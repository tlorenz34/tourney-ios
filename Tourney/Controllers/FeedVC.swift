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



// Protocol

//protocol Driveable{
//    func turnLeft()
//
//    func accelerate(value: Int)
//}
//
//
//class Car : Driveable{
//    func turnLeft() {
//
//    }
//
//    func accelerate(value: Int) {
//
//    }
//
//    // Properties
//    let color: String
//
//    // Init
//    init(color: String){
//        self.color = color
//    }
//
//    // Methods
//    func drive(){
//
//    }
//
//}
//
////let mazda = Car(color: "gray")
////mazda.color
////mazda.drive()
//
//class Bike : Driveable{
//    func turnLeft() {
//
//    }
//
//    func accelerate(value: Int) {
//
//    }
//
//
//}
//
//let vehicles =  [Drivable]()
//let car : Driveable = Car(color: "gray")
//car.turnLeft()


// Design Patterns

// Delegation
    // how do two objects communicate with each other, with one not knowing the class of the other

    // Two objects
        // Delegator - events to emit --> UIKit object can be delagtor
        // Delegate - receiving events, doing something with information -> ViewController

// TableView (Delegator) <--> FeedVC (Delegate)
    // - delegate: UITableViewDelegate?
    // - dataSource: UITableViewDataSource

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
    
    @IBOutlet weak var submissionLeaderboardSegmentControl: UISegmentedControl!
    
    @IBOutlet var thirdlaceUsernameLabel: UILabel!
    
    // leaderboard views
    @IBOutlet var firstPlaceVotesLabel: UILabel!
    @IBOutlet var secondPlaceVotesLabel: UILabel!
    @IBOutlet var thirdPlaceVotesLabel: UILabel!
    
    @IBOutlet weak var noVideosPostedLabel: UILabel!
    @IBOutlet var startCompetingButton: UIButton!
    /// Plays `featuredVideoURL` of `Tournament`. Also serves as the button for the parent tournament winner to upload the featured video.
    @IBOutlet var challengeButton: UIButton!
            
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
        if leaderboardSubmissions.indices.contains(0) {
            playVideo(url: leaderboardSubmissions[0].videoURL)
        }
    }
    // view second place video on leaderboard
    @IBAction func secondButtonPressed(_ sender: Any) {
        if leaderboardSubmissions.indices.contains(1) {
            playVideo(url: leaderboardSubmissions[1].videoURL)
        }
    }
    // view third place video on leaderboard
    @IBAction func thirdButtonPressed(_ sender: Any) {
        if leaderboardSubmissions.indices.contains(2) {
            playVideo(url: leaderboardSubmissions[2].videoURL)
        }
    }
    
    @IBAction func uploadVideoButtonTapped() {
        performSegue(withIdentifier: "toRecordVideoVC", sender: nil)
    }
    @IBAction func rulesButtonTapped() {
        performSegue(withIdentifier: "toRulesVC", sender: nil)
    }
    /// Invite a user by sending a unique tournament/competition link through iMessage
    @IBAction func inviteTapped(_ sender: Any) {
        
        guard let tournament = tournament else { return }
        
        DynamicLinkGenerator().generateLinkForTournament(tournament) { (url) in
            if let url = url {
                
                let ac = UIActivityViewController(activityItems: ["Check out \(tournament.name) tournament", url], applicationActivities: nil)
               // ac.excludedActivityTypes = [.postToFacebook]
                self.present(ac, animated: true)
                
//                self.sendMessageWithURL(url: url)
            }
        }
    }
    /// Plays challenge video or request challenge video to be uploaded depending on user tapping.
    @IBAction func challengeButtonTapped() {
        
        stopCurrentVideoPlayback()
        
        // if featured video is available, play it
        if let featuredVideoURL = tournament.featuredVideoURL {
            playVideo(url: featuredVideoURL)
        }
        // no challenge video available yet and current user is not parent tournament winner, show alert
        // note: this should never run as tournaments without `featuredVideoURL` properties are not fetched unless the user is indeed the parent tournament winner.
        else {
            showAlert(title: "Error", message: "No challenge video available yet.")
        }
    }
    
    @IBAction func leaderboardButtonTapped(_ sender: UIButton) {
        let leaderboardSubmission = leaderboardSubmissions[sender.tag]
        stopCurrentVideoPlayback()
        playVideo(url:  leaderboardSubmission.videoURL)
    }
    
    // MARK: - Properties
    
    var tournament: Tournament!
    var submissions: [Submission] = []
    /// Holds leaderboard submissions where index 0 is first, 1 is second, etc.
    var leaderboardSubmissions: [Submission] = []
    
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
    var currentCellPlaying: SubmissionCell?
    var currentCellPlayingIndexPath: IndexPath?
    var cells: [SubmissionCell] = [];
    var cellPostkeys: [String] = []
    var firstRun: Bool = true
        
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
        
        // Can user interact?
        // Can user particpate?
        startCompetingButton.isHidden = !tournament.canInteract || !tournament.canParticipate

        configureViews()
        fetchLeaderboard() // getting all submissions for a tournament, ordered by votes
        fetchSubmissions() // getting all submissions for a tournament // first 50
        loadUserVotes()
    }
    
    @IBAction func segmentControlDidTap(_ sender: UISegmentedControl) {
        tableView.reloadData()
        
        if isSubmissionsSelected,  let currentCellPlayingIndexPath = currentCellPlayingIndexPath{
            currentCellPlaying?.playVideo(videoURL: submissions[currentCellPlayingIndexPath.row].videoURL)
         } else{
            currentCellPlaying?.stopVideo()
        }
    }
    
    // MARK: - TableView
    
    
    var isSubmissionsSelected: Bool{
        return submissionLeaderboardSegmentControl.selectedSegmentIndex == 0
    }
  
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isSubmissionsSelected{
           return nil
       }
        
        let header = tableView.dequeueReusableCell(withIdentifier: "HeaderCell")
        
       
        if section == 0{
            header?.textLabel?.text = "Top 3"
            
        } else{
            header?.textLabel?.text = "All Participants"
        }
            
        
        return header
    }
