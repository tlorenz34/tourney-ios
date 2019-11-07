//
//  TableViewController.swift
//  goldcoastleague
//
//  Created by Thaddeus Lorenz on 7/3/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//

import UIKit

struct CellData {
    
    let image: UIImage?
    let message: String?
    let filter: String?
    
}

class TableViewController: UITableViewController {
    
    var data = [CellData]()
    var selectedFilter: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        data = [CellData(image: UIImage(named: "BMX_Competition_1"), message: "BMX #1", filter: "BMX_Competition_1"),
                CellData(image: UIImage(named: "BMX_Competition_2"), message: "BMX #2", filter: "BMX_Competition_2")]
        self.tableView.register(CustomCell.self, forCellReuseIdentifier: "custom")
        self.tableView.rowHeight = UITableView.automaticDimension
        // used to be 200
        self.tableView.estimatedRowHeight = 400
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "custom") as! CustomCell
        cell.mainImage = data[indexPath.row].image
        cell.titleLabel.text = data[indexPath.row].message
        cell.layoutSubviews()
        return cell
        
    }
    
 
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFilter = data[indexPath.row].filter!
        self.performSegue(withIdentifier: "toVideoFeed", sender: nil)
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toVideoFeed" {
            if let destination = segue.destination as? FeedVC {
                User.sharedInstance.activeFilter = self.selectedFilter
                destination.activeFilter = self.selectedFilter
            }
        }
    }
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return false
    }

}
