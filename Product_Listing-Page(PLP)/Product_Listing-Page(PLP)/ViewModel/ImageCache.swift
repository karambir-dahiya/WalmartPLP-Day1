//
//  ImageCache.swift
//  Product_Listing-Page(PLP)
//
//  Created by Siyaa Dahiya on 12/06/26.
//

import SwiftUI

struct CachedImageView: View {
    let thumbnailData: Data?
    let fallbackURLString: String
    
    var body: some View {
        Group {
            if let data = thumbnailData, let uiImage = UIImage(data: data) {
                // Local disk cache hits here instantly during airplane mode
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                // Fallback network loader if image hasn't been cached yet
                AsyncImage(url: URL(string: fallbackURLString)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFit()
                    case .failure:
                        Image(systemName: "photo") // Error placeholder
                            .foregroundColor(.gray)
                    case .empty:
                        ProgressView() // Loading indicator
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .clipped()
    }
}