//
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return isSubmissionsSelected ? 0 : 30.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if isSubmissionsSelected{
//            return  (tableView.frame.height * 0.90)
//        } else{
//            return  (tableView.frame.height * 0.90) // put a different number for LeaderboardCell
//        }
       
        return isSubmissionsSelected ?  (tableView.frame.height * 0.90) : 110.0
    }
    
    
    
    // UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
//        if isSubmissionsSelected{
//            return  1
//        } else{
//            return 2
//        }
        
        return isSubmissionsSelected ? 1 : 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if isSubmissionsSelected{
            return submissions.count
        } else if !isSubmissionsSelected && section == 0{
            return min(3, leaderboardSubmissions.count)
        } else {
            return max(0, leaderboardSubmissions.count - 3)
        }
        
        
    }
    
    // [submission 0 , submission 1, submission 2, submission 3, submission 4, submission 5,  ]
    
    // TableView
    
    //  SUBMISSIONS
//    ------------------------
//    | UITableViewCell
//    | section: 0 , row: 0 --> indexPath
//    _______________________
//    | UITableViewCell
//    | section: 0 , row: 1
//    _______________________
//    | UITableViewCell
//    | section: 0 , row: 2
//    _______________________
//    | UITableViewCell
//    | section: 0 , row: 3
//    _______________________
//    | UITableViewCell
//    | section: 0 , row: 4
//    _______________________
    
    
    //  LEADERBOARD
