//
//  Posts.swift
//  goldcoastleague
//
//  Created by Thaddeus Lorenz on 5/29/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//


// Every video that is uploaded contains these attributes
import Foundation
import FirebaseAnalytics
import FirebaseDatabase
import Firebase
import AVKit
import UIKit

class Post  {
    
    private var _username: String!
    private var _userImg: String!
    private var _postImg: String!
    private var _views: Int!
    private var _postKey: String!
    var _videoLink: String!
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
    var votes: Int
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
        votes = 0
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
        if let votes = postData["votes"] as? Int {
            self.votes = votes
        } else {
            votes = 0
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
/**
 Class to manage networking aspects of the Post model
 */
class PostManager {
    
    var id: String
    let db = Firestore.firestore()
    var submissionRef: DocumentReference {
        db.collection("submissions").document(id)
    }
    
    init(submissionId: String) {
        id = submissionId
    }
    
    /// Increments `votes` field by `1`
    public func addVote(completion: @escaping () -> Void) {
        addToVote(amount: 1) {
            completion()
        }
    }
    /// Decreases `votes` field by `1`
    public func removeVote(completion: @escaping () -> Void) {
        addToVote(amount: -1) {
            completion()
        }
    }
    /// Increases `views` field by `1`
    public func addView() {
        submissionRef.updateData([
            "views": FieldValue.increment(Int64(1))
        ])        
    }
    /**
     Add amount to `votes` field of Post object
     */
    private func addToVote(amount: Int, completion: @escaping () -> Void) {
        submissionRef.updateData([
            "votes": FieldValue.increment(Int64(amount))
        ])
        completion()
    }
    
}
