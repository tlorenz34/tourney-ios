//
//  UploadChallengeVideoViewController.swift
//  Tourney
//
//  Created by German Espitia on 11/12/20.
//  Copyright © 2020 Will Cohen. All rights reserved.
//

import UIKit

class UploadChallengeVideoViewController: UploadVideo {
    
    @IBOutlet var uploadVideo: LoadingUIButton!
    
    @IBAction func uploadTapped() {
        guard let videoURL = videoURL else {
            showAlert(title: "Missing Video", message: "Please select a video to upload!")
            return
        }
        uploadVideo.showLoading()
        uploadFeaturedVideo(videoURL: videoURL)
    }
    
    var tournamentsViewController: TournamentsTableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    /**
     Uploads featured video to storage, updates `Tournament` object's `featuredVideoURL` property and dismisses view controller.
     */
    private func uploadFeaturedVideo(videoURL: NSURL) {
        // crop video
        cropVideo(sourceURL: videoURL as URL, startTime: startTime, endTime: endTime) { (croppedVideoURL) in
            // upload video
            self.uploadVideoToFeaturedVideosStorage(url: croppedVideoURL) { (uploadedVideoURL) in
                if let uploadedVideoURL = uploadedVideoURL {
                    self.uploadVideo.hideLoading()
                    // update tournament with featured video
                    self.tournament.featuredVideoURL = uploadedVideoURL as URL
                    TournamentManager().save(self.tournament)
                    // update tournament tablevc tournament object with new updated object (makes it so that when user dismisses, they automatically can tap on tournament to view challenge video)
                    self.replaceTournament(tournament: self.tournament)
                    self.tournamentsViewController.tableView.reloadData()
                    // dismiss nav controller
                    self.navigationController?.dismiss(animated: true, completion: nil)
                } else {
                    self.uploadVideo.hideLoading()
                    self.showAlert(title: "Error", message: "There was an error uploading your challenge video. Please try again.")
                }
            }
        }
    }
    /// Replaces a tournament with passed tournament
    private func replaceTournament(tournament: Tournament) {
        if let index = tournamentsViewController.tournaments.firstIndex(where: { $0.id == tournament.id }) {
            self.tournamentsViewController.tournaments[index] = tournament
        }
    }
    

}
