//
//  Product_Listing_Page_PLP_App.swift
//  Product_Listing-Page(PLP)
//
//  Created by Siyaa Dahiya on 12/06/26.
//

import SwiftUI
import SwiftData

@main
struct Product_Listing_Page_PLP_App: App {
    
    @StateObject private var networkMonitor = NetworkMonitor()
    
    
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .modelContainer(for: CachedProduct.self)
            .environmentObject(networkMonitor)
            
        }
    }
}
