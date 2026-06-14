//
//  GridViewModel.swift
//  Product_Listing-Page(PLP)
//
//  Created by Siyaa Dahiya on 12/06/26.
//

//https://rss.marketingtools.apple.com/api/v2/us/apps/top-free/100/apps.json

import Combine
import Foundation

enum LoadingState {
    
    case idle
    
    case refreshing
    
    case paginating
    
}

@MainActor
class GridViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var state: LoadingState = .idle
    var countPerPage = 20
    var pageNumber = 1
    private var hasMoreData = true
    
    func refreshData() async {
        guard state != .refreshing else { return }
        state = .refreshing
        
        defer { state = .idle }
        
        pageNumber = 1
        hasMoreData = true
        products.removeAll()
        
        await getData()
    }
    
    func getData() async {
        let urlString = "https://dummyjson.com/products?limit=\(countPerPage)&skip=\((pageNumber - 1) * countPerPage)"
        print(urlString)
        guard let url = URL(string: urlString) else {
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let newFeeds = try JSONDecoder().decode(ProductModel.self, from: data)
            if newFeeds.products.isEmpty {
                hasMoreData = false
            } else {
                products.append(contentsOf: newFeeds.products)
                pageNumber += 1
            }
            
        } catch is CancellationError {
            
            print("Request cancelled")
            
        } catch {
            
            print(error)
            
        }
    }
    
    func loadMoreIfNeeded(currentItem item: Product) async {
        guard state == .idle else { return }
        state = .paginating
        defer { state = .idle }
        
        guard let index = products.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        
        // Trigger when user reaches last 5 items
        
        if index >= products.count - 5 {
            
            await getData()
            
        }
        
    }
}


struct ProductModel: Codable {
    let products: [Product]
    let total, skip, limit: Int
}

// MARK: - Welcome
struct Product: Codable, Hashable {
    let id: Int
    let title, description, thumbnail: String
}


//{
//    "id":1,
//    "title":"Essence Mascara Lash Princess",
//    "description":"The Essence Mascara Lash Princess is a popular mascara known for its volumizing and lengthening effects. Achieve dramatic lashes with this long-lasting and cruelty-free formula.",
//    "category":"beauty",
//    "price":9.99,
//    "discountPercentage":10.48,
//    "rating":2.56,
//    "stock":99,
//    "tags":[
//        "beauty",
//        "mascara"
//    ],
//    "brand":"Essence",
//    "sku":"BEA-ESS-ESS-001",
//    "weight":4,
//    "dimensions":{
//        "width":15.14,
//        "height":13.08,
//        "depth":22.99
//    },
//    "warrantyInformation":"1 week warranty",
//    "shippingInformation":"Ships in 3-5 business days",
//    "availabilityStatus":"In Stock",
//    "reviews":[
//        {
//          "rating":3,
//          "comment":"Would not recommend!",
//          "date":"2025-04-30T09:41:02.053Z",
//          "reviewerName":"Eleanor Collins",
//          "reviewerEmail":"eleanor.collins@x.dummyjson.com"
//        },
//        {
//          "rating":4,
//          "comment":"Very satisfied!",
//          "date":"2025-04-30T09:41:02.053Z",
//          "reviewerName":"Lucas Gordon",
//          "reviewerEmail":"lucas.gordon@x.dummyjson.com"
//        },
//        {
//          "rating":5,
//          "comment":"Highly impressed!",
//          "date":"2025-04-30T09:41:02.053Z",
//          "reviewerName":"Eleanor Collins",
//          "reviewerEmail":"eleanor.collins@x.dummyjson.com"
//        }
//    ],
//    "returnPolicy":"No return policy",
//    "minimumOrderQuantity":48,
//    "meta":{
//        "createdAt":"2025-04-30T09:41:02.053Z",
//        "updatedAt":"2025-04-30T09:41:02.053Z",
//        "barcode":"5784719087687",
//        "qrCode":"https://cdn.dummyjson.com/public/qr-code.png"
//    },
//    "images":[
//        "https://cdn.dummyjson.com/product-images/beauty/essence-mascara-lash-princess/1.webp"
//    ],
//    "thumbnail":"https://cdn.dummyjson.com/product-images/beauty/essence-mascara-lash-princess/thumbnail.webp"
//}
