//
//  ViewController.swift
//  WalmartPLP-Day1
//
//  Created by Siyaa Dahiya on 11/06/26.
//

import UIKit

class ViewController: UIViewController {
    
    var vm = AlbumViewModel()
    
    

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var albumCollectionView: UICollectionView!
    @IBOutlet var bgView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .green
        albumCollectionView.register(
            UINib(nibName: "AlbumViewCell", bundle: nil),
            forCellWithReuseIdentifier: AlbumViewCell.albumCellIdentifier
        )
        albumCollectionView.delegate = self
        albumCollectionView.dataSource = self
        Task {
            await self.vm.fetchAlbums()
            DispatchQueue.main.async {
                self.albumCollectionView.reloadData()
            }
        }
       
    }


}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm.albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = albumCollectionView.dequeueReusableCell(withReuseIdentifier: AlbumViewCell.albumCellIdentifier, for: indexPath) as! AlbumViewCell
        cell.setData(album: vm.albums[indexPath.row])
        return cell
    }
    
    
}





//Build Product Listing Page:
//1. UISearchBar at top
//2. UICollectionView 2-col grid below
//3. API: Mock with https://jsonplaceholder.typicode.com/photos?_page=0&_limit=20
//4. Pagination: Load next page when user scrolls to last 5 items
//5. Image: Async load, cancel on cell reuse, placeholder system image
//6. Debounce search: 300ms. Cancel old request
//7. Pull to refresh
//8. Show "No Results" label when empty
//9. 60fps target on iPhone SE simulator
//
//Rules: URLSession only. No Kingfisher. Must use UICollectionViewDiffableDataSource
