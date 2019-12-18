//
//  Posts.swift
//  goldcoastleague
//
//  Created by Thaddeus Lorenz on 5/29/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//

import Foundation

import FirebaseAnalytics
import FirebaseDatabase
import AVKit
import UIKit

class Post  {
    
    private var _username: String!
    private var _userImg: String!
    private var _postImg: String!
    private var _views: Int!
    private var _postKey: String!
    private var _videoLink: String!
    private var _postRef: DatabaseReference!
    var thumbnail: UIImage!
    
    private var _downloadedURL: URL!

    var downloadedURL: URL {
        get {
            return _downloadedURL
        } set{
            _downloadedURL = newValue
        }
    }
    var username: String {
        return _username
    }
    var userImg: String {
        return _userImg
    }
    var videoLink: String {
        return _videoLink
    }
    var postImg: String{
        get {
            return _postImg
        } set{
            _postImg = newValue
        }
    }
    var views: Int {
        return _views
    }
    /// Views as a string with commas. Turns 120442 into "120,442"
    var formattedViews: String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf.string(from: NSNumber(integerLiteral: _views))!
    }
    var postKey: String {
        return _postKey
    }
    
   /* var downloadedURL: URL {
        get {
            return _downloadedURL
        } set{
            _downloadedURL = newValue
        }
    }*/
    
    init(imgUrl: String, views: Int, username: String, userImg: String, videoLink: String) {
        _views = views
        _postImg = imgUrl
        _username = username
        _userImg = userImg
        _videoLink = videoLink
    }
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        _postKey = postKey
        
        if let username = postData["username"] as? String{
            _username = username
        }
        if let userImg = postData["profileImage"] as? String{
            _userImg = userImg
        }
        if let postImage = postData[""] as? String{
            _postImg = postImage
        }
        if let views = postData["views"] as? Int{
            _views = views
        }
        
        if let videoLink = postData["videoURL"] as? String {
            _videoLink = videoLink
        }
        
        _postRef = Database.database().reference().child("posts").child(_postKey)
        
        
    }
    func adjustViews(addView: Bool){
        if addView {
            _views = views + 1
        } else {
            _views = views - 1
            
        }
        _postRef.child("views").setValue(_views)
        
    }
}
