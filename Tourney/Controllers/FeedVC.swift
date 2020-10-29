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
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
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
    
    // MARK: - Properties
    
    var tournament: Tournament!
    var submissions: [Submission] = []
    var indexPathToPlayVideo: IndexPath?
    
    var posts = [Post]()
    var post: Post!
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var selectedImage: UIImage!
    var userImage: String!
    var userName: String!
    /// ID of competition being displayed
    var activeFilter: String! = "BMX_Competition_2"
    /// ID of post which user has voted for within competition. Used to signify which post the user has voted for via the voting button
    var submissionIdOfCurrentUserVote: String?
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

        fetchLeaderboard()
        fetchSubmissions()
        loadUserVotes()
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (tableView.frame.height * 0.90)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return submissions.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        let submission = submissions[indexPath.row]
        
        cell.submissionId = submission.id
        cell.delegate = self
        cell.usernameLabel.text = submission.creatorUsername
        cell.viewsLabel.text = "\(submission.views)"
        cell.profileImageView.kf.setImage(with: submission.creatorProfileImageURL)
        cell.thumbnailImageView.kf.setImage(with: submission.thumbnailURL)
        
        if (firstRun && (indexPath.row == 0)) {
            currentCellPlaying = cell
            firstRun = false
        }
        
        // update vote button reflecting state of vote for post
        if let submissionIdOfCurrentUserVote = submissionIdOfCurrentUserVote {
            if submissionIdOfCurrentUserVote == submission.id {
                cell.isVotedFor = true
            } else {
                cell.isVotedFor = false
            }
        }
        
        // playback for first run on first cell
        if firstRun && indexPath.row == 0 {
            cell.playVideo(videoURL: submission.videoURL)
            currentCellPlaying = cell
            firstRun = false
        }
        
        return cell
    }
    
    // MARK: - Helpers
    
    private func configureViews() {
        firstPlaceProfileImageView.layer.borderColor = UIColor.systemYellow.cgColor
        secondPlaceProfileImageView.layer.borderColor = UIColor.gray.cgColor
        thirdPlaceProfileImageView.layer.borderColor = UIColor.orange.cgColor
    }
    
    /// Fetch leadboard submissions
    private func fetchLeaderboard() {
        SubmissionManager().fetchLeaderboardForTorunament(tournamentId: tournament.id) { (submissions) in
            guard let submissions = submissions else {
                print("error getting subs")
                return
            }
            self.setUpSubmissionsUI(submissions)
        }
    }
    
    /// Render submissions into leaderboard UI
    private func setUpSubmissionsUI(_ submissions: [Submission]) {
        
        for (index, submission) in submissions.enumerated() {
            // first place
            if index == 0 {
                firstPlaceProfileImageView.kf.setImage(with: submission.creatorProfileImageURL)
                firstPlaceUsernameLabel.text = submission.creatorUsername
                firstPlaceViews.text = "\(submission.views)"
            }
            // second place
            if index == 1 {
                secondPlaceProfileImageView.kf.setImage(with: submission.creatorProfileImageURL)
                secondPlaceUsernameLabel.text = submission.creatorUsername
                secondPlaceViews.text = "\(submission.views)"
            }
            // third place
            if index == 2 {
                thirdPlaceProfileImageView.kf.setImage(with: submission.creatorProfileImageURL)
                thirdlaceUsernameLabel.text = submission.creatorUsername
                thirdPlaceViews.text = "\(submission.views)"
            }
        }
    }
    
    /// Fetch submissions for tournament
    private func fetchSubmissions() {
        SubmissionManager().fetchSubmissionsForTournament(tournamentId: tournament.id) { (submissions) in
            if let submissions = submissions {
                self.submissions = submissions
                self.tableView.reloadData()
            }
        }
    }

    /// Initial load for user vote to reflect on posts being displayed.
    private func loadUserVotes() {
        // initial load vote for user to reflect on cell
        if let userManager = UserManager() {
            userManager.getVotes { (votes) in
                if let votes = votes {
                    if (votes[self.tournament.id] != nil) {
                        self.submissionIdOfCurrentUserVote = votes[self.tournament.id]
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    /// Fetch new submission with video URL and scroll to it.
    private func fetchSubmissionAndShow(videoURL: URL) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // handle video playing
        
        var mostVisiblePercentage: CGFloat = 0.0
        var newMostVisibleCandidate: PostCell!
        var indexPath: IndexPath!
        
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
                    indexPath = item
                }
            }
        }
        
        if (newMostVisibleCandidate != currentCellPlaying) {
            let submission = submissions[indexPath.row]
            // update cells video playback
            currentCellPlaying.stopVideo()
            newMostVisibleCandidate.playVideo(videoURL: submission.videoURL)
            currentCellPlaying = newMostVisibleCandidate
            // update video views
            PostManager(submissionId: submission.id).addView()
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
                destination.tournament = tournament
                destination.feedVC = self
            }
        } else if segue.identifier == "toRulesVC" {
            if let destination = segue.destination as? RulesViewController {
                destination.delegate = self
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

extension FeedVC: UploadVideoDelegate {
    func didUploadVideo(with videoURL: String) {
        if let url = URL(string: videoURL) {
            fetchSubmissionAndShow(videoURL: url)
        }
    }
}

extension FeedVC: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
extension FeedVC: SubmissionCellDelegate {
    func didVoteForSubmission(submissionId: String) {
        voteForSubmission(submissionId: submissionId)
    }
    /**
     Set a vote from user towards a submission.
     */
    private func voteForSubmission(submissionId: String) {
        // check if user already voted for a post in this competition
        if let userManager = UserManager() {
            userManager.getVotes { (votes) in
                if let votes = votes, let oldVotePostId = votes[self.tournament.id] {
                    // if user is unvoting a submission which they previously voted for
                    if submissionId == oldVotePostId {
                        // remove vote from user object and leave empty
                        userManager.removeVoteFromCompetition(competitionId: self.tournament.id)
                        // remove vote from post
                        PostManager(submissionId: submissionId).removeVote {
                            // update leaderboard videos
//                            self.sortTopVideos()
                        }
                        // update current vote (to reflect on cells)
                        self.submissionIdOfCurrentUserVote = nil
                    } else {
                        // remove vote from old post by decreasing the post.votes count
                        PostManager(submissionId: oldVotePostId).removeVote {}
                        // add new vote to post Id in post model
                        PostManager(submissionId: submissionId).addVote {
                            // update leaderboard videos
//                            self.sortTopVideos()
                        }
                        // replace vote with new vote in user model
                        userManager.addVote(competitionId: self.tournament.id, postId: submissionId)
                        // update current vote (to reflect on cells)
                        self.submissionIdOfCurrentUserVote = submissionId
                    }
                } else {
                    // new vote
                    if let userManager = UserManager() {
                        // add vote to user model
                        userManager.addVote(competitionId: self.tournament.id, postId: submissionId)
                        // add vote post model
                        PostManager(submissionId: submissionId).addVote {
                            // update leaderboard videos
//                            self.sortTopVideos()
                        }
                        // update current vote (to reflect on cells)
                        self.submissionIdOfCurrentUserVote = submissionId
                        // update leaderboard videos
//                        self.sortTopVideos()
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
}
extension FeedVC: RulesViewControllerDelegate {
    func didTapStartCompeting() {
        performSegue(withIdentifier: "toRecordVideoVC", sender: nil)
    }
}
