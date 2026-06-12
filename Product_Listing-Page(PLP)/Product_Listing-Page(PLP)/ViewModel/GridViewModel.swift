//
//  GridViewModel.swift
//  Product_Listing-Page(PLP)
//
//  Created by Siyaa Dahiya on 12/06/26.
//

//https://rss.marketingtools.apple.com/api/v2/us/apps/top-free/100/apps.json

import Combine
import Foundation

class GridViewModel : ObservableObject {
    @Published var feeds = [AppResult]()
    
    init() {
       
        
    }
    
    func getData() {
        let urlString = "https://rss.marketingtools.apple.com/api/v2/us/apps/top-free/10/apps.json"
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                return
            }
            do {
                let obj = try JSONDecoder().decode(GridModel.self, from: data)
                self.feeds = obj.feed.results
            } catch {
                print("Error in decoding")
            }
        }.resume()
    }
}


// MARK: - Welcome
struct GridModel: Codable {
    let feed: Feed
}

// MARK: - Feed
struct Feed: Codable {
    let id: String
    let results: [AppResult]
}


// MARK: - Result
struct AppResult: Codable, Hashable {
    let id, name, releaseDate,kind: String
    let artworkUrl100: String
}
