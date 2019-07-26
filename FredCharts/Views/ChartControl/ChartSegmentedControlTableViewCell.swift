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
    @IBAction func segmentedControlDidChange(_ sender: UISegmentedControl) {
//        swit segmentControl.selectedSegmentIndex
        switch segmentControl.selectedSegmentIndex  {
        case 0:
            delegate?.segmentedControlDidChange(with: nil)
        case 1:
            delegate?.segmentedControlDidChange(with: 10)
        case 2:
            delegate?.segmentedControlDidChange(with: 5)
        case 3:
            delegate?.segmentedControlDidChange(with: 1)
        case 4:
            delegate?.segmentedControlDidChange(with: 0)

        default:
            delegate?.segmentedControlDidChange(with: nil)
        }
    }
    
    
    // MARK: Properties
    @IBOutlet weak var segmentControl: UISegmentedControl!
    weak var delegate: ChartSegementedControlDelegate?
}
