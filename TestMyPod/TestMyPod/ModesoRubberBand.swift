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
   

    open override func adjustedContentInsetDidChange() {
        if #available(iOS 11.0, *) {
            super.adjustedContentInsetDidChange()
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        guard let middleMan = self.middleMan else {
            guard let receiver = self.receiver else {
                return super.forwardingTarget(for: aSelector)
            }
            
            if (receiver.responds(to: aSelector)) {
                return receiver
            }
            return super.forwardingTarget(for: aSelector)
        }
        
        if (middleMan.responds(to: aSelector)) {
            return middleMan
        }
        guard let receiver = self.receiver else {
            return super.forwardingTarget(for: aSelector)
        }
        
        if (receiver.responds(to: aSelector)) {
            return receiver
        }
        return super.forwardingTarget(for: aSelector)
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        guard let middleMan = self.middleMan else {
            guard let receiver = self.receiver else {
                return super.responds(to: aSelector)
            }
            
            if (receiver.responds(to: aSelector)) {
                return true
            }
            return super.responds(to: aSelector)
        }
        
        if (middleMan.responds(to: aSelector)) {
            return true
        }
        guard let receiver = self.receiver else {
            return super.responds(to: aSelector)
        }
        
        if (receiver.responds(to: aSelector)) {
            return true
        }
        return super.responds(to: aSelector)
    }
}

extension ModesoRubberBand: UIGestureRecognizerDelegate {
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        print("gestureRecognizerShouldBegin")
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
         print("setContentOffset")
        super.setContentOffset(contentOffset, animated: animated)
    }
}

class ModesoRubberBandDelegate: NSObject, UIGestureRecognizerDelegate, UIScrollViewDelegate  {
    
    var cheight: CGFloat
    var receiver: UIScrollViewDelegate?
    fileprivate var rubberBandViews = RubberBandViews()
    var offsetBefore:CGFloat = 0.0
    var flag: Bool = false
    var location: CGPoint?
    
    init(_ receiver: UIScrollViewDelegate?) {
        self.receiver = receiver
        self.cheight = 0.0
        super.init()
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging Scroll Middleman")
        self.flag = true
        self.cheight = scrollView.contentSize.height
        self.location = scrollView.panGestureRecognizer.location(in: scrollView.superview)
        loadConstraints(scrollView)
        
        //animateStart(scrollView)
        /*guard let delegate = self.receiver else {
         return
         }
         if (delegate.responds(to: #selector(scrollViewWillBeginDragging(_:)))) {
         delegate.scrollViewWillBeginDragging!(scrollView);
         }*/
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       // print("scrollviewDid Scroll Middleman ")
        if(flag) {
            if (scrollView.contentOffset.y >= offsetBefore) {
                for i in 1..<rubberBandViews.childViews.count-2 {
                    let rubberBand = rubberBandViews.childViews[i]
                    
                    guard let upperConstraint = rubberBand.upperConstraint else {
                        continue
                    }
                    upperConstraint.constant = upperConstraint.constant + 0.65
                    
                    
                    rubberBandViews.childViews.last?.lowerConstraint?.constant -= 0.65
                }
            } else {
                for i in 1..<rubberBandViews.childViews.count-2 {
                    let rubberBand = rubberBandViews.childViews[i]
                    guard let upperConstraint = rubberBand.upperConstraint else {
                        continue
                    }
                    upperConstraint.constant = upperConstraint.constant - 0.45
                    
                    rubberBandViews.childViews.last?.lowerConstraint?.constant  += 0.45
                }
            }
            scrollView.updateConstraintsIfNeeded()
            scrollView.layoutIfNeeded()
            offsetBefore = scrollView.contentOffset.y
        }
        
        guard let delegate = self.receiver else {
            return
        }
        if (delegate.responds(to: #selector(scrollViewDidScroll(_:)))) {
            delegate.scrollViewDidScroll!(scrollView);
        }
    }
    
    
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        print("scrollViewWillEndDragging Scroll Middleman")
        flag = false
        animateEnd(scrollView)
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        print("scrollViewDidZoom")
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging")
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDecelerating")
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("scrollViewDidEndScrollingAnimation")
    }

    
    func animateEnd(_ scrollView: UIScrollView) {
        for i in 1..<rubberBandViews.childViews.count-2  {
            let rubberBand = rubberBandViews.childViews[i]
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
        guard let rubberBandLastView = rubberBandViews.childViews.last else {
            return
        }
        rubberBandLastView.lowerConstraint?.constant  = rubberBandLastView.lowerConstraintConstant
        UIView.animate(withDuration: 0.1, delay: 0.075, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            scrollView.layoutIfNeeded()
        }, completion: { (ended) in
            if (ended) {}
        })
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
    public var location: CGPoint?
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
}
