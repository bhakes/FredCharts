//
//  PickerControlDelegate.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/13/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import Foundation

protocol PickerControlDelegate: AnyObject {
    func pickerStartDateSelected(with date: Date)
    
    func pickerEndDateSelected(with date: Date)
}
