//
//  FavoritesTableViewCell.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 6/11/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        updateViews()
        
    }
    
    // MARK: - Private Methods
    private func updateViews(){
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
    
    }
    
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var lastObservationValueLabel: UILabel!
    @IBOutlet weak var previousObservationValueLabel: UILabel!
    @IBOutlet weak var unitsLabel: UILabel!
    @IBOutlet weak var lastDateLabel: UILabel!
    @IBOutlet weak var prevDateLabel: UILabel!
    
    // MARK: - Properties
    var deleteLabel1: UILabel!
    var deleteLabel2: UILabel!
    
    var series: FredSeriesS?
    
    
}
