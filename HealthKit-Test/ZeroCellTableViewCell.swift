//
//  ZeroCellTableViewCell.swift
//  HealthKit-Test
//
//  Created by Steve on 05/12/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import UIKit
import Charts

class ZeroCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var barChartView: BarChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
