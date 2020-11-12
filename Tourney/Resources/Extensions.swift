//
//  Extensions.swift
//  Tourney
//
//  Created by German Espitia on 10/20/20.
//  Copyright © 2020 Will Cohen. All rights reserved.
//

import Foundation
import UIKit

extension Collection where Indices.Iterator.Element == Index {
    subscript (exist index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
    }
    /// Presents the WinnerFlow storyboard to take user through the uploading challenge video flow.
    func presentWinnerFlowStoryboard(tournament: Tournament, tournamentsViewController: TournamentsTableViewController) {
        let storyboard = UIStoryboard(name: "WinnerFlow", bundle: .main)
        if let navController = storyboard.instantiateInitialViewController() as? UINavigationController,
           let congratulationsViewController = navController.viewControllers.first as? CongratulationsViewController {
            congratulationsViewController.tournamentsViewController = tournamentsViewController
            congratulationsViewController.tournament = tournament
            present(navController, animated: true, completion: nil)
        }
    }
}
