//
//  ViewController.swift
//  KCollectionView
//
//  Created by ikorn on 9/8/16.
//  Copyright © 2016 ikorn. All rights reserved.
//

import UIKit

class ViewController: PassCollectionViewController {

    var data: [CollectionDataModel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.register(CollectionViewCell.cellNib(), forCellWithReuseIdentifier: CollectionViewCell.cellIdentifier())
        
        self.data = (0..<20).map { index in
            CollectionDataModel(title: "title \(index)", subtitle: "subtitle \(index)", amount: index * 10000)
        }
        collectionView?.reloadData()
        
    }

    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.cellIdentifier(), for: indexPath) as? CollectionViewCell {
            let pass = self.data[indexPath.item]
            cell.configureCell(cell: cell, data: pass)
            return cell
        }
        return UICollectionViewCell()
    }
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let pass = self.data[sourceIndexPath.item]
        self.data.remove(at: sourceIndexPath.item)
        self.data.insert(pass, at: destinationIndexPath.item)
        collectionView.reloadItems(at: [ sourceIndexPath, destinationIndexPath ])
    }
    
}

