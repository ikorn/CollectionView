//
//  CollectionDataModel.swift
//  KCollectionView
//
//  Created by ikorn on 9/8/16.
//  Copyright © 2016 ikorn. All rights reserved.
//

import UIKit

class CollectionDataModel: NSObject {
    var title:                                      String
    var subtitle:                                   String
    var currency:                                   String
    var amount:                                     Int
    
    init(title: String, subtitle: String, currency: String = "JPY", amount: Int) {
        self.title = title
        self.subtitle = subtitle
        self.currency = currency
        self.amount = amount
    }
}
