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
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var thumbsUpButton: UIButton!
    
    var post: Post!
    var userPostKey: DatabaseReference!
    let currentUser = KeychainWrapper.standard.string(forKey: "uid")
    let loadingIndicator = UIActivityIndicatorView(style: .large)
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
        setupVideoView()
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = videoView.layer.bounds
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                DispatchQueue.main.async {[weak self] in
                    if newStatus == .playing || newStatus == .paused {
                        self?.loadingIndicator.isHidden = true
                        self?.loadingIndicator.stopAnimating()
                    } else {
                        self?.loadingIndicator.isHidden = false
                        self?.loadingIndicator.startAnimating()
                    }
                }
            }
        }
    }
    
    /// Initial set up for video view
    private func setupVideoView() {
        
        // ui
        videoView.backgroundColor = UIColor.clear
        videoView.layer.cornerRadius = 15
        videoView.layer.masksToBounds = true
        videoView.layer.addSublayer(self.playerLayer)
        
        loadingIndicator.center = videoView.center
        loadingIndicator.color = .white
        videoView.addSubview(loadingIndicator)
                        
        // video ended notificaiton to loop video
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: nil,
                                               queue: nil) { [weak self] note in
            self?.player.seek(to: .zero)
            self?.player.play()
        }
        
        // check when buffering to show loading indicator
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        
        
        // bring views to the front to not be covered by player
        videoView.bringSubviewToFront(profileImageView)
        videoView.bringSubviewToFront(usernameLabel)
        videoView.bringSubviewToFront(viewsLabel)
        videoView.bringSubviewToFront(thumbsUpButton)
        videoView.bringSubviewToFront(loadingIndicator)
    }
    
    /// Initial set up for general UI
    private func setupUI() {
        thumbnailImageView.backgroundColor = UIColor.gray
        thumbnailImageView.layer.cornerRadius = 15
    }
    
    /// Stop playback of video
    func stopVideo() {
        player.replaceCurrentItem(with: nil)
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
    }
    
    /// Play video in cell using given URL
    func playVideo(videoURL: URL) {
        let playerItem = AVPlayerItem(url: videoURL)
        player.replaceCurrentItem(with: playerItem)
        player.automaticallyWaitsToMinimizeStalling = true
        player.play()
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
