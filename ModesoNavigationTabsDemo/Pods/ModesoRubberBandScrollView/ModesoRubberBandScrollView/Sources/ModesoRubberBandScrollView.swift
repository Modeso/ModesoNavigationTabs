//
//  ModesoRubberBandScrollView.swift
//  TestMyPod
//
//  Created by Samuel Schmid on 14.08.17.
//  Copyright © 2017 Modeso. All rights reserved.
//

import UIKit

class ModesoRubberBandScrollView: UIScrollView {
    var receiver: UIScrollViewDelegate?
    var middleMan: ModesoRubberBandDelegate?
    
    override func awakeFromNib() {
        self.receiver = self.delegate
        self.middleMan = ModesoRubberBandDelegate(self.receiver);
        self.delegate = self.middleMan
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

protocol ModesoInterceptor {
    func forwardingTarget(for aSelector: Selector!) -> Any?
    func responds(to aSelector: Selector!) -> Bool
}

extension ModesoRubberBandScrollView: ModesoInterceptor {
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        guard let middleMan = self.middleMan else {
            guard let receiver = self.receiver else {
                return super.forwardingTarget(for: aSelector)
            }
            
            if receiver.responds(to: aSelector) {
                return receiver
            }
            return super.forwardingTarget(for: aSelector)
        }
        
        if middleMan.responds(to: aSelector) {
            return middleMan
        }
        
        guard let receiver = self.receiver else {
            return super.forwardingTarget(for: aSelector)
        }
        if receiver.responds(to: aSelector) {
            return receiver
        }
        return super.forwardingTarget(for: aSelector)
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        guard let middleMan = self.middleMan else {
            guard let receiver = self.receiver else {
                return super.responds(to: aSelector)
            }
            if receiver.responds(to: aSelector) {
                return true
            }
            return super.responds(to: aSelector)
        }
        
        if middleMan.responds(to: aSelector) {
            return true
        }
        guard let receiver = self.receiver else {
            return super.responds(to: aSelector)
        }
        if receiver.responds(to: aSelector) {
            return true
        }
        return super.responds(to: aSelector)
    }
}

class ModesoRubberBandDelegate: NSObject, UIScrollViewDelegate  {
    
    var receiver: UIScrollViewDelegate?
    fileprivate var rubberBandViews = ModesoRBCollection()
    var isDragging:Bool = false
    var location: CGPoint?
    
    init(_ receiver: UIScrollViewDelegate?) {
        self.receiver = receiver
        super.init()
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isDragging = true
        self.location = scrollView.panGestureRecognizer.location(in: scrollView)
        loadConstraints(scrollView)
        notifyDelegateWillBeginDraggin(scrollView)
    }
    
