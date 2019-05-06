//
//  FetchRecentDataOperation.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 5/2/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import UIKit

class FetchRecentDataOperation: ConcurrentOperation {
    
    init(series: FredSeriesS, url: URL, session: URLSession = URLSession.shared) {
        self.series = series
        self.session = session
        self.url = url
        super.init()
        
    }
    
    override func start() {
        state = .isExecuting
        guard let url = url else { return }
        
        let task = session.dataTask(with: url) { (data, response, error) in
            defer { self.state = .isFinished }
            if self.isCancelled { return }
            if let error = error {
                NSLog("Error fetching data for \(self.series): \(error)")
                return
            }
            
            if let data = data {
//                self.image = UIImage(data: data)
            }
        }
        task.resume()
        dataTask = task
    }
    
    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
    
    // MARK: Properties
    
    var series: FredSeriesS
    private var session: URLSession
    private var url: URL?
    private var dataTask: URLSessionDataTask?
}
