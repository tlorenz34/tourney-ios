//
//  UploadVideo.swift
//  Tourney
//
//  Created by Will Cohen on 7/17/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//
// When a user picks a video from their camera roll, they have the ability to clip and
// adjust the video to a maximum of 10 seconds. This class helps the user pick, clip/edit, then
// upload the video
import UIKit
import AVKit
import AVFoundation
import Firebase
import Photos
import SwiftKeychainWrapper
import MobileCoreServices

/**
 Delegate to let other view controllers know when the `UploadVideo` view controller has finished uploading a video to the database.
 */

protocol UploadVideoDelegate: class {
    func didUploadVideo(with videoURL: String)
}

class UploadVideo: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Actions
    
    @IBAction func RecordButtonTapped() {
        performSegue(withIdentifier: "toRecordVideo", sender: nil)
    }
    @IBAction func chooseVideoButtonPressed(_ sender: Any) {
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.movie"]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    @IBAction func uploadVideoButtonPressed(_ sender: Any) {
                
        // add loading indicator
        loadingIndicatorView.center = uploadButton.center
        if let buttonSuperView = uploadButton.superview {
            buttonSuperView.addSubview(loadingIndicatorView)
            uploadButton.setTitle("", for: .normal)
            loadingIndicatorView.startAnimating()
        }
        
        guard let videoURL = videoURL,
              let username = User.sharedInstance.username,
              let userProfileImageURLString = User.sharedInstance.profileImageURL,
              let userProfileImageURL = URL(string: userProfileImageURLString) else { return }
        
        uploadAndCreateSubmission(videoURL: videoURL, username: username, userProfileImageURL: userProfileImageURL)
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var chooseVideoButton: UIButton!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var trimView: ABVideoRangeSlider!
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var recordButton: UIButton!
    
    weak var delegate: UploadVideoDelegate?
    
    let VIDEO_MAX_DURATION: Float = 10.0;
    
    var didComeFromRecording: Bool = false
    var recordedVideo: URL!
    let loadingIndicatorView = UIActivityIndicatorView()
    
    let imagePickerController = UIImagePickerController()
    var videoURL: NSURL?
    let uid: String = KeychainWrapper.standard.string(forKey: "uid") ?? "";
    var randomID: String!
    
    var player : AVPlayer!
    var item: AVPlayerItem!
    var avPlayerLayer : AVPlayerLayer!
    
    var endTime = 0.0;
    var startTime = 0.0;
    var timeObserver: AnyObject!
    var shouldUpdateProgressIndicator = true
    
    var priorRecordingController: RecordVideo!
    
    /// Tournament that video is being uploaded under.
    var tournament: Tournament!
    
    // MARK: - View lifecyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        randomID = self.randomString(length: 16);
        setupTrimView()
        if (didComeFromRecording) {
            setupRecordingPreview()
        }
    }
    
    // MARK: - Helpers
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        checkPermissions()
        
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL {
            self.setupVideoView(videoURL: videoURL as URL)
        }
        //Dismiss the controller after picking some media
        dismiss(animated: true, completion: nil)
        
    }
    
    /**
     Adds a new `Submission` and dismisses view controller.
     
     The function does several things linked together:
     1. Crops video.
     2. Captures thumbnail of video.
     3. Uploads the thumbnail and video to Storage.
     4. Creates new `Submission` with data.
     5. Dismisses view controller.
     */
    private func uploadAndCreateSubmission(videoURL: NSURL, username: String, userProfileImageURL: URL) {
        // crop video
        cropVideo(sourceURL: videoURL as URL, startTime: self.startTime, endTime: self.endTime) { (croppedVideoURL) in
            print("cropeed video...")
            // make thumbnail from video
            self.getThumbnailImageFromVideoUrl(videoURL: croppedVideoURL) { (image) in
                // upload thumbnail
                if let image = image {
                    
                    print("got image from video.... ")
                    self.uploadThumbnailToStorage(image: image) { (uploadedThumbnailURL) in
                        if let uploadedThumbnailURL = uploadedThumbnailURL {
                            
                            print("uplaoded thumbnail to storage...")
                            
                            // upload video
                            self.uploadVideoToSubmissionsStorage(url: croppedVideoURL) { (uploadedVideoURL) in
                                if let uploadedVideoURL = uploadedVideoURL {
                                    print("uploaded video to storage....")
                                    // create submission
                                    let submission = Submission(tournamentId: self.tournament.id, creatorProfileImageURL: userProfileImageURL, creatorUsername: username, videoURL: uploadedVideoURL, thumbnailURL: uploadedThumbnailURL)
                                    // save new submission
                                    SubmissionManager().saveNew(submission)
                                    // dismiss
                                    if let priorController = self.priorRecordingController {
                                        priorController.shouldDismiss = true
                                    }
                                    self.dismiss(animated: true) {
                                        // delegate implementation
                                        self.delegate?.didUploadVideo(with: uploadedVideoURL.absoluteString)
                                    }
                                    
                                } else {
                                    print("failed to uploaded video")
                                }
                            }
                        } else {
                            print("failed to uploaded thumbnail")
                        }
                    }
                }
            }
        }
    }
    
    func setupRecordingPreview() {
        self.videoURL = recordedVideo! as NSURL
        trimView.setVideoURL(videoURL: recordedVideo)
        trimView.delegate = self
        trimView.minSpace = 1.0
        trimView.maxSpace = 8.0
        trimView.setStartPosition(seconds: 0.0)
        self.startTime = 0.0;
        
        item = AVPlayerItem(url: recordedVideo)
        player = AVPlayer(playerItem: item)
        avPlayerLayer = AVPlayerLayer(player: player)
        avPlayerLayer.frame = videoView.layer.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.item.forwardPlaybackEndTime = CMTimeMake(value: (Int64(endTime * 10000)), timescale: 10000)
        let videoDuration = player.currentItem!.asset.duration.seconds
        
        if (Float(videoDuration) > VIDEO_MAX_DURATION) {
            self.endTime = 8.0;
            trimView.setEndPosition(seconds: 8.0)
        } else {
            self.endTime = videoDuration;
            trimView.setEndPosition(seconds: Float(videoDuration))
        }
        
        videoView.layer.addSublayer(avPlayerLayer)
        player.play()
    }
    /**
     Uploads video to Storage under the `videos` folder.
     */
    func uploadVideoToSubmissionsStorage(url: URL, completion: @escaping ((_ url: URL?) -> Void)) {
        let storageReference = Storage.storage().reference().child("videos").child(UUID().uuidString)
        storageReference.putFile(from: url, metadata: nil, completion: { (metadata, error) in
            if error == nil {
                  // You can also access to download URL after upload.
                storageReference.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                    }
                    completion(downloadURL)
                }
                
            } else {
                // if error, stop loading indicator
                self.loadingIndicatorView.stopAnimating()
                self.resetUploadButtonState()
                print(error?.localizedDescription ?? "")
                completion(nil)
            }
        })
    }
    /**
     Uploads video to Storage under the `featuredVideos` folder.
     */
    func uploadVideoToFeaturedVideosStorage(url: URL, completion: @escaping ((_ url: URL?) -> Void)) {
        let storageReference = Storage.storage().reference().child("featured-videos").child(UUID().uuidString)
        storageReference.putFile(from: url, metadata: nil, completion: { (metadata, error) in
            if error == nil {
                  // You can also access to download URL after upload.
                storageReference.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                    }
                    completion(downloadURL)
                }
                
            } else {
                // if error, stop loading indicator
                self.loadingIndicatorView.stopAnimating()
                self.resetUploadButtonState()
                print(error?.localizedDescription ?? "")
                completion(nil)
            }
        })
    }
    /**
     Uploads image to Storage under the `videoThumbnails` folder.
     */
    func uploadThumbnailToStorage(image: UIImage, completion: @escaping ((_ url: URL?) -> Void)) {
        guard let imageData: Data = image.jpegData(compressionQuality: 0.1) else {
            return
        }

        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "image/jpg"

        let storageRef = Storage.storage().reference().child("video-thumbnails").child(UUID().uuidString)

        storageRef.putData(imageData, metadata: metaDataConfig){ (metaData, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
                return
            }

            storageRef.downloadURL(completion: { (url: URL?, error: Error?) in
                completion(url)
            })
        }
    }
    private func observeTime(elapsedTime: CMTime) {
        let elapsedTime = CMTimeGetSeconds(elapsedTime)
        if (player.currentTime().seconds > self.endTime) {
            print("did end?")
            player.seek(to: CMTime(seconds: (startTime * 10000), preferredTimescale: 10000))
        }
        
        if self.shouldUpdateProgressIndicator {
            trimView.updateProgressIndicator(seconds: elapsedTime)
        }
    }
    
    private func setupTrimView() {
        let customStartIndicator =  UIImage(named: "CustomStartIndicator")
        trimView.setStartIndicatorImage(image: customStartIndicator!)
        let customStopIndicator =  UIImage(named: "CustomStopIndicator")
        trimView.setEndIndicatorImage(image: customStopIndicator!)
        let customProgressIndicator =  UIImage(named: "CustomProgressIndicator")
        trimView.setProgressIndicatorImage(image: customProgressIndicator!)
        let customBorder =  UIImage(named: "CustomBorder")
        trimView.setBorderImage(image: customBorder!)
        trimView.startTimeView.backgroundColor = UIColor.white;
        trimView.endTimeView.backgroundColor = UIColor.white;
        trimView.startTimeView.timeLabel.backgroundColor = UIColor.white
        trimView.startTimeView.backgroundView.backgroundColor = UIColor.white
        trimView.endTimeView.timeLabel.backgroundColor = UIColor.white
        trimView.endTimeView.backgroundView.backgroundColor = UIColor.white
    }
    
    private func setupVideoView(videoURL: URL) {
        
        self.videoURL = videoURL as NSURL
        trimView.setVideoURL(videoURL: videoURL)
        trimView.delegate = self
        trimView.minSpace = 1.0
        trimView.maxSpace = 8.0
        trimView.setStartPosition(seconds: 0.0)
        self.startTime = 0.0;

        item = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: item)
        avPlayerLayer = AVPlayerLayer(player: player)
        avPlayerLayer.frame = videoView.layer.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.item.forwardPlaybackEndTime = CMTimeMake(value: (Int64(endTime * 10000)), timescale: 10000)
        let videoDuration = player.currentItem!.asset.duration.seconds
        
        if (Float(videoDuration) > VIDEO_MAX_DURATION) {
            self.endTime = 8.0;
            trimView.setEndPosition(seconds: 8.0)
        } else {
            self.endTime = videoDuration;
            trimView.setEndPosition(seconds: Float(videoDuration))
        }
        
        videoView.layer.addSublayer(avPlayerLayer)
        player.play()
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { [weak self] _ in
            self?.player.seek(to: CMTimeMake(value: (Int64((self?.startTime)! * 10000)), timescale: 10000))
            self?.player.play()
        }
        
        //self.endTime = CMTimeGetSeconds((player.currentItem?.duration)!)
        let timeInterval: CMTime = CMTimeMakeWithSeconds(0.01, preferredTimescale: 100)
        timeObserver = player.addPeriodicTimeObserver(forInterval: timeInterval,
                                                      queue: DispatchQueue.main) { (elapsedTime: CMTime) -> Void in
                                                        self.observeTime(elapsedTime: elapsedTime) } as AnyObject?
        
    }
    
    func checkPermissions() {
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    
                } else {
                    print("do something here to handle")
                }
            })
        }
    }
    
    func cropVideo(sourceURL: URL, startTime: Double, endTime: Double, completion: ((_ outputUrl: URL) -> Void)? = nil) {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let asset = AVAsset(url: sourceURL)
        _ = Float(asset.duration.value) / Float(asset.duration.timescale)
        
        var outputURL = documentDirectory.appendingPathComponent("output")
        do {
            try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("\(sourceURL.lastPathComponent)")
        }catch let error {
            print(error)
        }
        
        //Remove existing file
        try? fileManager.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        
        let timeRange = CMTimeRange(start: CMTime(seconds: (startTime), preferredTimescale: 1000),
                                    end: CMTime(seconds: (endTime), preferredTimescale: 1000))
      
        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                print("exported at \(outputURL)")
                completion?(outputURL)
            case .failed:
                print("failed \(exportSession.error.debugDescription)")
            case .cancelled:
                print("cancelled \(exportSession.error.debugDescription)")
            default: break
            }
        }
    }

    func getThumbnailImageFromVideoUrl(videoURL: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.global().async {
            let asset = AVAsset(url: videoURL)
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            let thumnailTime = CMTimeMake(value: 1, timescale: 1)
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    completion(thumbImage)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func resetUploadButtonState() {
        uploadButton.setTitle("Upload", for: .normal)
    }
    
}

extension UploadVideo: ABVideoRangeSliderDelegate {
    
    func didChangeValue(videoRangeSlider: ABVideoRangeSlider, startTime: Float64, endTime: Float64) {
        self.startTime = startTime
        self.endTime = endTime
        trimView.updateProgressIndicator(seconds: startTime)
        self.player.seek(to: CMTimeMake(value: (Int64(startTime * 10000)), timescale: 10000))
        //self.player.seek(to: CMTimeMake(value: Int64(startTime), timescale: 1))
        self.item.forwardPlaybackEndTime = CMTimeMake(value: (Int64(endTime * 10000)), timescale: 10000)
        self.player.play()
    }
    
    func indicatorDidChangePosition(videoRangeSlider: ABVideoRangeSlider, position: Float64) {
      //  self.shouldUpdateProgressIndicator = false
    }
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
}



