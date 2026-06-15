//
//  GridViewModel.swift
//  Product_Listing-Page(PLP)
//
//  Created by Siyaa Dahiya on 12/06/26.
//


import SwiftUI
import SwiftData
import Combine

//https://dummyjson.com/products/search?q=phone&limit=20&skip=0

@MainActor
class ProductViewModel: ObservableObject {
    @Published var products: [CachedProduct] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    
    var pageNumber = 1
    let limit = 20
    var hasMoreData = true
    
    private var modelContext: ModelContext?
    
    // Safe fallback init
    init() {}
    
    func setupContext(_ context: ModelContext) {
        // Prevent duplicate setup passes if the view re-renders
        guard self.modelContext == nil else { return }
        
        self.modelContext = context
        
        // Context is now fully wired up and ready to read from disk
        loadLocalCache()
    }
    
    // 1. Fetch instantly from disk
    func loadLocalCache() {
        
        // Safely unwrap the context now that setupContext has run
        guard let modelContext = modelContext else {
            print("Database context is unexpectedly nil")
            return
        }
        
        let descriptor = FetchDescriptor<CachedProduct>(sortBy: [SortDescriptor(\.id)])
        if let localItems = try? modelContext.fetch(descriptor) {
            self.products = localItems
        }
    }
    
    // 2. Network Fetch + Local Save
    // Inside your ProductViewModel class...
    
    func getData() async {
        guard !isLoading, hasMoreData else { return }
        isLoading = true
        defer { isLoading = false }
        
        let skip = (pageNumber - 1) * limit
        let urlString = "https://dummyjson.com/products?limit=\(limit)&skip=\(skip)"
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let apiResponse = try JSONDecoder().decode(ProductAPIResponse.self, from: data)
            
            if apiResponse.products.isEmpty {
                hasMoreData = false
                return
            }
            
            // Fetch image data concurrently for all incoming products
            for apiProduct in apiResponse.products {
                var imageData: Data? = nil
                if let imgURL = URL(string: apiProduct.thumbnail) {
                    // If offline or fails, it will gracefully fallback to nil without crashing
                    imageData = try? await URLSession.shared.data(from: imgURL).0
                }
                
                let cachedItem = CachedProduct(
                    id: apiProduct.id,
                    title: apiProduct.title,
                    productDescription: apiProduct.description,
                    thumbnailURL: apiProduct.thumbnail,
                    thumbnailData: imageData // Saved locally on disk
                )
                modelContext?.insert(cachedItem)
            }
            
            try? modelContext?.save()
            loadLocalCache()
            pageNumber += 1
            
        } catch {
            print("Offline/Fetch error: \(error.localizedDescription)")
        }
    }

    
    func refreshData() async {
        guard !isLoading else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        
//        https://dummyjson.com/products?limit=20&skip=0
        let urlString = "https://dummyjson.com/products?limit=\(limit)&skip=0"
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let APIResponse = try JSONDecoder().decode(ProductAPIResponse.self, from: data)
            
            // Clear old cache on pull-to-refresh success
            try? modelContext?.delete(model: CachedProduct.self)
            
            for apiProduct in APIResponse.products {
                
                var imageData: Data? = nil
                if let imgURL = URL(string: apiProduct.thumbnail) {
                    // If offline or fails, it will gracefully fallback to nil without crashing
                    imageData = try? await URLSession.shared.data(from: imgURL).0
                }
                let cachedItem = CachedProduct(
                    id: apiProduct.id,
                    title: apiProduct.title,
                    productDescription: apiProduct.description,
                    thumbnailURL: apiProduct.thumbnail,
                    thumbnailData: imageData // Saved locally on disk
                )
                modelContext?.insert(cachedItem)
            }
            
            try? modelContext?.save()
            pageNumber += 1
            hasMoreData = true
            loadLocalCache()
            
        } catch {
            print("Refresh failed. Retaining old cache.")
        }
    }
    
    func loadMoreIfNeeded(currentItem item: CachedProduct) async {
        
        
        guard let index = products.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        
        // Trigger when user reaches last 5 items
        
        if index >= products.count - 5 {
            
            await getData()
            
        }
        
    }
}

// Temporary Decodable struct just for API parsing
struct ProductAPIResponse: Decodable {
    let products: [APIProduct]
}
struct APIProduct: Decodable {
    let id: Int
    let title: String
    let description: String
    let thumbnail: String
}


@Model
class CachedProduct: Identifiable {
    @Attribute(.unique) var id: Int
    var title: String
    var productDescription: String
    var thumbnailURL: String
    
    // Stores the raw image bytes cleanly outside the main database file
    @Attribute(.externalStorage) var thumbnailData: Data?
    
    init(id: Int, title: String, productDescription: String, thumbnailURL: String, thumbnailData: Data? = nil) {
        self.id = id
        self.title = title
        self.productDescription = productDescription
        self.thumbnailURL = thumbnailURL
        self.thumbnailData = thumbnailData
    }
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
