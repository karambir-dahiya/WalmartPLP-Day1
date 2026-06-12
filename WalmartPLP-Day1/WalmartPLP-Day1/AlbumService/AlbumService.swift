//
//  AlbumService.swift
//  WalmartPLP-Day1
//
//  Created by Siyaa Dahiya on 11/06/26.

import Foundation

class AlbumService {
    func fetchAlbums(page: Int, query: String? = nil) async throws -> [Album] {
        var urlString = "https://jsonplaceholder.typicode.com/photos?_page=\(page)&_limit=20"
        if let query = query,!query.isEmpty {
            urlString += "&q=\(query)"
        }
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([Album].self, from: data)
    }
}
