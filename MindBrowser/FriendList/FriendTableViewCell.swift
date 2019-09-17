//
//  FriendTableViewCell.swift
//  MindBrowser
//
//  Created by Apple on 15/09/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {
   
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var backview: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backview.layer.shadowColor = UIColor.black.cgColor
        self.backview.layer.shadowOpacity = 1
        self.backview.layer.shadowOffset = .zero
        self.backview.layer.shadowRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
