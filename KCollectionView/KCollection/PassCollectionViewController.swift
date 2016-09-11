//
//  PassCollectionViewController.swift
//  KCollectionView
//
//  Created by ikorn on 9/10/16.
//  Copyright © 2016 ikorn. All rights reserved.
//

import UIKit


class PassCollectionViewController: UICollectionViewController, UIGestureRecognizerDelegate {
    
    @IBInspectable var exposedLayoutMargin:         UIEdgeInsets = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
    @IBInspectable var exposedTopOverlap:           CGFloat = 10
    @IBInspectable var exposedBottomOverlap:        CGFloat = 10
    @IBInspectable var movingItemScaleFactor:       CGFloat = 0.95
    @IBInspectable var movingItemOnTop:             Bool = true
    @IBInspectable var collapsePanMinimumThreshold: CGFloat = 120
    @IBInspectable var collapsePanMaximumThreshold: CGFloat = 0
    
    var interactiveTransitionInProgress:            Bool = false
    var exposedItemIndexPath:                       IndexPath?
    var stackedLayout:                              StackedLayout?
    var exposedLayout:                              ExposedLayout?
    var moveGestureRecognizer:                      UILongPressGestureRecognizer!
    var movingIndexPath:                            IndexPath!
    var collapseGestureRecognizer:                  UIGestureRecognizer? {
        guard let _ = self.exposedLayout else {
            return nil
        }
        return self.collapsePanGestureRecognizer

    }
    var _collapsePanGestureRecognizer:              UIPanGestureRecognizer?
    var collapsePanGestureRecognizer:               UIPanGestureRecognizer {
        guard let collapsePanGestureRecognizer = self._collapsePanGestureRecognizer else {
            self._collapsePanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handleCollapsePanGesture))
            self._collapsePanGestureRecognizer!.delegate = self
            return self._collapsePanGestureRecognizer!
        }
        return collapsePanGestureRecognizer
    }
    
    // MARK: - Actions
    
    @IBAction func handleMovePressGesture(recognizer: UILongPressGestureRecognizer) {
        guard let collectionView = self.collectionView else { return }
        var startLocation: CGPoint = CGPoint.zero
        var targetPosition: CGPoint = CGPoint.zero
        switch recognizer.state {
        case .began:
            startLocation = recognizer.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: startLocation), collectionView.beginInteractiveMovementForItem(at: indexPath) {
                self.stackedLayout?.movingItemScaleFactor = self.movingItemScaleFactor
                self.stackedLayout?.movingItemOnTop = self.movingItemOnTop
                let movingCell = collectionView.cellForItem(at: indexPath)!
                targetPosition = movingCell.center
                collectionView.updateInteractiveMovementTargetPosition(targetPosition)
                self.movingIndexPath = indexPath
            }
        case .changed:
            guard let _ = self.movingIndexPath else { return }
            let currentLocation = recognizer.location(in: collectionView)
            var newTargetPosition = targetPosition
            newTargetPosition.y += (currentLocation.y - startLocation.y)
            collectionView.updateInteractiveMovementTargetPosition(newTargetPosition)
        case .ended:
            guard let _ = self.movingIndexPath else { return }
            collectionView.endInteractiveMovement()
            self.stackedLayout?.invalidateLayout()
            self.movingIndexPath = nil
        case .cancelled:
            guard let _ = self.movingIndexPath else { return }
            collectionView.cancelInteractiveMovement()
            self.stackedLayout?.invalidateLayout()
            self.movingIndexPath = nil
        default:
            break
        }
        
    }
    
    
    @IBAction func handleCollapsePanGesture(recognizer: UIPanGestureRecognizer) {
        guard let collectionView = self.collectionView else { return }
        var transitionLayout: UICollectionViewTransitionLayout?
        var transitionMaxThreshold: CGFloat = 0
        var transitionMinThreshold: CGFloat = 0
        switch recognizer.state {
        case .began:
            let exposedCell = collectionView.cellForItem(at: self.exposedItemIndexPath!)!
            transitionLayout = collectionView.startInteractiveTransition(to: self.stackedLayout!, completion: {[weak self] (completed: Bool, finish: Bool) -> () in
                if finish {
                    if let collapsePanGestureRecognizer = self?._collapsePanGestureRecognizer {
                        exposedCell.removeGestureRecognizer(collapsePanGestureRecognizer)
                    }
                    self!.stackedLayout?.overwriteContentOffset = false
                    self!.exposedItemIndexPath = nil
                    self!.exposedLayout = nil
                }
                self?.interactiveTransitionInProgress = false
                transitionLayout = nil
            })
            transitionMaxThreshold = (self.collapsePanMaximumThreshold > 0.0) ? self.collapsePanMaximumThreshold : exposedCell.bounds.height
            transitionMinThreshold = max(self.collapsePanMinimumThreshold, 0.0)
            self.interactiveTransitionInProgress = true
            
        case .changed:
            let currentOffset = recognizer.translation(in: collectionView)
            if currentOffset.y >= 0.0 {
                transitionLayout?.transitionProgress = min(currentOffset.y, transitionMaxThreshold) / transitionMaxThreshold
            }
            
        case .ended:
            let currentOffset = recognizer.translation(in: collectionView)
            let currentSpeed = recognizer.velocity(in: collectionView)
            if currentOffset.y >= transitionMinThreshold && currentSpeed.y >= 0.0 {
                collectionView.deselectItem(at: self.exposedItemIndexPath!, animated: true)
                collectionView.finishInteractiveTransition()
            }
            else {
                collectionView.cancelInteractiveTransition()
            }
            
        case .cancelled:
            collectionView.cancelInteractiveTransition()
            
        default:
            break
        }
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initController()
        
    }
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        assert((layout is StackedLayout), "TGLStackedViewController collection view layout is not a TGLStackedLayout")
        super.init(collectionViewLayout: layout)
        
        initController()
        
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        initController()
        
    }
    
    func initController() {
        self.installsStandardGestureForInteractiveMovement = false
        self.exposedLayoutMargin = UIEdgeInsets(top: 40.0, left: 0.0, bottom: 0.0, right: 0.0)
        self.exposedTopOverlap = 30.0
        self.exposedBottomOverlap = 30.0
        self.movingItemScaleFactor = 0.95
        self.movingItemOnTop = true
        self.collapsePanMinimumThreshold = 120.0
        self.collapsePanMaximumThreshold = 0.0
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let collectionView = self.collectionView {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.isUserInteractionEnabled = true
            assert((self.collectionViewLayout is StackedLayout), "StackedLayout collection view layout is not a StackedLayout")
            self.stackedLayout = (self.collectionViewLayout as! StackedLayout)
            self.moveGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleMovePressGesture))
            self.moveGestureRecognizer.delegate = self
            collectionView.addGestureRecognizer(self.moveGestureRecognizer)
        }
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: IndexPath) -> Bool {
        // When selecting unexposed items is not allowed, prevent them from being highlighted and thus selected by the collection view
        if self.interactiveTransitionInProgress {
            return false
        }
        return self.exposedItemIndexPath == nil || indexPath.item == self.exposedItemIndexPath!.item
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: IndexPath) {
        // When selecting unexposed items is not allowed make sure the currently exposed item remains selected
        if let exposedItemIndexPath = self.exposedItemIndexPath, indexPath.item == exposedItemIndexPath.item {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let prevExposedItemIndexPath = self.exposedItemIndexPath else {
            // no exposed item -> exposed selected item
            self.stackedLayout?.contentOffset = collectionView.contentOffset
            self.exposedLayout = getExposedLayout(indexPath: indexPath)
            collectionView.setCollectionViewLayout(self.exposedLayout!, animated: true, completion: { [weak self] (finished) in
                self!.stackedLayout?.overwriteContentOffset = true
                if let exposedCell = collectionView.cellForItem(at: indexPath) {
                    self!.addCollapseGestureRecognizerToView(view: exposedCell)
                }
                self?.exposedItemIndexPath = indexPath
                })
            return
        }
        // has exposed item and select item
        if prevExposedItemIndexPath.item == indexPath.item {
            // deselect -> collapsed selected item
            collectionView.deselectItem(at: indexPath, animated: true)
            if let exposedCell = collectionView.cellForItem(at: indexPath),
                let collapsePanGestureRecognizer = self._collapsePanGestureRecognizer {
                exposedCell.removeGestureRecognizer(collapsePanGestureRecognizer)
            }
            collectionView.setCollectionViewLayout(self.stackedLayout!, animated: true, completion: { [weak self] (finished) in
                self!.stackedLayout?.overwriteContentOffset = false
                self?.exposedItemIndexPath = nil
                self?.exposedLayout = nil
            })
        } else {
            // select other -> exposed selected item
            if let exposedCell = collectionView.cellForItem(at: prevExposedItemIndexPath),
                let collapsePanGestureRecognizer = self._collapsePanGestureRecognizer {
                exposedCell.removeGestureRecognizer(collapsePanGestureRecognizer)
            }
            self.exposedLayout = getExposedLayout(indexPath: indexPath)
            collectionView.setCollectionViewLayout(self.exposedLayout!, animated: true, completion: { [weak self] (finished) in
                self?.exposedItemIndexPath = indexPath
                if let exposedCell = collectionView.cellForItem(at: indexPath) {
                    self?.addCollapseGestureRecognizerToView(view: exposedCell)
                }
            })
        }
    }
    
    // MARK: - UICollectionViewDataSource protocol
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: IndexPath) -> Bool {
        return (self.exposedLayout == nil && collectionView.numberOfItems(inSection: 0) > 1)
    }
    // MARK: - Helpers
    
    func addCollapseGestureRecognizerToView(view: UIView) {
        if let recognizer = self.collapseGestureRecognizer {
            view.addGestureRecognizer(recognizer)
        }
    }
    
    func getExposedLayout(indexPath: IndexPath) -> ExposedLayout? {
        let exposedLayout = ExposedLayout(exposedItemIndex: indexPath.item)
        exposedLayout.layoutMargin = self.exposedLayoutMargin
        exposedLayout.topOverlap = self.exposedTopOverlap
        exposedLayout.bottomOverlap = self.exposedBottomOverlap
        return exposedLayout
    }

}