    func notifyDelegateWillBeginDraggin(_ scrollView: UIScrollView) {
        guard let delegate = self.receiver else {
            return
        }
        if (delegate.responds(to: #selector(scrollViewWillBeginDragging(_:)))) {
            delegate.scrollViewWillBeginDragging!(scrollView);
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        stretchRubberBand(scrollView)
        notifyDelegateDidScroll(scrollView)
    }
    
    func notifyDelegateDidScroll(_ scrollView: UIScrollView) {
        guard let delegate = self.receiver else {
            return
        }
        if (delegate.responds(to: #selector(scrollViewDidScroll(_:)))) {
            delegate.scrollViewDidScroll!(scrollView);
        }
    }
    
    func stretchRubberBand(_ scrollView: UIScrollView) {
        if(self.isDragging) {
            let directionUp = scrollView.panGestureRecognizer.velocity(in: scrollView).y < 0
            if directionUp {
                updateConstraintsOfViewsBelow()
            }
            if !directionUp {
                updateConstraintsOfViewsAbove()
            }
            scrollView.updateConstraintsIfNeeded()
            scrollView.layoutIfNeeded()
        }
    }
    
    fileprivate func updateConstraintsOfViewsBelow() {
        for i in 0..<rubberBandViews.getBelow().count {
            let rubberBand = rubberBandViews.getBelow()[i]
            guard let upperConstraint = rubberBand.upperConstraint else {
                continue
            }
            upperConstraint.constant = upperConstraint.constant + 0.85
            rubberBandViews.views.last?.lowerConstraint?.constant -= 0.85
        }
    }
    
    fileprivate func updateConstraintsOfViewsAbove() {
        for i in 0..<rubberBandViews.getAbove().count {
            let rubberBand = rubberBandViews.getAbove()[i]
            guard let upperConstraint = rubberBand.upperConstraint else {
                continue
            }
            upperConstraint.constant = upperConstraint.constant + 0.85
            rubberBandViews.views.last?.lowerConstraint?.constant  -= 0.85
        }
    }
    
    func rewindRubberBand(_ scrollView: UIScrollView) {
        animateViewsAboveTouch(scrollView)
        animateViewsBelowTouch(scrollView)
        updateBottomSpaceWithAnimation(scrollView)
    }
    
    func animateViewsAboveTouch(_ scrollView: UIScrollView) {
        for i in 0..<rubberBandViews.getAbove().count {
            let rubberBand = rubberBandViews.getAbove()[i]
            guard let upperConstraint = rubberBand.upperConstraint else {
                continue
            }
            upperConstraint.constant = rubberBand.upperConstraintConstant
            
            UIView.animate(withDuration: 0.1, delay: 0.075*Double(i), options: UIViewAnimationOptions.curveEaseInOut, animations: {
                scrollView.layoutIfNeeded()
            }, completion: { (ended) in
                if (ended) {}
            })
        }
    }
    
    func animateViewsBelowTouch(_ scrollView: UIScrollView) {
        for i in 0..<rubberBandViews.getBelow().count {
            let rubberBand = rubberBandViews.getBelow()[i]
            guard let upperConstraint = rubberBand.upperConstraint else {
                continue
            }
            upperConstraint.constant = rubberBand.upperConstraintConstant
            
            UIView.animate(withDuration: 0.15, delay: 0.075*Double(i), options: UIViewAnimationOptions.curveEaseInOut, animations: {
                scrollView.layoutIfNeeded()
            }, completion: { (ended) in
                if (ended) {}
            })
        }
    }
    
    func updateBottomSpaceWithAnimation(_ scrollView: UIScrollView) {
        guard let rubberBandLastView = rubberBandViews.views.last else {
            return
        }
        rubberBandLastView.lowerConstraint?.constant  = rubberBandLastView.lowerConstraintConstant
        UIView.animate(withDuration: 0.15, delay: 0.075, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            scrollView.layoutIfNeeded()
        }, completion: { (ended) in
            if (ended) {}
        })
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        self.isDragging = false
        rewindRubberBand(scrollView)
    }
    
    func loadConstraints(_ scrollView: UIScrollView) {
        rubberBandViews.clear()
        
        for i in 0..<scrollView.subviews.count-2 {
            let view = scrollView.subviews[i]
            let rubberBandView = ModesoRBView(view)
            self.rubberBandViews.append(rubberBandView)
        }
      
        for constraint in scrollView.constraints {
            
            if(constraint.firstAttribute == NSLayoutAttribute.top) {
                let rubberBandView: ModesoRBView? = rubberBandViews.getView(constraint.firstItem as? UIView)
                if rubberBandView != nil {
                    rubberBandView?.upperConstraint = constraint
                    rubberBandView?.upperConstraintConstant = constraint.constant
                }
                guard let hitLocation: CGPoint = self.location else {
                    continue
                }
                let viewLocation: CGPoint = scrollView.convert(hitLocation, to: rubberBandView?.view)
                if viewLocation.y > 0 {
                    rubberBandView?.aboveTouch = true
                }  else {
                    rubberBandView?.aboveTouch = false
                }
            }
            if(constraint.firstAttribute == NSLayoutAttribute.bottom) {
                let rubberBandView: ModesoRBView? = rubberBandViews.getView(constraint.firstItem as? UIView)
                if rubberBandView != nil {
                    rubberBandView?.lowerConstraint = constraint
                    rubberBandView?.lowerConstraintConstant = constraint.constant
                }
            }
        }
    }
}

private class ModesoRBView {
    public var view: UIView
    public var upperConstraint: NSLayoutConstraint?
    public var lowerConstraint: NSLayoutConstraint?
    public var upperConstraintConstant: CGFloat = 0.0
    public var lowerConstraintConstant: CGFloat = 0.0
    public var aboveTouch: Bool = false
    
    init(_ view: UIView) {
        self.view = view
    }
}

private struct ModesoRBCollection {
    fileprivate var views = [ModesoRBView]()
    
    init() {
        self.views = [ModesoRBView]()
    }
    
    mutating func clear() {
        self.views = [ModesoRBView]()
    }
    
    mutating func append(_ rubberBandView: ModesoRBView) {
        if(self.getView(rubberBandView.view) == nil) {
            self.views.append(rubberBandView)
        }
    }
    
    func getView(_ view: UIView?) -> ModesoRBView? {
        if view == nil {
            return nil
        }
        for rubberBandView in self.views {
            if (rubberBandView.view.isEqual(view)) {
                return rubberBandView
            }
        }
        return nil
    }
    
    func getAbove() -> [ModesoRBView] {
        var rubberBandViews =  [ModesoRBView]()
        for rubberBandView in self.views {
            if (rubberBandView.aboveTouch) {
                rubberBandViews.append(rubberBandView)
            }
        }
        return rubberBandViews
    }
    
    func getBelow() -> [ModesoRBView] {
        var rubberBandViews = [ModesoRBView]()
        for rubberBandView in self.views {
            if (!rubberBandView.aboveTouch) {
                rubberBandViews.append(rubberBandView)
            }
        }
        return rubberBandViews
    }
}
