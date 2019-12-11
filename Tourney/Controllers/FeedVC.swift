//
//  FeedVC.swift
//  goldcoastleague
//
//  Created by Thaddeus Lorenz on 5/29/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SwiftKeychainWrapper
import AVKit
import CoreData
import Cache

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postBtn: UIButton!
    
    // leaderboard profile images
    @IBOutlet var firstPlaceProfileImageView: UIImageView!
    @IBOutlet var secondPlaceProfileImageView: UIImageView!
    @IBOutlet var thirdPlaceProfileImageView: UIImageView!
    
    // leaderboard usernames
    @IBOutlet var firstPlaceUsernameLabel: UILabel!
    @IBOutlet var secondPlaceUsernameLabel: UILabel!
    @IBOutlet var thirdlaceUsernameLabel: UILabel!
    
    // leaderboard views
    @IBOutlet var firstPlaceViews: UILabel!
    @IBOutlet var secondPlaceViews: UILabel!
    @IBOutlet var thirdPlaceViews: UILabel!
    
    @IBOutlet weak var noVideosPostedLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var posts = [Post]()
    var post: Post!
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var selectedImage: UIImage!
    var userImage: String!
    var userName: String!
    
    var activeFilter: String!
    
    var currentCellPlaying: PostCell!
    var cells: [PostCell] = [];
    var cellPostkeys: [String] = []
    var firstRun: Bool = true
    
    var selectedVideo: Post!
    var queried: [Post] = []
    
    var likedPosts: [String] = []
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noVideosPostedLabel.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        loadDataAndResetTable()
        configureViews()
        
        sortTopVideos()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*if let currentCell = currentCell {
            currentCell.isActive();
        }
        loadDataAndResetTable()
         */
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        /*if let currentCell = currentCell {
            currentCell.isUnactive()
        }
         */
    }
    
    // MARK: - Actions
    
    @IBAction func postImageTapped(_ sender: AnyObject){
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func SignOut (_sender: AnyObject){
        try! Auth.auth().signOut()
        
        KeychainWrapper.standard.removeObject(forKey: "uid")
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
       // self.activityIndicator.startAnimating()
        self.dismiss(animated: true, completion: nil);
        //self.activityIndicator.stopAnimating()
    }
    
    @IBAction func firstVideoPressed(_ sender: Any) {
        self.selectedVideo = queried[0]
        self.performSegue(withIdentifier: "toTopVideo", sender: nil)
    }
    
    @IBAction func secondButtonPressed(_ sender: Any) {
        self.selectedVideo = queried[1]
        self.performSegue(withIdentifier: "toTopVideo", sender: nil)
    }
    
    @IBAction func thirdButtonPressed(_ sender: Any) {
        self.selectedVideo = queried[1]
        self.performSegue(withIdentifier: "toTopVideo", sender: nil)
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (tableView.frame.height * 0.90)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            cell.configCell(post: post)
            if (cellPostkeys.contains(post.postKey)) {
                let index = cellPostkeys.firstIndex(of: post.postKey)
                cells[index!] = cell
            } else {
                cells.append(cell)
                cellPostkeys.append(post.postKey)
            }
            if (firstRun && (indexPath.row == 0)) {
                cell.playvid(url: post.videoLink)
                currentCellPlaying = cell
                firstRun = false
            }
            cell.updateThumbnail()
            return cell
        } else {
            return PostCell()
        }
        
        /*
         cell.configCell(post: post)
         if (!cells.contains(cell)) {
         cells.append(cell)
         }
         if (indexPath.row == 0) {
         cell.isActive()
         } else {
         cell.isUnactive()
         }
         return cell
         */
    }
   
    // MARK: - Helpers
    
    private func configureViews() {
        firstPlaceProfileImageView.layer.borderColor = UIColor.systemYellow.cgColor
        secondPlaceProfileImageView.layer.borderColor = UIColor.orange.cgColor
        thirdPlaceProfileImageView.layer.borderColor = UIColor.gray.cgColor
    }
    
    private func sortTopVideos() {
        let ref = Database.database().reference().child("posts")
        var queriedPosts: [Post] = []
        let query = ref.queryOrdered(byChild: "eventID").queryEqual(toValue: activeFilter)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            if let childSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                queriedPosts.removeAll()
                for data in childSnapshot {
                    if let postDict = data.value as? Dictionary<String, AnyObject>{
                        let key = data.key
                        let post = Post(postKey: key, postData: postDict)
                        queriedPosts.append(post)
                    }
                }
            }
            
            queriedPosts = queriedPosts.sorted(by: { $0.views > $1.views })
            self.queried = queriedPosts
            if (queriedPosts.count == 1) {
                self.updateUITopVideos(topVideos: [queriedPosts[0]], any: true)
            } else if (queriedPosts.count == 2) {
                self.updateUITopVideos(topVideos: [queriedPosts[0], queriedPosts[1]], any: true)
            } else if (queriedPosts.count == 0) {
                self.updateUITopVideos(topVideos: [], any: false)
            } else {
                self.updateUITopVideos(topVideos: [queriedPosts[0], queriedPosts[1] , queriedPosts[2]], any: true)
            }
        })
    }
    
    private func updateUITopVideos(topVideos: [Post?], any: Bool) {
        if let _ = topVideos[exist: 0] {
            firstPlaceUsernameLabel.text = topVideos[0]!.username
            firstPlaceViews.text = "\(topVideos[0]!.views)"
            downloadImage(from: URL(string: topVideos[0]!.userImg)!, imageView: firstPlaceProfileImageView)
        }
        if let _ = topVideos[exist: 1] {
            secondPlaceUsernameLabel.text = topVideos[1]!.username
            secondPlaceViews.text = "\(topVideos[1]!.views)"
            downloadImage(from: URL(string: topVideos[1]!.userImg)!, imageView: secondPlaceProfileImageView)
        }
        if let _ = topVideos[exist: 2] {
            thirdlaceUsernameLabel.text = topVideos[2]!.username
            thirdPlaceViews.text = "\(topVideos[2]!.views)"
            downloadImage(from: URL(string: topVideos[2]!.userImg)!, imageView: thirdPlaceProfileImageView)
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, imageView: UIImageView) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() {
                imageView.image = UIImage(data: data)
            }
        }
    }
    
    func loadDataAndResetTable() {
        let ref = Database.database().reference().child("posts")
        let query = ref.queryOrdered(byChild: "eventID").queryEqual(toValue: activeFilter)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                self.posts.removeAll()
                for data in snapshot {
                    if let postDict = data.value as? Dictionary<String, AnyObject> {
                        let key = data.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post)
                        let postIndex = self.posts.firstIndex{$0 === post}
                        self.getThumbnailImageFromVideoUrl(post: post) { (image) in
                            post.thumbnail = image
                            if (self.cells.count > postIndex!) {
                                let cell = self.cells[postIndex!]
                                cell.updateThumbnail()
                            }
                        }
                    }
                }
            }
            self.tableView.reloadData()
            if (self.posts.count == 0) {
                self.noVideosPostedLabel.isHidden = false
            }
        })
    }
    
    func getThumbnailImageFromVideoUrl(post: Post, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.global().async {
            let asset = AVAsset(url: URL(string: post.videoLink)!)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        var mostVisiblePercentage: CGFloat = 0.0
        var newMostVisibleCandidate: PostCell!
        for item in tableView.indexPathsForVisibleRows! {
            let cellRect = tableView.rectForRow(at: item)
            if let superview = tableView.superview {
                let convertedRect = tableView.convert(cellRect, to:superview)
                let intersect = tableView.frame.intersection(convertedRect)
                let visibleHeight = intersect.height
                let cellHeight = cellRect.height
                let ratio = visibleHeight / cellHeight
                
                if (ratio > mostVisiblePercentage) {
                    newMostVisibleCandidate = (tableView.cellForRow(at: item) as! PostCell)
                    mostVisiblePercentage = ratio
                }
                
            }
        }
        
        if (newMostVisibleCandidate != currentCellPlaying) {
            currentCellPlaying.stopvid()
            newMostVisibleCandidate.playvid(url: newMostVisibleCandidate.post.videoLink)
            currentCellPlaying = newMostVisibleCandidate
        }
        
    }
        
    func postToFireBase(imgUrl: String){
        let userID = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(userID!).observeSingleEvent(of: .value, with: {(snapshot) in
            let data = snapshot.value as! Dictionary<String, AnyObject>
            let username = data["username"]
            let userImg = data["userImg"]
            let post: Dictionary<String, AnyObject> = [
                "username": username as AnyObject,
                "userImg": userImg as AnyObject,
                "imageUrl": imgUrl as AnyObject,
                "likes": 0 as AnyObject
            ]
            let firebasePost = Database.database().reference().child("posts").childByAutoId()
            firebasePost.setValue(post)
            self.imageSelected = false
            self.tableView.reloadData()
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTopVideo" {
            if let destination = segue.destination as? TopVideoController {
                destination.post = self.selectedVideo
            }
        } else if segue.identifier == "toUploadVideo" {
            if let destination = segue.destination as? UploadVideo {
                
            }
        } else if segue.identifier == "recordVideoSegue" {
            if let destination = segue.destination as? RecordVideo {
                
            }
        }
    }
    
}
extension FeedVC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            selectedImage = image
            imageSelected = true
        } else {
            print("a valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
        guard imageSelected == true else{
            print("An image needs to be selected")
            return
        }
        if let imgData = selectedImage.jpegData(compressionQuality: 0.2){
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            let storageRef = Storage.storage().reference().child("post-pics").child(imgUid)
            storageRef.putData(imgData, metadata: metadata){
                (metadata, error) in
                if error != nil{
                    print("did not upload image")
                } else {
                    print("Image was saved")
                    storageRef.downloadURL(completion: {url, error in
                        if let _ = error {
                            print("error")
                        } else {
                            print((url?.absoluteString)!)
                            
                            self.postToFireBase(imgUrl: url!.absoluteString)
                            print("HELLO")
                        }
                    })
                    
                }
            }
        }
    }
}

extension Collection where Indices.Iterator.Element == Index {
    subscript (exist index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
