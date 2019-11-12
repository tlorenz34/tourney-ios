//
//  CustomCell.swift
//  goldcoastleague
//
//  Created by Thaddeus Lorenz on 7/3/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//

import Foundation
import UIKit

class CustomCell: UITableViewCell {
    
    var message : String?
    var mainImage : UIImage?
    
    var messageView : UITextView = {
        var textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        return textView
    }()
    
    var mainImageView : UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
        
    }()
    var opaqueView: UIView = {
       let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.25
        return view
    }()
    var titleLabel: UILabel = {
        var height = 60
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: height))
        label.font = UIFont.boldSystemFont(ofSize: CGFloat(height))
        label.textColor = .white
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // add components
        addSubview(mainImageView)
        addSubview(opaqueView)
        addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let message = message {
            messageView.text = message
        }
        if let image = mainImage {
            mainImageView.image = image
        }
        
        // update frames for components within competitions cells to match tableview frame
        mainImageView.frame = CGRect(x: 0, y: 0, width: super.frame.width, height: super.frame.height)
        opaqueView.frame = mainImageView.frame
        titleLabel.frame = CGRect(x: 20, y: 400 - titleLabel.frame.height - 20, width: super.frame.width, height: titleLabel.frame.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return false
    }
    
}
