//
//  ChartSegmentedControlTableViewCell.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/11/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import UIKit

class ChartSegmentedControlTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: IBActions
    @IBAction func segmentedControlDidChange(_ sender: Any) {
        
    }
    
    
    // MARK: Properties
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
}
