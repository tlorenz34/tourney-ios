//
//  FeaturedChannelsTableViewController.swift
//  Tourney
//
//  Created by Hakan Eren on 9.02.2021.
//  Copyright © 2021 Will Cohen. All rights reserved.
//

import UIKit

class FeaturedChannelsTableViewController: UITableViewController {
    
    var dynamicLinkTourneyId: String?
    
    enum Selection: Equatable {
        case all
        case filtered(Filter)
        
        static func ==(lhs: Selection, rhs: Selection) -> Bool {
            switch (lhs, rhs) {
            case (.all, .all):
                return true
            case let (.filtered(leftFilter), .filtered(rightFilter)):
                return leftFilter.id == rightFilter.id
            default:
                return false
            }
        }
    }
    
    var filters: [Filter] = []
    var channels: [Channel] = []
    var filteredChannels: [Channel] { channels.filter { channel -> Bool in
        switch selectedFilter {
        case .all:
            return true
        case let .filtered(filter):
            return channel.filters.contains(filter.id)
        }
    } }
    
    var selectedFilter: Selection = .all {
        didSet {
            if selectedFilter != oldValue {
                tableView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func profileButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toProfile", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchFilters()
        fetchChannels()
    }
    
    func fetchFilters() {
        FilterManager().fetchFilters { filters in
            if let filters = filters {
                self.filters = filters.sorted(by: { $0.name < $1.name })
                self.collectionView.reloadData()
                self.collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .init())
            }
        }
        collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .init())
    }
    
    func fetchChannels() {
        ChannelManager().fetchFeaturedChannels { channels in
            if let channels = channels {
                self.channels = channels
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source / delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredChannels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell", for: indexPath) as! ChannelTableViewCell
        let channel = filteredChannels[indexPath.row]
        
        cell.backgroundImageView.kf.setImage(with: channel.coverImageURL)
        cell.bannerView.isHidden = !channel.isLive
        cell.titleLabel.text = channel.name
        cell.descriptionLabel.text = channel.desc

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toTournaments", sender: filteredChannels[indexPath.row].id)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toTournaments":
            if let tournamentsVC = segue.destination as? TournamentsTableViewController, let channelId = sender as? String {
                tournamentsVC.channelId = channelId
            }
        case "toProfile":
            break
        default:
            break
        }
    }

}

extension FeaturedChannelsTableViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TabCell", for: indexPath) as! TabCollectionViewCell
        
        if indexPath.row == 0 {
            cell.titleLabel.text = "All"
        } else {
            cell.titleLabel.text = filters[indexPath.row - 1].name
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            selectedFilter = .all
        } else {
            selectedFilter = .filtered(filters[indexPath.row - 1])
        }
    }
    
}
