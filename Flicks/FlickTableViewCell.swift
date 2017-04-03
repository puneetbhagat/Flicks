//
//  FlickTableViewCell.swift
//  Flicks
//
//  Created by Bhagat, Puneet on 4/2/17.
//  Copyright © 2017 Puneet Bhagat. All rights reserved.
//

import UIKit

class FlickTableViewCell: UITableViewCell {

    var flickImageUrlString: String = ""
    @IBOutlet weak var flickImageView: UIImageView!
    @IBOutlet weak var flickTitleLabel: UILabel!
    @IBOutlet weak var flickDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
