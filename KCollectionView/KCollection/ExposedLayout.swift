//
//  ExposedLayout.swift
//  KCollectionView
//
//  Created by ikorn on 9/9/16.
//  Copyright © 2016 ikorn. All rights reserved.
//

import UIKit

class ExposedLayout: UICollectionViewLayout {

    var layoutMargin: UIEdgeInsets =                UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
    var itemSize:                                   CGSize = CGSize.zero
    var topOverlap:                                 CGFloat = 10.0
    var bottomOverlap:                              CGFloat = 5.0
    var bottomOverlapCount:                         UInt = 1
    var bottomPinningCount:                         UInt = 5
    var exposedItemIndex:                           Int!
    var layoutAttributes:                           [IndexPath : UICollectionViewLayoutAttributes] = [:]
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = self.collectionView else { return CGSize.zero }
        var contentSize = collectionView.bounds.size
        contentSize.height -= collectionView.contentInset.top + collectionView.contentInset.bottom
        return contentSize
    }
    
    init(exposedItemIndex: Int) {
        super.init()
        
        self.exposedItemIndex = exposedItemIndex
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return CGPoint.zero
    }
    
    override func prepare() {
        guard let collectionView = self.collectionView else { return }
        let layoutSize:                             CGSize = CGSize(width: collectionView.bounds.width - self.layoutMargin.left - self.layoutMargin.right,
                                height: collectionView.bounds.height - self.layoutMargin.top - self.layoutMargin.bottom)
        if self.itemSize == CGSize.zero {
            self.itemSize = CGSize(width: layoutSize.width,
                                   height: self.collectionViewContentSize.height - self.layoutMargin.top - self.layoutMargin.bottom)
        }
        let itemHorizontalOffset:                   CGFloat = 0.5 * (layoutSize.width - self.itemSize.width)
        let itemOrigin:                             CGPoint = CGPoint(x: self.layoutMargin.left + floor(itemHorizontalOffset), y: 0)
        var layoutAttributes:                       [IndexPath : UICollectionViewLayoutAttributes] = [:]
        let itemCount:                              Int = collectionView.numberOfItems(inSection: 0)
        let bottomPinningCount:                     Int = min(itemCount - self.exposedItemIndex - 1, Int(self.bottomPinningCount))
        let topPinningCount:                        Int = self.exposedItemIndex
        for item in 0..<itemCount {
            let indexPath:                          IndexPath = IndexPath(item: item, section: 0)
            let attributes:                         UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.zIndex = item
            attributes.transform3D = CATransform3DMakeTranslation(0, 0, CGFloat(item - itemCount))
            if item < self.exposedItemIndex {
                var count = self.exposedItemIndex - item
                if count > topPinningCount {
                    attributes.frame = CGRect(origin: CGPoint(x: itemOrigin.x, y: self.collectionViewContentSize.height),
                                              size: self.itemSize)
                    attributes.isHidden = true
                } else {
                    count += bottomPinningCount
                    attributes.frame = CGRect(origin: CGPoint(x: itemOrigin.x, y: self.collectionViewContentSize.height - self.layoutMargin.bottom - CGFloat(count) * self.bottomOverlap),
                                              size: self.itemSize)
                }
            } else if item == self.exposedItemIndex {
                // Exposed item
                attributes.frame = CGRect(origin: CGPoint(x: itemOrigin.x, y: self.layoutMargin.top),
                                          size: self.itemSize)
            } else if item > self.exposedItemIndex + bottomPinningCount {
                attributes.frame = CGRect(origin: CGPoint(x: itemOrigin.x, y: self.collectionViewContentSize.height),
                                          size: self.itemSize)
                attributes.isHidden = true
            } else {
                let count = min(bottomPinningCount + 1, itemCount - self.exposedItemIndex) - (item - self.exposedItemIndex)
                attributes.frame = CGRect(origin: CGPoint(x: itemOrigin.x, y: self.collectionViewContentSize.height - self.layoutMargin.bottom - CGFloat(count) * self.bottomOverlap),
                                          size: self.itemSize)
            }
            
            layoutAttributes[indexPath] = attributes
        }
        self.layoutAttributes = layoutAttributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.layoutAttributes.map({ $0.value }).filter({ rect.intersects($0.frame) })
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        return self.layoutAttributes[indexPath]!
    }
}
