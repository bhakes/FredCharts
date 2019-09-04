//
//  AppDelegate.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/9/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupViews()
        Appearance.setupNavAppearance()
        Appearance.setupSegmentedControlAppearance()
        return true
    }
    
    private func setupViews() {
        
        // Make the View Controllers
        let navController = UINavigationController()
        let favoritesVC = FavoritesTableViewController()
        navController.viewControllers = [favoritesVC]
        
        
        // Set up the window
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navController
        
        window?.makeKeyAndVisible()
    }

}

