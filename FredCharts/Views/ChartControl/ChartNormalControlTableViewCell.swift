//
//  ChartNormalControlTableViewCell.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/11/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import UIKit

class ChartNormalControlTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    @IBOutlet weak var attributeTitleLabel: UILabel!
    @IBOutlet weak var attributeValueLabel: UILabel!
}
