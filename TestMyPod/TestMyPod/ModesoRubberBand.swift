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
    var animateConstraint = [NSLayoutConstraint]()
    var animateConstraintConstants = [CGFloat]()
    var aConstraint: NSLayoutConstraint?
    var aConstraintConstatn: CGFloat = 0.0
    var bottomConstraint: NSLayoutConstraint?
    var bottomConstraintConstant: CGFloat = 0.0
    var offsetBefore:CGFloat = 0.0
    var flag: Bool = false
    
    init(_ receiver: UIScrollViewDelegate?) {
        self.receiver = receiver
        self.cheight = 0.0
        super.init()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       // print("scrollviewDid Scroll Middleman ")
        if(flag) {
            if (scrollView.contentOffset.y >= offsetBefore) {
                for i in 1..<animateConstraint.count-2 {
                    animateConstraint[i].constant = animateConstraint[i].constant + 0.65
                    bottomConstraint?.constant -= 0.65
                }
            } else {
                for i in 1..<animateConstraint.count-2 {
                    animateConstraint[i].constant = animateConstraint[i].constant - 0.45
                    bottomConstraint?.constant += 0.45
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
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging Scroll Middleman")
        self.flag = true
        self.cheight = scrollView.contentSize.height
        loadConstraints(scrollView)
        
        //animateStart(scrollView)
        /*guard let delegate = self.receiver else {
            return
        }
        if (delegate.responds(to: #selector(scrollViewWillBeginDragging(_:)))) {
            delegate.scrollViewWillBeginDragging!(scrollView);
        }*/
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
        for i in 1..<animateConstraint.count-1 {
            animateConstraint[i].constant = animateConstraintConstants[i]
            bottomConstraint?.constant = bottomConstraintConstant
         
            UIView.animate(withDuration: 0.1, delay: 0.075*Double(i), options: UIViewAnimationOptions.curveEaseInOut, animations: {
                scrollView.layoutIfNeeded()
            }, completion: { (ended) in
                if (ended) {}
            })
        }
    }
    
    func loadConstraints(_ scrollView: UIScrollView) {

        animateConstraint = [NSLayoutConstraint]()
        animateConstraintConstants = [CGFloat]()
      
        for constraint in scrollView.constraints {
            
            if(constraint.firstAttribute == NSLayoutAttribute.top) {
                
                animateConstraint.append(constraint)
                animateConstraintConstants.append(constraint.constant)
                aConstraint = constraint
                aConstraintConstatn = constraint.constant
            }
            if(constraint.firstAttribute == NSLayoutAttribute.bottom) {
             
                animateConstraint.append(constraint)
                animateConstraintConstants.append(constraint.constant)
                bottomConstraint = constraint
                bottomConstraintConstant = constraint.constant
            }
        }
    }
}
