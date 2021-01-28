//
//  UploadChallengeVideoViewController.swift
//  Tourney
//
//  Created by German Espitia on 11/12/20.
//  Copyright © 2020 Will Cohen. All rights reserved.
//

import UIKit

class UploadChallengeVideoViewController: UploadVideo {
    
    @IBOutlet var textFieldName: UITextField!
    @IBOutlet var uploadVideo: LoadingUIButton!
    @IBOutlet var labelPreview: UILabel!
    
    @IBAction func uploadTapped() {
        guard let videoURL = videoURL else {
            showAlert(title: "Missing Video", message: "Please select a video to upload!")
            return
        }
        uploadVideo.showLoading()
        uploadFeaturedVideo(videoURL: videoURL)
    }
    
    var tournamentsViewController: TournamentsTableViewController!
    
    @IBAction func textFieldNameChanged(_ sender: UITextField) {
        labelPreview.text = "Preview: \(sender.text ?? "") Challenge"
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
                    // update tournament and its parent
                    self.updateChildAndParentTournament(challengeVideoURL: uploadedVideoURL as URL)                    
                    // update tournament tablevc data source
                    self.updateDataSource(tournament: self.tournament)
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
    
    /// Updates child tournament to become active and disables parent tournamnet to become inactive.
    func updateChildAndParentTournament(challengeVideoURL: URL) {
        
        let tournamentManager = TournamentManager()
        
        tournament.featuredVideoURL = challengeVideoURL
        tournament.canInteract = true
        tournament.active = true
        if !textFieldName.text.isNilOrEmpty {
            tournament.name = textFieldName.text!
        }
        tournament.challengeType = .public
        tournamentManager.save(tournament)
        
        if let parentTournamentId = tournament.parentTournamentId,
           var parentTournament = tournamentsViewController.tournaments.first(where: { $0.id == parentTournamentId }) {
            parentTournament.active = false
            tournamentManager.save(parentTournament)
        }
    }
    /// Update `tournamentsViewController` data source
    private func updateDataSource(tournament: Tournament) {
        // switch new tournament for updated new tournament (now with `featuredVideoURL` property)
        if let index = tournamentsViewController.tournaments.firstIndex(where: { $0.id == tournament.id }) {
            self.tournamentsViewController.tournaments[index] = tournament
        }
        // remove old video (parent tournament is not inactive)
        if let parentTournamentId = tournament.parentTournamentId {
            tournamentsViewController.tournaments.removeAll(where: {
                $0.id == parentTournamentId
            })
            tournamentsViewController.tableView.reloadData()
        }
    }
    

extension UploadChallengeVideoViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 8
   }
}
