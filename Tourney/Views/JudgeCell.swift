//
//  JudgeCell.swift
//  Tourney
//
//  Created by Thaddeus Lorenz on 4/27/21.
//  Copyright © 2021 Will Cohen. All rights reserved.
//

import UIKit
import Kingfisher

class JudgeCell: UITableViewCell {

    @IBOutlet weak var judgeProfilePicture: UIImageView!
   
    @IBOutlet weak var judgeName: UILabel!
    
    
    func updateUI (judge: User?){
        guard let  judge = judge else {
            judgeName.text = "Public Vote"
            // TODO: - Thaddues
//            judgeProfilePicture.image = UIImage(named: "")
            return
        }
        
        judgeName.text = judge.username
        if let imageUrl = judge.profileImageURL{
            judgeProfilePicture.kf.setImage(with: URL(string: imageUrl)!)
        }
        
        
    }

}
