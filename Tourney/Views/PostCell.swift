//
//  PostCell.swift
//  goldcoastleague
//
//  Created by Thaddeus Lorenz on 5/29/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.

// This class defines how each individual video within FeedVC is configured in terms of design
// and functionality

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import SwiftKeychainWrapper
import AVKit
import Kingfisher

protocol PostCellDelegate: class {
    func didVoteForPost(postId: String)
}

class PostCell: UITableViewCell {
    
    @IBAction func didTapThumbsUp() {
        // if state = not vote
        if thumbsUpButton.titleLabel!.text == "Vote" {
            // update ui
            updateUIForVotingButton(voted: true)
        } else {
            updateUIForVotingButton(voted: false)
        }
        // notify controllers of action
        delegate?.didVoteForPost(postId: post.postKey)
    }
    
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var postVideo: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var thumbsUpButton: UIButton!
    
    var post: Post!
    var userPostKey: DatabaseReference!
    let currentUser = KeychainWrapper.standard.string(forKey: "uid")
    let loadingIndicator = UIActivityIndicatorView(style: .white)
    var isVotedFor: Bool = false {
        didSet {
            if self.isVotedFor {
                updateUIForVotingButton(voted: true)
            } else {
                updateUIForVotingButton(voted: false)
            }
        }
    }
    weak var delegate: PostCellDelegate?
    
    var viewed: Bool = false;
    
    private lazy var player: AVPlayer = AVPlayer(playerItem: nil)
    
    private lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer(player: self.player)
        playerLayer.videoGravity = .resizeAspectFill
        return playerLayer
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        postVideo.backgroundColor = UIColor.clear
        postVideo.isHidden = true
        postVideo.layer.cornerRadius = 15
        postVideo.layer.masksToBounds = true
        postVideo.layer.addSublayer(self.playerLayer)
        player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
        thumbnailImageView.backgroundColor = UIColor.gray
        thumbnailImageView.layer.cornerRadius = 15
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = postVideo.layer.bounds
        loadingIndicator.frame = bounds

    }
    
    func stopvid() {
        postVideo.isHidden = true
        updateThumbnail()
        player.replaceCurrentItem(with: nil)
        thumbnailImageView.isHidden = false
    }
    
    func playvid(videoURL: URL) {
        
        let playerItem = AVPlayerItem(url: videoURL)
        player.replaceCurrentItem(with: playerItem)
        player.automaticallyWaitsToMinimizeStalling = true
        self.player.play()
        
        // bring views to the front to not be covered by player
        postVideo.bringSubviewToFront(profileImageView)
        postVideo.bringSubviewToFront(usernameLabel)
        postVideo.bringSubviewToFront(viewsLabel)
        postVideo.bringSubviewToFront(thumbsUpButton)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate" {
            if player.rate > 0 {
                print("here we set it")
                self.postVideo.isHidden = false
            }
        }
    }
    
    func updateThumbnail() {
        if let thumbnail = post.thumbnail {
            
            // once thumbnail is set, replace loading indicator with thumbnail
            loadingIndicator.stopAnimating()
            
            thumbnailImageView.image = thumbnail
        } else {
            thumbnailImageView.backgroundColor = UIColor.gray
        }
    }
    
    
    func configCell(post: Post, img: UIImage? = nil, userImg: UIImage? = nil) {
        
        postVideo.backgroundColor = UIColor.clear
        self.post = post
        viewsLabel.text = "\(post.views) views"
        usernameLabel.text = post.username
        updateViewsInDatabase()
        profileImageView.kf.setImage(with: URL(string: post.userImg))
        
        // add loading indicator
        addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        
    }
    
    func updateViewsInDatabase() {
      
            
        
        let postRef = Database.database().reference().child("posts").child(post.postKey).child("views")
        postRef.runTransactionBlock( { (currentData: MutableData) -> TransactionResult in
            
            var currentCount = currentData.value as? Int ?? 0
            currentCount +=  1
            currentData.value = currentCount
            
            return TransactionResult.success(withValue: currentData)
        })
        }
    
    func updateLikesInUI(like: Bool) {
        let views = viewsLabel.text!
        viewsLabel.text = "\((Int(views)! + 1)) views"
    }
    /**
     Update UI of voting button to reflect state of vote
     */
    private func updateUIForVotingButton(voted: Bool) {
        if voted {
            thumbsUpButton.setTitle("Voted", for: .normal)
            thumbsUpButton.backgroundColor = UIColor.link
            thumbsUpButton.setTitleColor(UIColor.white, for: .normal)
        } else {
            thumbsUpButton.setTitle("Vote", for: .normal)
            thumbsUpButton.backgroundColor = UIColor.white
            thumbsUpButton.setTitleColor(UIColor.link, for: .normal)
        }
    }
}
