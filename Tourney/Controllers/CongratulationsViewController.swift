//
//  CongratulationsViewController.swift
//  
//
//  Created by German Espitia on 11/11/20.
//

import Foundation
import UIKit

class CongratulationsViewController: UIViewController {
    
    var tournament: Tournament!
    var tournamentsViewController: TournamentsViewController!
    
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var uploadChallengeButton: UIButton!
    
    override func viewDidLoad() {        
        // set description label
        descriptionLabel.text = "You've won the \n\(tournament.name) tournament"
        // confetti
        let confettiView = SAConfettiView(frame: view.frame)
        confettiView.intensity = 1.0
        view.insertSubview(confettiView, belowSubview: uploadChallengeButton)
        confettiView.startConfetti()
        // haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        // stop confetti
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            confettiView.stopConfetti()
        })
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UploadChallengeVideoViewController" {
            let destination = segue.destination as! UploadChallengeVideoViewController
            destination.tournament = tournament
            destination.tournamentsViewController = tournamentsViewController
        }
    }
}
