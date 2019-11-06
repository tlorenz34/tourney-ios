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
    
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var postVideo: UIView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    var post: Post!
    var userPostKey: DatabaseReference!
    let currentUser = KeychainWrapper.standard.string(forKey: "uid")
    
    var viewed: Bool = false;
    
    private lazy var player: AVPlayer = AVPlayer(playerItem: nil)
    
    private lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer(player: self.player)
        playerLayer.videoGravity = .resizeAspectFill
        return playerLayer
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.postVideo.backgroundColor = UIColor.clear
        self.postVideo.isHidden = true
        self.postVideo.layer.addSublayer(self.playerLayer)
        player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
        thumbnailImageView.backgroundColor = UIColor.gray
        userImg.layer.cornerRadius = userImg.frame.height / 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = postVideo.layer.bounds
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
        
        // NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { [weak self] _ in
        //     self?.player.seek(to: CMTime.zero)
        //     self?.player.play()
        //}
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
            thumbnailImageView.image = thumbnail
        } else {
            thumbnailImageView.backgroundColor = UIColor.gray
        }
    }
    
    
    func configCell(post: Post, img: UIImage? = nil, userImg: UIImage? = nil) {
        
        postVideo.backgroundColor = UIColor.clear
        self.post = post
        self.likesLbl.text = "\(post.views)"
        self.username.text = post.username
        updateViewsInDatabase();
        self.userImg.kf.setImage(with: URL(string: post.userImg))
        
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
        let views = likesLbl.text!
        likesLbl.text = "\((Int(views)! + 1))"
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        print("button")
        
    }
    

    
}
