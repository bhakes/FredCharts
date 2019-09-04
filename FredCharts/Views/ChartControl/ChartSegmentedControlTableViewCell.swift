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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        updateViews()
        
        segmentControl.addTarget(self, action: #selector(segmentedControlDidChange), for:.valueChanged)
        segmentControl.addTarget(self, action: #selector(segmentedControlDidChange), for:.touchUpInside)
    }
    
    // MARK: IBActions
    @objc func segmentedControlDidChange(_ sender: UISegmentedControl) {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackGenerator.prepare()
        impactFeedbackGenerator.impactOccurred()
        
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
    
    // MARK: - Private Methods
    private func updateViews() {
        segmentControl.constrainToSuperView(self, safeArea: true, leading: 20, trailing: 20, centerX: 0)
    }
    
    // MARK: - Properties
    lazy var segmentControl: UISegmentedControl = {
        let scItems = ["All", "10Y", "5Y", "1Y", "6M"]
        let sc = UISegmentedControl(items: scItems)
        sc.selectedSegmentIndex = 3
        
        return sc
    }()
    weak var delegate: ChartSegementedControlDelegate?
}
