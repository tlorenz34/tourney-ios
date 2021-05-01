//
//  startCompetingButton.swift
//  Tourney
//
//  Created by Thaddeus Lorenz on 4/3/21.
//  Copyright © 2021 Will Cohen. All rights reserved.
//

import UIKit

class startCompetingButton: UIButton {

    var selectedState: Bool = false

        override func awakeFromNib() {
            super.awakeFromNib()
            layer.borderWidth = 2 / UIScreen.main.nativeScale
            layer.borderColor = UIColor.blue.cgColor
            contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        }


        override func layoutSubviews(){
            super.layoutSubviews()
            layer.cornerRadius = frame.height / 2
            backgroundColor = selectedState ? UIColor.blue : UIColor.blue
            self.titleLabel?.textColor = selectedState ? UIColor.white : UIColor.white
        }

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            selectedState = !selectedState
            self.layoutSubviews()
        }

}
