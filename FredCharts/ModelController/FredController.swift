//
//  FredController.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/9/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import Foundation

class FredController {
    
    // to be refactored later
    let baseURL = "https://api.stlouisfed.org/fred/series"
    let apiKey = Keys.apiKey
    var searchResults: [FredSeriesSRepresentation] = []
    
    // Add the completion last
    func searchForFredSeries(with searchTerm: String, completion: @escaping ([FredSeriesSRepresentation]?, Error?) -> Void) {
        
        // Establish the base url for our search
        guard let baseURL = URL(string: "\(baseURL)/search")
            else {
                fatalError("Unable to construct baseURL")
        }
        
        // Decompose it into its components
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            fatalError("Unable to resolve baseURL to components")
        }
        
        // Create the query item using `search` and the search term
        let searchQueryItem1 = URLQueryItem(name: "search_text", value: searchTerm)
        let searchQueryItem2 = URLQueryItem(name: "api_key", value: apiKey)
        let searchQueryItem3 = URLQueryItem(name: "file_type", value: "json")
        
        
        // Add in the search term
        urlComponents.queryItems = [searchQueryItem1, searchQueryItem2, searchQueryItem3]
        
        // Recompose all those individual components back into a fully
        // realized search URL
        guard let searchURL = urlComponents.url else {
            NSLog("Error constructing search URL for \(searchTerm)")
            completion(nil, NSError())
            return
        }
        
        // Create a GET request
        var request = URLRequest(url: searchURL)
        request.httpMethod = "GET" // basically "READ"
        
        // Asynchronously fetch data
        // Once the fetch completes, it calls its handler either with data
        // (if available) _or_ with an error (if one happened)
        // There's also a URL Response but we're going to ignore it
        let dataTask = URLSession.shared.dataTask(with: request) {
            // This closure is sent three parameters:
            data, _, error in
            
            // Rehydrate our data by unwrapping it
            guard error == nil, let data = data else {
                if let error = error { // this will always succeed
                    NSLog("Error fetching data: \(error)")
                    completion(nil, error) // we know that error is non-nil
                }
                return
            }
            
            // We know now we have no error *and* we have data to work with
            
            // Convert the data to JSON
            // We need to convert snake_case decoding to camelCase
            // Oddly there is no kebab-case equivalent
            // Note issues with naming and show similar thing
            // For example: https://github.com/erica/AssetCatalog/blob/master/AssetCatalog%2BImageSet.swift#L295
            // See https://randomuser.me for future
            do {
                // Declare, customize, use the decoder
                let jsonDecoder = JSONDecoder()
                
                let results = try jsonDecoder.decode(FredSearchSearchResults.self, from: data)
                
                self.searchResults = results.seriess
                
                // Send back the results to the completion handler
                completion(results.seriess, nil)
                
            } catch {
                NSLog("Unable to decode data into search: \(error)")
                completion(nil, error)
                //        return
            }
        }
        
        // A data task needs to be run. To start it, you call `resume`.
        // "Newly-initialized tasks begin in a suspended state, so you need to call this method to start the task."
        dataTask.resume()
    }
    
    // Add the completion last
    func getObservationsForFredSeries(with seriesID: String, descendingSortOrder: Bool? = false, observationCount: Int? = nil, completion: @escaping (Observations?, Error?) -> Void) {
        
        // Establish the base url for our search
        guard let baseURL = URL(string: "\(baseURL)/observations")
            else {
                fatalError("Unable to construct baseURL")
        }
        
        // Decompose it into its components
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            fatalError("Unable to resolve baseURL to components")
        }
        
        // Create the query item using `search` and the search term
        let searchQueryItem1 = URLQueryItem(name: "series_id", value: seriesID)
        let searchQueryItem2 = URLQueryItem(name: "api_key", value: apiKey)
        let searchQueryItem3 = URLQueryItem(name: "file_type", value: "json")
        
        // Add in the search term
        urlComponents.queryItems = [searchQueryItem1, searchQueryItem2, searchQueryItem3]
        
        if let observationCount = observationCount {
            let searchQueryItem4 = URLQueryItem(name: "limit", value: "\(observationCount)")
            urlComponents.queryItems?.append(searchQueryItem4)
        }
        
        if let descendingSortOrder = descendingSortOrder {
            if descendingSortOrder {
                let searchQueryItem5 = URLQueryItem(name: "sort_order", value: "desc")
                urlComponents.queryItems?.append(searchQueryItem5)
            }
            
        }
        
        // Recompose all those individual components back into a fully
        // realized search URL
        guard let searchURL = urlComponents.url else {
            NSLog("Error constructing search URL for \(seriesID)")
            completion(nil, NSError())
            return
        }
        
        // Create a GET request
        var request = URLRequest(url: searchURL)
        request.httpMethod = "GET" // basically "READ"
        
        // Asynchronously fetch data
        // Once the fetch completes, it calls its handler either with data
        // (if available) _or_ with an error (if one happened)
        // There's also a URL Response but we're going to ignore it
        let dataTask = URLSession.shared.dataTask(with: request) {
            // This closure is sent three parameters:
            data, _, error in
            
            // Rehydrate our data by unwrapping it
            guard error == nil, let data = data else {
                if let error = error { // this will always succeed
                    NSLog("Error fetching data: \(error)")
                    completion(nil, error) // we know that error is non-nil
                }
                return
            }
            
            // We know now we have no error *and* we have data to work with
            
            // Convert the data to JSON
            do {
                // Declare, customize, use the decoder
                let jsonDecoder = JSONDecoder()
                
                let results = try jsonDecoder.decode(Observations.self, from: data)
                
                // Send back the results to the completion handler
                completion(results, nil)
                
            } catch {
                NSLog("Unable to decode data into series: \(error)")
                completion(nil, error)
                //        return
            }
        }
        
        // A data task needs to be run. To start it, you call `resume`.
        // "Newly-initialized tasks begin in a suspended state, so you need to call this method to start the task."
        dataTask.resume()
    }
}
