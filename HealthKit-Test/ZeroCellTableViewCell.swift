//
//  ZeroCellTableViewCell.swift
//  HealthKit-Test
//
//  Created by Steve on 05/12/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import UIKit

class ZeroCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var item1Label: UILabel!
    @IBOutlet weak var item2Label: UILabel!
    @IBOutlet weak var item3Label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
