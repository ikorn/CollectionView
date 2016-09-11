//
//  CollectionViewCell.swift
//  KCollectionView
//
//  Created by ikorn on 9/8/16.
//  Copyright © 2016 ikorn. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var viewFrame:       UIView!
    @IBOutlet weak var lblTitle:        UILabel!
    @IBOutlet weak var lblSubtitle:     UILabel!
    @IBOutlet weak var lblCurrency:     UILabel!
    @IBOutlet weak var lblAmount:       UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static func cellIdentifier() -> String {
        return "kCell"
    }
    
    static func cellNib() -> UINib {
        return UINib(nibName: "CollectionViewCell", bundle: nil)
    }
    
    func configureCell(cell: UICollectionViewCell, data: CollectionDataModel) {
        guard let cell = cell as? CollectionViewCell else {
            return
        }
        cell.lblTitle.text = data.title
        cell.lblSubtitle.text = data.subtitle
        cell.lblCurrency.text = data.currency
        cell.lblAmount.text = "\(data.amount)"
        cell.viewFrame.layer.borderWidth = 1
        cell.viewFrame.layer.borderColor = UIColor.lightGray.cgColor
        cell.viewFrame.layer.masksToBounds = true
    }
    
}
