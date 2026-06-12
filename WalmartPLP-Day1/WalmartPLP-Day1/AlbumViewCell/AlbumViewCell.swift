//
//  AlbumViewCell.swift
//  WalmartPLP-Day1
//
//  Created by Siyaa Dahiya on 11/06/26.
//

import UIKit
class AlbumViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bgView: UIView!
    static let albumCellIdentifier = "albumCell"
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!
    
    private var imageTask: Task<Void, Never>?
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        imageTask?.cancel()
        
        thumbnailView.image = nil
        self.title.text = ""
        self.bgView?.backgroundColor = .gray
        self.bgView.layer.cornerRadius = 10
        
        
    }
    
    
    
    func configure(with album: Album) {
        thumbnailView.image = UIImage(systemName: "photo")
        
        imageTask?.cancel()
        self.title.text = album.title
        imageTask = Task {
            
            do {
                print(album.thumbnailUrl)
                let image = try await ImageLoader.shared.loadImage(from: album.thumbnailUrl)
                
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self.thumbnailView.image = image
                }
                
            } catch {
                print(error)
            }
            
        }
        
    }
}
