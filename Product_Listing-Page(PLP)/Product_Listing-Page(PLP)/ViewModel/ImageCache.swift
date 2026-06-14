//
//  ImageCache.swift
//  Product_Listing-Page(PLP)
//
//  Created by Siyaa Dahiya on 12/06/26.
//

import SwiftUI
import Combine

final class ImageCache {
    static let shared = ImageCache()
    
    private init() {}
    
    let cache = NSCache<NSString, UIImage>()
}




final class ImageLoader: ObservableObject {
    
    @Published var image: UIImage?
    
    func load(from urlString: String) {
        
        if let cachedImage = ImageCache.shared.cache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            
            guard let data = data,
                  let downloadedImage = UIImage(data: data) else {
                return
            }
            
            ImageCache.shared.cache.setObject(
                downloadedImage,
                forKey: urlString as NSString
            )
            
            DispatchQueue.main.async {
                self.image = downloadedImage
            }
        }
        .resume()
    }
}


struct CachedImageView: View {
    
    let urlString: String
    
    @StateObject private var loader = ImageLoader()
    
    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .cornerRadius(20)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            loader.load(from: urlString)
        }
    }
}
