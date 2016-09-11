//
//  StackedLayout.swift
//  KCollectionView
//
//  Created by ikorn on 9/10/16.
//  Copyright © 2016 ikorn. All rights reserved.
//

import UIKit

class StackedLayout: UICollectionViewLayout {
    
    @IBInspectable var layoutMargin:                UIEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    @IBInspectable var itemSize:                    CGSize = CGSize.zero
    @IBInspectable var topReveal:                   CGFloat = 75
    @IBInspectable var bounceFactor:                CGFloat = 0.2
    @IBInspectable var movingItemScaleFactor:       CGFloat = 0.95
    @IBInspectable var movingItemOnTop:             Bool = true
    
    var overwriteContentOffset:                     Bool = false
    var contentOffset:                              CGPoint = CGPoint.zero
    var layoutAttributes:                           [IndexPath: UICollectionViewLayoutAttributes] = [:]
    
    var contentCount:                               CGFloat {
        guard let collectionView = self.collectionView else {
            return 0
        }
        return CGFloat(collectionView.numberOfItems(inSection: 0))
    }
    
    override var collectionViewContentSize:         CGSize {
        guard let collectionView = self.collectionView else {
            return CGSize.zero
        }
        var contentSize:                            CGSize = CGSize(width: collectionView.bounds.width,
                                                                    height: self.layoutMargin.top + self.topReveal * self.contentCount + self.layoutMargin.bottom)
        if contentSize.height < collectionView.bounds.height {
            contentSize.height = collectionView.bounds.height + 1
        }
        return contentSize
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return self.overwriteContentOffset ? self.contentOffset : proposedContentOffset
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func prepare() {
        guard let collectionView = self.collectionView else { return }
        _ = self.collectionViewContentSize
        let layoutSize = CGSize(width: collectionView.bounds.width - self.layoutMargin.left - self.layoutMargin.right,
                                height: collectionView.bounds.height - self.layoutMargin.top - self.layoutMargin.bottom)
        let itemReveal: CGFloat = self.topReveal
        if self.itemSize == CGSize.zero {
            self.itemSize = layoutSize
        }
        let itemHorizontalOffset: CGFloat = 0.5 * (layoutSize.width - self.itemSize.width)
        let itemOrigin = CGPoint(x: self.layoutMargin.left + floor(itemHorizontalOffset), y: 0.0)
        // Honor overwritten contentOffset
        let contentOffset = self.overwriteContentOffset ? self.contentOffset : collectionView.contentOffset
        var layoutAttributes: [IndexPath : UICollectionViewLayoutAttributes] = [:]
        var previousTopOverlappingAttributes: [UICollectionViewLayoutAttributes?] = [nil, nil]
        let itemCount = Int(self.contentCount)
        var firstCompressingItem = -1

        for item in 0..<itemCount {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            // By default all items are layed out evenly with each revealing only top part ...
            attributes.frame = CGRect(origin: CGPoint(x: itemOrigin.x, y: self.layoutMargin.top + itemReveal * CGFloat(item)),
                                      size: self.itemSize)
            attributes.zIndex = item
            attributes.transform3D = CATransform3DMakeTranslation(0, 0, CGFloat(item - itemCount))
            if contentOffset.y + collectionView.contentInset.top < 0 {
                // Expand cells when reaching top and user scrolls further down, i.e. when bouncing
                attributes.frame.origin.y -= self.bounceFactor * (contentOffset.y + collectionView.contentInset.top) * CGFloat(item)
            } else if attributes.frame.minY < contentOffset.y + self.layoutMargin.top {
                // Topmost cells overlap stack, but are placed directly above each other such that only one cell is visible
                attributes.frame.origin.y = contentOffset.y + self.layoutMargin.top
                // Keep queue of last two items' attributes and hide any item below top overlapping item to improve performance
                if let prevAttributes = previousTopOverlappingAttributes[1] {
                    prevAttributes.isHidden = true
                }
                previousTopOverlappingAttributes[1] = previousTopOverlappingAttributes[0]
                previousTopOverlappingAttributes[0] = attributes
            } else if self.collectionViewContentSize.height > collectionView.bounds.height &&
                contentOffset.y > self.collectionViewContentSize.height - collectionView.bounds.height {
                // Compress cells when reaching bottom and user scrolls further up, i.e. when bouncing
                if firstCompressingItem < 0 {
                    firstCompressingItem = item
                } else {
                    var frame = attributes.frame
                    let delta: CGFloat = contentOffset.y + collectionView.bounds.height - self.collectionViewContentSize.height
                    frame.origin.y += self.bounceFactor * delta * CGFloat(firstCompressingItem - item)
                    frame.origin.y = max(frame.origin.y, contentOffset.y + self.layoutMargin.top)
                    attributes.frame = frame
                }
            } else {
                firstCompressingItem = -1
            }
            layoutAttributes[indexPath] = attributes
        }
        self.layoutAttributes = layoutAttributes
    }
    
    
    func layoutAttributesForInteractivelyMovingItemAtIndexPath(indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes {
        let attributes = super.layoutAttributesForInteractivelyMovingItem(at: indexPath, withTargetPosition: position)
        if self.movingItemOnTop {
            // If moving item should float above
            // other items change z ordering
            // NOTE: Since z transform is from -#items to 0.0 we place floating item at +1
            attributes.zIndex = NSIntegerMax
            attributes.transform3D = CATransform3DMakeTranslation(0.0, 0.0, 1.0)
        }
        // Apply scale factor in addition to z transform
        //
        attributes.transform3D = CATransform3DScale(attributes.transform3D, self.movingItemScaleFactor, self.movingItemScaleFactor, 1.0)
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes] {
        return self.layoutAttributes.map({ $0.value }).filter({ rect.intersects($0.frame) })
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        return self.layoutAttributes[indexPath]!
    }
}
