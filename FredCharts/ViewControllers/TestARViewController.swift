//
//  TestARViewController.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/13/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//
m
import UIKit

class TestARViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func dismissButtonClicked(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    

}
