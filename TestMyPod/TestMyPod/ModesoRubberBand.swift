//
//  ModesoRubberBand.swift
//  TestMyPod
//
//  Created by Samuel Schmid on 14.08.17.
//  Copyright © 2017 Modeso. All rights reserved.
//

import UIKit

class ModesoRubberBand: UIScrollView {
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

extension ModesoRubberBand: ModesoInterceptor {
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
    fileprivate var rubberBandViews = RubberBandViews()
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
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(self.isDragging) {
            let directionUp = scrollView.panGestureRecognizer.velocity(in: scrollView).y < 0
            if directionUp {
                for i in 0..<rubberBandViews.getBelow().count {
                    let rubberBand = rubberBandViews.getBelow()[i]
                    
                    guard let upperConstraint = rubberBand.upperConstraint else {
                        continue
                    }
                    upperConstraint.constant = upperConstraint.constant + 0.85
                    rubberBandViews.childViews.last?.lowerConstraint?.constant -= 0.85
                }
            }
            if !directionUp {
                for i in 0..<rubberBandViews.getAbove().count {
                    let rubberBand = rubberBandViews.getAbove()[i]
                    guard let upperConstraint = rubberBand.upperConstraint else {
                        continue
                    }
                    upperConstraint.constant = upperConstraint.constant + 0.85
                    rubberBandViews.childViews.last?.lowerConstraint?.constant  -= 0.85
                }
            }
            
            scrollView.updateConstraintsIfNeeded()
            scrollView.layoutIfNeeded()
        }
        
        guard let delegate = self.receiver else {
            return
        }
        if (delegate.responds(to: #selector(scrollViewDidScroll(_:)))) {
            delegate.scrollViewDidScroll!(scrollView);
        }
    }
    
    func animateEnd(_ scrollView: UIScrollView) {
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
    
        guard let rubberBandLastView = rubberBandViews.childViews.last else {
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
        animateEnd(scrollView)
    }
    
    func loadConstraints(_ scrollView: UIScrollView) {
        rubberBandViews.clear()
        
        for i in 0..<scrollView.subviews.count-2 {
            let view = scrollView.subviews[i]
            let rubberBandView = RubberBandView(view)
            self.rubberBandViews.append(rubberBandView)
        }
      
        for constraint in scrollView.constraints {
            
            if(constraint.firstAttribute == NSLayoutAttribute.top) {
                let rubberBandView: RubberBandView? = rubberBandViews.getView(constraint.firstItem as? UIView)
                if rubberBandView != nil {
                    rubberBandView?.upperConstraint = constraint
                    rubberBandView?.upperConstraintConstant = constraint.constant
                }
                guard let location1: CGPoint = self.location else {
                    continue
                }
                let location2: CGPoint = scrollView.convert(location1, to: rubberBandView?.view)
                if location2.y > 0 {
                    rubberBandView?.above = true
                }  else {
                    rubberBandView?.above = false
                }
            }
            if(constraint.firstAttribute == NSLayoutAttribute.bottom) {
                let rubberBandView: RubberBandView? = rubberBandViews.getView(constraint.firstItem as? UIView)
                if rubberBandView != nil {
                    rubberBandView?.lowerConstraint = constraint
                    rubberBandView?.lowerConstraintConstant = constraint.constant
                }
               
            }
        }
    }
}

private class RubberBandView {
    public var view: UIView
    public var upperConstraint: NSLayoutConstraint?
    public var lowerConstraint: NSLayoutConstraint?
    public var upperConstraintConstant: CGFloat = 0.0
    public var lowerConstraintConstant: CGFloat = 0.0
    public var above: Bool = false
    
    init(_ view: UIView) {
        self.view = view
    }
}

private struct RubberBandViews {
    fileprivate var childViews = [RubberBandView]()
    
    init() {
        self.childViews = [RubberBandView]()
    }
    
    mutating func clear() {
        self.childViews = [RubberBandView]()
    }
    
    mutating func append(_ rubberBandView: RubberBandView) {
        if(self.getView(rubberBandView.view) == nil) {
            self.childViews.append(rubberBandView)
        }
    }
    
    func getView(_ view: UIView?) -> RubberBandView? {
        if view == nil {
            return nil
        }
        for rubberBandView in self.childViews {
            if (rubberBandView.view.isEqual(view)) {
                return rubberBandView
            }
        }
        return nil
    }
    
    func getAbove() -> [RubberBandView] {
        var rubberBandViews =  [RubberBandView]()
        for rubberBandView in self.childViews {
            if (rubberBandView.above) {
                rubberBandViews.append(rubberBandView)
            }
        }
        return rubberBandViews
    }
    
    func getBelow() -> [RubberBandView] {
        var rubberBandViews = [RubberBandView]()
        for rubberBandView in self.childViews {
            if (!rubberBandView.above) {
                rubberBandViews.append(rubberBandView)
            }
        }
        return rubberBandViews
    }
}