//    ------------------------
//    | UITableViewCell
//    | section: 0 , row: 0 --> indexPath
//    _______________________
//    | UITableViewCell
//    | section: 0 , row: 1
//    _______________________
//    | UITableViewCell
//    | section: 0 , row: 2
//    _______________________
    
    
//    ------------------------
//    | UITableViewCell
//    | section: 1 , row: 0
//    _______________________
//    | UITableViewCell
//    | section: 1 , row: 1
//    _______________________
//    | UITableViewCell
//    | section: 1 , row: 2
//    _______________________
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        // Depending on which segment the user has selected on, return the appropriate cell
        if isSubmissionsSelected{
            startCompetingButton.isHidden = !tournament.canInteract || !tournament.canParticipate
            return generateSubmissionCell(indexPath)
        } else{
            startCompetingButton.isHidden = true
            return generateLeaderboardCell(indexPath)
        }
        
    }
    
    
    private func generateLeaderboardCell(_ indexPath: IndexPath) -> LeaderboardCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell") as! LeaderboardCell
       
        let position = indexPath.section == 0 ? indexPath.row :   indexPath.row  + 3
        let submission = leaderboardSubmissions[position]
        
        cell.updateUI(position: position, submission: submission)
        
        return cell
    }
    
    private func generateSubmissionCell(_ indexPath: IndexPath) -> SubmissionCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubmissionCell") as! SubmissionCell
        let submission = submissions[indexPath.row]
       
        cell.delegate = self
        cell.updateUI(submission: submission, canInteract: tournament.canInteract)

        
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
    
    func playVideo(url: URL) {
        let player = AVPlayer(url: url)
        let vc = AVPlayerViewController()
        vc.player = player
        present(vc, animated: true) { vc.player?.play() }
    }
    
    /// Additional UI modifications
    private func configureViews() {
        // set ui for leaderboard
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
            self.leaderboardSubmissions = submissions
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
                firstPlaceVotesLabel.text = "\(submission.votes)"
            }
            // second place
            if index == 1 {
                secondPlaceProfileImageView.kf.setImage(with: submission.creatorProfileImageURL)
                secondPlaceUsernameLabel.text = submission.creatorUsername
                secondPlaceVotesLabel.text = "\(submission.votes)"
            }
            // third place
            if index == 2 {
                thirdPlaceProfileImageView.kf.setImage(with: submission.creatorProfileImageURL)
                thirdlaceUsernameLabel.text = submission.creatorUsername
                thirdPlaceVotesLabel.text = "\(submission.votes)"
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
    
    /// Display text mesage controller to share link via text
    private func sendMessageWithURL(url: URL) {
        if MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()
            controller.body = "Start competing against me by uploading a video to the Tourney app. Accept this challenge by clicking the link \(url.absoluteString)"
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    /// Stop current cell video playback
    private func stopCurrentVideoPlayback() {
        if let currentCell = currentCellPlaying {
            currentCell.stopVideo()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if !isSubmissionsSelected{
            return
        }
        
        // handle video playing
        
        var mostVisiblePercentage: CGFloat = 0.0
        var newMostVisibleCandidate: SubmissionCell!
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
                    newMostVisibleCandidate = (tableView.cellForRow(at: item) as! SubmissionCell)
                    mostVisiblePercentage = ratio
                    indexPath = item
                    currentCellPlayingIndexPath = item
                }
            }
        }
        
        if (newMostVisibleCandidate != currentCellPlaying) {
            let submission = submissions[indexPath.row]
            // update cells video playback
            currentCellPlaying?.stopVideo()
            newMostVisibleCandidate.playVideo(videoURL: submission.videoURL)
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
        
        stopCurrentVideoPlayback()
        
        if segue.identifier == "toUploadVideoVC" {
            if let destination = segue.destination as? UploadVideo {
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
    func didUploadVideoForSubmission(submission: Submission) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.submissions.append(submission)
            let lastIndexPath = IndexPath(row: self.submissions.count - 1, section: 0)
            self.tableView.insertRows(at: [lastIndexPath], with: .none)
            self.tableView.endUpdates()
            self.tableView.scrollToRow(at: lastIndexPath, at: .top, animated: true)
        }
        fetchLeaderboard()
    }
}

extension FeedVC: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
extension FeedVC: SubmissionCellDelegate {
    func didPlayVideo(submissionId: String) {
        PostManager(tournament: tournament, submissionId: submissionId).addView()
    }
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
                        PostManager(tournament: self.tournament, submissionId: submissionId).removeVote {
                            // update leaderboard videos
                            self.fetchLeaderboard()
                        }
                        // update current vote (to reflect on cells)
                        self.submissionIdOfCurrentUserVote = nil
                    } else {
                        // remove vote from old post by decreasing the post.votes count
                        PostManager(tournament: self.tournament, submissionId: oldVotePostId).removeVote {}
                        // add new vote to post Id in post model
                        PostManager(tournament: self.tournament, submissionId: submissionId).addVote {
                            // update leaderboard videos
                            self.fetchLeaderboard()
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
                        PostManager(tournament: self.tournament, submissionId: submissionId).addVote {
                            // update leaderboard videos
                            self.fetchLeaderboard()
                        }
                        // update current vote (to reflect on cells)
                        self.submissionIdOfCurrentUserVote = submissionId
                        // update leaderboard videos
                        self.fetchLeaderboard()
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
