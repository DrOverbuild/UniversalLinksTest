//
//  ImageTableViewCell.swift
//  UniversalLinksTest
//
//  Created by Jasper on 7/24/19.
//  Copyright © 2019 Jasper. All rights reserved.
//

import UIKit
import Firebase

class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var mainImageView: UIImageView!
    
    var labels: [VisionImageLabel]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
