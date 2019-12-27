//
//  PostCell.swift
//  goldcoastleague
//
//  Created by Thaddeus Lorenz on 5/29/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import SwiftKeychainWrapper
import AVKit
import Kingfisher

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var postVideo: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    var post: Post!
    var userPostKey: DatabaseReference!
    let currentUser = KeychainWrapper.standard.string(forKey: "uid")
    let loadingIndicator = UIActivityIndicatorView(style: .white)
    
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
        
        // add loading indicator
        addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
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
    
    func playvid(url: String) {
        
        let playerItem = AVPlayerItem(url: URL(string: post.videoLink)!)
        player.replaceCurrentItem(with: playerItem)
        player.automaticallyWaitsToMinimizeStalling = true
        self.player.play()
        
        // bring views to the front to not be covered by player
        postVideo.bringSubviewToFront(profileImageView)
        postVideo.bringSubviewToFront(usernameLabel)
        postVideo.bringSubviewToFront(viewsLabel)
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
        updateViewsInDatabase();
        profileImageView.kf.setImage(with: URL(string: post.userImg))
        
    }
    
    func updateViewsInDatabase() {
        let postRef = Database.database().reference().child("posts").child(post.postKey).child("views")
        postRef.runTransactionBlock( { (currentData: MutableData) -> TransactionResult in
            
            var currentCount = currentData.value as? Int ?? 0
            currentCount += 1
            currentData.value = currentCount
            
            return TransactionResult.success(withValue: currentData)
        })
    }
    
    func updateLikesInUI(like: Bool) {
        let views = viewsLabel.text!
        viewsLabel.text = "\((Int(views)! + 1)) views"
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        print("button")
        
    }
    

    
}
