//
//  FeedVC.swift
//  Tourney
//
//  Created by Thaddeus Lorenz on 5/29/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//
// After a user selects a TournamentCell, the user is presented with a competition/tournament
// that includes a newsfeed of the participants video uploads, top three most viewed videos,
// and the ability to "Start Competing" (upload a video)

import UIKit
import Firebase
import FirebaseDatabase
import SwiftKeychainWrapper
import AVKit
import CoreData
import Cache
import MessageUI

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
    /// ID of competition being displayed
    var activeFilter: String!
    /// ID of post which user has voted for within competition. Used to signify which post the user has voted for via the voting button
    var postIdOfCurrentUserVote: String?
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
        
        loadDataAndResetTable(scrollTo: nil)
        loadUserVotes()
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
    // clicking "Back"
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
       // self.activityIndicator.startAnimating()
        self.dismiss(animated: true, completion: nil);
        //self.activityIndicator.stopAnimating()
    }
    
    // view first place video on leaderboard
    @IBAction func firstVideoPressed(_ sender: Any) {
        self.selectedVideo = queried[0]
        self.performSegue(withIdentifier: "toTopVideo", sender: nil)
    }
    // view second place video on leaderboard
    @IBAction func secondButtonPressed(_ sender: Any) {
        self.selectedVideo = queried[1]
        self.performSegue(withIdentifier: "toTopVideo", sender: nil)
    }
    // view third place video on leaderboard
    @IBAction func thirdButtonPressed(_ sender: Any) {
        self.selectedVideo = queried[2]
        self.performSegue(withIdentifier: "toTopVideo", sender: nil)
    }
    
    @IBAction func uploadVideoButtonTapped() {
        performSegue(withIdentifier: "toRecordVideoVC", sender: nil)
    }
    @IBAction func rulesButtonTapped() {
        performSegue(withIdentifier: "toRulesVC", sender: nil)
    }
    // invite a user by sending a unique tournament/competition link through iMessage
    @IBAction func inviteTapped(_ sender: Any) {
        if MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()
            controller.body = "Think you can beat me? Start competing against me by uploading a video to the Tourney app. Accept this challenge by clicking the link https://tourney.page.link/\(activeFilter!)"
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
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
            cell.delegate = self
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
            // update vote button reflecting state of vote for post
            if let postIdOfCurrentUserVote = postIdOfCurrentUserVote {
                if postIdOfCurrentUserVote == post.postKey {
                    cell.isVotedFor = true
                } else {
                    cell.isVotedFor = false
                }
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
        secondPlaceProfileImageView.layer.borderColor = UIColor.gray.cgColor
        thirdPlaceProfileImageView.layer.borderColor = UIColor.orange.cgColor
    }
    // sorting all uploaded videos to competition/tournament by views
    // fetching data from Firebase and sorting the top three most viewed videos
    private func sortTopVideos() {
        print("running sort top videos...")
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
            
            queriedPosts = queriedPosts.sorted(by: { $0.votes > $1.votes })
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
    // updates leaderboard based off of views
    private func updateUITopVideos(topVideos: [Post?], any: Bool) {
        if let _ = topVideos[exist: 0] {
            firstPlaceUsernameLabel.text = topVideos[0]!.username
            firstPlaceViews.text = "\(topVideos[0]!.votes)"
            downloadImage(from: URL(string: topVideos[0]!.userImg)!, imageView: firstPlaceProfileImageView)
        }
        if let _ = topVideos[exist: 1] {
            secondPlaceUsernameLabel.text = topVideos[1]!.username
            secondPlaceViews.text = "\(topVideos[1]!.votes)"
            downloadImage(from: URL(string: topVideos[1]!.userImg)!, imageView: secondPlaceProfileImageView)
        }
        if let _ = topVideos[exist: 2] {
            thirdlaceUsernameLabel.text = topVideos[2]!.username
            thirdPlaceViews.text = "\(topVideos[2]!.votes)"
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
    /**
     Initial load for user vote to reflect on posts being displayed.
     */
    private func loadUserVotes() {
        // initial load vote for user to reflect on cell
        if let userManager = UserManager() {
            userManager.getVotes { (votes) in
                if let votes = votes {
                    if (votes[self.activeFilter] != nil) {
                        self.postIdOfCurrentUserVote = votes[self.activeFilter]
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    /**
     Loads video submissions (Posts) that have `eventID` as the tournament id (`activeFilter`).
     
     To scroll to a video: if `videoURL` parameter  is non-nil, it will look for the `Post` that has the `_videoLink` property to `videoURL'`. Else, it won't scroll.
     */
    func loadDataAndResetTable(scrollTo videoURL: String?) {
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
            
            // if video url passed, scroll to it
            if let videoURLToScrollTo = videoURL {
                for (index, post) in self.posts.enumerated() {
                    if post._videoLink == videoURLToScrollTo {
                        self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
                    }
                }
            }
            
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
        } else if segue.identifier == "toUploadVideoVC" {
            if let destination = segue.destination as? UploadVideo {
                print("this segue ran")
                destination.delegate = self
            }
        } else if segue.identifier == "toRecordVideoVC" {
            if let destination = segue.destination as? RecordVideo {
                destination.feedVC = self
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
extension FeedVC: UploadVideoDelegate {
    func didUploadVideo(with videoURL: String) {
        loadDataAndResetTable(scrollTo: videoURL)
    }
}

extension FeedVC: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
extension FeedVC: PostCellDelegate {
    /**
     Delegate call from `PostCellDelegate`
     */
    func didVoteForPost(postId: String) {
        voteForPost(newVotePostId: postId)
    }
    /**
     Set a vote from user towards a submission.
     */
    private func voteForPost(newVotePostId: String) {
        // check if user already voted for a post in this competition
        if let userManager = UserManager() {
            userManager.getVotes { (votes) in
                if let votes = votes, let oldVotePostId = votes[self.activeFilter] {
                    // if user is unvoting a submission which they previously voted for
                    if newVotePostId == oldVotePostId {
                        // remove vote from user object and leave empty
                        userManager.removeVoteFromCompetition(competitionId: self.activeFilter)
                        // remove vote from post
                        PostManager(postId: newVotePostId).removeVote {
                            // update leaderboard videos
                            self.sortTopVideos()
                        }
                        // update current vote (to reflect on cells)
                        self.postIdOfCurrentUserVote = nil
                    } else {
                        // remove vote from old post by decreasing the post.votes count
                        PostManager(postId: oldVotePostId).removeVote {}
                        // add new vote to post Id in post model
                        PostManager(postId: newVotePostId).addVote {
                            // update leaderboard videos
                            self.sortTopVideos()
                        }
                        // replace vote with new vote in user model
                        userManager.addVote(competitionId: self.activeFilter, postId: newVotePostId)
                        // update current vote (to reflect on cells)
                        self.postIdOfCurrentUserVote = newVotePostId
                    }
                } else {
                    // new vote
                    if let userManager = UserManager() {
                        // add vote to user model
                        userManager.addVote(competitionId: self.activeFilter, postId: newVotePostId)
                        // add vote post model
                        PostManager(postId: newVotePostId).addVote {
                            // update leaderboard videos
                            self.sortTopVideos()
                        }
                        // update current vote (to reflect on cells)
                        self.postIdOfCurrentUserVote = newVotePostId
                        // update leaderboard videos
                        self.sortTopVideos()
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
}
