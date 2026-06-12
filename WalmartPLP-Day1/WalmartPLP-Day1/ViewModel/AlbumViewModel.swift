
//
//  AlbumViewModel.swift
//  WalmartPLP-Day1
//
//  Created by Siyaa Dahiya on 11/06/26.
//


class AlbumViewModel {
    
    var albums: [Album] = [Album]()
    
    func fetchAlbums() async {
        do {
             albums = try await AlbumService().fetchAlbums(pageNumber: 1, limit: 20)
        } catch {
            print("Error")
        }
    }
}
