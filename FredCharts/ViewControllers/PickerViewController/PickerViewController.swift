//
//  PickerViewController.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/13/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let startDate = startDate else { fatalError("Should have passed startDate but startDate is not available")}
        guard let endDate = endDate else { fatalError("Should have passed startDate but startDate is not available")}
        if startFlag == true {
            
            datePicker.date = startDate
            
        } else {
            
            datePicker.date = endDate
        }
        
        containerView.layer.cornerRadius = 30
        containerView.clipsToBounds = true
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowRadius = 2.0
        selectButton.layer.cornerRadius = 16
        cancelButton.layer.cornerRadius = 16
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    @IBAction func selectButtonTapped(_ sender: Any) {
        if startFlag == true {
            delegate?.pickerStartDateSelected(with: datePicker.date)
        } else {
            delegate?.pickerEndDateSelected(with: datePicker.date)
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var delegate: PickerControlDelegate?
    var startFlag: Bool = true
    var startDate: Date?
    var endDate: Date?
}
