//
//  ModesoRubberBand.swift
//  TestMyPod
//
//  Created by Samuel Schmid on 14.08.17.
//  Copyright © 2017 Modeso. All rights reserved.
//

import UIKit

class ModesoRubberBand: UIScrollView {
    
    var cheight: Float
    var receiver: UIScrollViewDelegate?
    var middleMan: UIScrollViewDelegate?
    
    override func awakeFromNib() {
        self.receiver = self.delegate
        self.middleMan = ModesoRubberBandDelegate(self.receiver);
        self.delegate = self.middleMan
    }
    
    override init(frame: CGRect) {
        self.cheight = 0.0
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.cheight = 0.0
        super.init(coder: aDecoder)
    }
   

    open override func adjustedContentInsetDidChange() {
        if #available(iOS 11.0, *) {
            super.adjustedContentInsetDidChange()
        } else {
            // Fallback on earlier versions
        }
    }
    
    func calculateHeight() {
        
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

class ModesoRubberBandDelegate: NSObject, UIScrollViewDelegate {
    
    var receiver: UIScrollViewDelegate?
    
    init(_ receiver: UIScrollViewDelegate?) {
        self.receiver = receiver
        super.init()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollviewDid Scroll Middleman")
        guard let delegate = self.receiver else {
            return
        }
        if (delegate.responds(to: #selector(scrollViewDidScroll(_:)))) {
            delegate.scrollViewDidScroll!(scrollView);
        }
    }
}
