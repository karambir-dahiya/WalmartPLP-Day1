//
//  AlbumViewCell.swift
//  WalmartPLP-Day1
//
//  Created by Siyaa Dahiya on 11/06/26.
//

import UIKit
class AlbumViewCell: UICollectionViewCell {
    
   static let albumCellIdentifier = "albumCell"
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!
    
    func setData(album: Album) {
        self.title.text = album.title
        
        
        
    }
}
