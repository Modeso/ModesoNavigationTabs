//
//  MNavigationTabsViewController+ScrollDelegate.swift
//  MNavigationTabs
//
//  Created by Mohammed Elsammak on 3/24/17.
//  Copyright © 2017 Modeso. All rights reserved.
//

import Foundation
extension MNavigationTabsViewController: UIScrollViewDelegate {
    
    // MARK: - UIScrollView Methods
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tabsScrollView && enableCycles {

            let contentWidth = (CGFloat(viewControllersArray.count) * calculatedTabWidth) + (CGFloat(viewControllersArray.count - 1) * tabInnerMargin) + tabOuterMargin
            if  contentWidth <= tabsScrollView.bounds.width {
            
                if scrollView.contentOffset.x <= (CGFloat(viewControllersArray.count - 1) * calculatedTabWidth) {
                    scrollView.contentOffset.x = CGFloat(viewControllersArray.count + viewControllersArray.count - 1) * calculatedTabWidth + tabInnerMargin + tabOuterMargin
                }
                else if scrollView.contentOffset.x + tabsScrollView.bounds.width == tabsScrollView.contentSize.width {
                    scrollView.contentOffset.x = CGFloat(viewControllersArray.count - 1) * calculatedTabWidth + tabOuterMargin
                }
            } else {
            
                if scrollView.contentOffset.x <= (CGFloat(viewControllersArray.count - 1) * calculatedTabWidth + CGFloat(viewControllersArray.count - 2) * tabInnerMargin + tabOuterMargin )  {
                    scrollView.contentOffset.x = CGFloat(viewControllersArray.count + viewControllersArray.count - 1) * calculatedTabWidth + CGFloat(viewControllersArray.count + viewControllersArray.count - 2) * tabInnerMargin + tabOuterMargin
                } else if scrollView.contentOffset.x >= (CGFloat(viewControllersArray.count * 2) * calculatedTabWidth  + CGFloat(viewControllersArray.count * 2) * tabInnerMargin + tabOuterMargin) {
                    scrollView.contentOffset.x = CGFloat(viewControllersArray.count) * calculatedTabWidth + CGFloat(viewControllersArray.count) * tabInnerMargin + tabOuterMargin
                }
            }
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !isChangingOrientation {
            if scrollView != viewControllersScrollView {
                return
            }
            
            oldPage = currentPage
            currentPage = Int(scrollView.contentOffset.x / viewControllersScrollView.bounds.width)
            startNavigating(toPage: currentPage)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        if !enableCycles {
            return
        }
        
        let translation = viewControllersScrollView.panGestureRecognizer.translation(in: viewControllersScrollView.superview)
        
        
        if scrollView == tabsScrollView {
            
            let contentWidth = (CGFloat(viewControllersArray.count) * calculatedTabWidth) + (CGFloat(viewControllersArray.count - 1) * tabInnerMargin) + tabOuterMargin
            if  contentWidth <= tabsScrollView.bounds.width {
                
                if scrollView.contentOffset.x <= (CGFloat(viewControllersArray.count - 1) * calculatedTabWidth) {
                    scrollView.contentOffset.x = CGFloat(viewControllersArray.count + viewControllersArray.count - 1) * calculatedTabWidth + tabInnerMargin + tabOuterMargin
                }
                else if scrollView.contentOffset.x + tabsScrollView.bounds.width == tabsScrollView.contentSize.width {
                    scrollView.contentOffset.x = CGFloat(viewControllersArray.count - 1) * calculatedTabWidth + tabOuterMargin
                }
            } else {
                
                if scrollView.contentOffset.x <= (CGFloat(viewControllersArray.count - 1) * calculatedTabWidth + CGFloat(viewControllersArray.count - 2) * tabInnerMargin + tabOuterMargin )  {
                    scrollView.contentOffset.x = CGFloat(viewControllersArray.count + viewControllersArray.count - 1) * calculatedTabWidth + CGFloat(viewControllersArray.count + viewControllersArray.count - 2) * tabInnerMargin + tabOuterMargin
                } else if scrollView.contentOffset.x >= (CGFloat(viewControllersArray.count * 2) * calculatedTabWidth  + CGFloat(viewControllersArray.count * 2) * tabInnerMargin + tabOuterMargin) {
                    scrollView.contentOffset.x = CGFloat(viewControllersArray.count) * calculatedTabWidth + CGFloat(viewControllersArray.count) * tabInnerMargin + tabOuterMargin
                }
            }
        } else {
            let currentIndex = mappingArray.index(of: currentPage)!
            var scrollBounds = tabsScrollView.bounds
            if  currentIndex == viewControllersArray.count - 1 && translation.x < 0 {
                scrollBounds.origin = CGPoint(x: CGFloat(viewControllersArray.count - 1) * calculatedTabWidth + CGFloat(viewControllersArray.count - 1) * tabInnerMargin + tabOuterMargin, y: 0)
            } else if currentIndex == 0 && translation.x > 0{
                scrollBounds.origin = CGPoint(x: CGFloat(viewControllersArray.count * 2) * calculatedTabWidth + CGFloat(viewControllersArray.count * 2) * tabInnerMargin + tabOuterMargin, y: 0)
            }
            tabsScrollView.bounds = scrollBounds
            
        }

        
        
        
        let length = viewControllersArray.count - 1
        if translation.x < 0 && currentPage == length { //drag to the left, show first in the last
            
            shiftViewsToRight()
            
        } else if translation.x > 0 && currentPage == 0 {
            
            shiftViewsToLeft()
            
        }
        
    }
    
    public func scrollToCurrentPage(currentPage: Int) {
        
        if viewControllersScrollView.isDragging || viewControllersScrollView.isDecelerating {
            return
        }
        startNavigating(toPage: currentPage)
        
    }
    
    fileprivate func startNavigating(toPage currentPage: Int) {
        
        if currentPage > viewControllersTitlesArray.count - 1 || oldPage > viewControllersTitlesArray.count - 1 {
            return
        }
        
        
        if Int(viewControllersScrollView.contentOffset.x / viewControllersScrollView.bounds.width) < currentPage {
            viewControllersScrollView.contentOffset.x = CGFloat(currentPage) * viewControllersScrollView.bounds.width
        }
        
        adjustTabsView(forPage: currentPage)
        
    }
    
    public func adjustTabsView(forPage currentPage:Int) {
       
        
        var indexOfCurrentPage = mappingArray.index(of: currentPage)!
        
        // Set font to inactivefont
        for view in tabsScrollView.subviews {
            (view as? UIButton)?.backgroundColor = inactiveTabColor
            (view as? UIButton)?.titleLabel?.font = inactiveTabFont
            (view as? UIButton)?.titleLabel?.textColor = inactiveTabTextColor
            
            if enableResizingAnimated {
                UIView.animate(withDuration: 0.2, animations: {
                    view.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
                })
            }
            
        }
        
        // Set font to activefont
        let activeArr = tabsScrollView.subviews.filter{ $0.tag == indexOfCurrentPage }
        for activeView in activeArr {
         
            (activeView as? UIButton)?.backgroundColor = activeTabColor
            (activeView as? UIButton)?.titleLabel?.font = activeTabFont
            (activeView as? UIButton)?.titleLabel?.textColor = activeTabTextColor
            
            if enableResizingAnimated {
                UIView.animate(withDuration: 0.2, animations: {
                    activeView.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
                })
            }
        }
        
        
        var currentTabOrigin: CGFloat = (CGFloat(indexOfCurrentPage) * calculatedTabWidth) + (CGFloat(indexOfCurrentPage) * tabInnerMargin) + tabOuterMargin
        var indicatorFrame = indicatorView.frame
        
        if tabsBarStatus == .center {
            currentTabOrigin = -tabsScrollView.bounds.width * 0.5 + 0.5 * calculatedTabWidth
            currentTabOrigin += calculatedTabWidth * CGFloat(indexOfCurrentPage) + (CGFloat(indexOfCurrentPage) * tabInnerMargin) + tabInnerMargin
            tabsScrollView.setContentOffset(CGPoint(x: currentTabOrigin, y: 0), animated: true)
            
            //Adjust indicator origin
            indicatorFrame.origin.x = currentTabOrigin + tabsScrollView.bounds.width * 0.5 - indicatorFrame.size.width / 2.0
        }
        else {
            if currentTabOrigin + calculatedTabWidth >= tabsScrollView.bounds.width + tabsScrollView.contentOffset.x {
                
                
                if Int(indexOfCurrentPage + 1) == viewControllersTitlesArray.count {
                    if calculatedTabWidth == tabsScrollView.bounds.width {
                        tabsScrollView.setContentOffset(CGPoint(x: currentTabOrigin, y: 0), animated: true)
                    } else {
                        tabsScrollView.setContentOffset(CGPoint(x: tabsScrollView.contentSize.width - tabsScrollView.bounds.width, y: 0), animated: true)
                    }
                    
                }
                else {
                    var movingStep = (CGFloat(indexOfCurrentPage) * calculatedTabWidth) + (CGFloat(indexOfCurrentPage - 1) * tabInnerMargin) + tabOuterMargin
                    if movingStep > abs(tabsScrollView.contentSize.width - tabsScrollView.bounds.width) {
                        movingStep = tabsScrollView.contentOffset.x + calculatedTabWidth
                    }
                    tabsScrollView.setContentOffset(CGPoint(x: movingStep, y: 0), animated: true)
                }
                
                
            } else if currentTabOrigin <= tabsScrollView.contentOffset.x {
                
                if indexOfCurrentPage == 0 {
                    if enableCycles {
                        let startingIndex = CGFloat(viewControllersArray.count) * calculatedTabWidth + CGFloat(viewControllersArray.count - 1) * tabInnerMargin + 2 * tabOuterMargin
                        tabsScrollView.setContentOffset(CGPoint(x: (CGFloat(indexOfCurrentPage) * calculatedTabWidth) + (CGFloat(indexOfCurrentPage - 1) * tabInnerMargin) + tabOuterMargin + startingIndex, y: 0), animated: true)
                    }
                    else {
                        tabsScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                    }
                    
                } else {
                    if enableCycles {
                        
                        let startingIndex = CGFloat(viewControllersArray.count) * calculatedTabWidth + CGFloat(viewControllersArray.count - 1) * tabInnerMargin + 2 * tabOuterMargin
                        tabsScrollView.setContentOffset(CGPoint(x: (CGFloat(indexOfCurrentPage) * calculatedTabWidth) + (CGFloat(indexOfCurrentPage - 1) * tabInnerMargin) + tabOuterMargin + startingIndex, y: 0), animated: true)
                        
                    } else {
                        tabsScrollView.setContentOffset(CGPoint(x: (CGFloat(indexOfCurrentPage) * calculatedTabWidth) + (CGFloat(indexOfCurrentPage - 1) * tabInnerMargin) + tabOuterMargin, y: 0), animated: true)
                    }
                    
                }
            }
            
            //Adjust indicator origin
            indicatorFrame.origin.x = currentTabOrigin
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.indicatorView.frame = indicatorFrame
        })
        
    }
    
    fileprivate func shiftViewsToRight() {
        
        viewControllersScrollView.delegate = nil
        let length = viewControllersArray.count - 1
        var origin: CGFloat = 0.0
        viewControllersArray[length].view.frame = CGRect(x: origin, y: 0, width: viewControllersScrollView.bounds.width, height: viewControllersScrollView.bounds.height)
        origin += viewControllersScrollView.bounds.width
        
        for i in 0..<length  {
            viewControllersArray[i].view.frame = CGRect(x: origin, y: 0, width: viewControllersScrollView.bounds.width, height: viewControllersScrollView.bounds.height)
            origin += viewControllersScrollView.bounds.width
        }
        viewControllersArray.shiftRightInPlace()
        mappingArray.shiftLeftInPlace()
        
        viewControllersScrollView.contentOffset.x = 0
        
        viewControllersScrollView.delegate = self
        
    }
    
    fileprivate func shiftViewsToLeft() {
        
        viewControllersArray.shiftLeftInPlace()
        mappingArray.shiftRightInPlace()
        
        viewControllersScrollView.delegate = nil
        
        let length = viewControllersArray.count - 1
        var origin: CGFloat = 0.0
        
        for i in 0..<length  {
            viewControllersArray[i].view.frame = CGRect(x: origin, y: 0, width: viewControllersScrollView.bounds.width, height: viewControllersScrollView.bounds.height)
            origin += viewControllersScrollView.bounds.width
        }
        
        
        viewControllersArray[length].view.frame = CGRect(x: origin, y: 0, width: viewControllersScrollView.bounds.width, height: viewControllersScrollView.bounds.height)
        
        viewControllersScrollView.contentOffset.x = viewControllersScrollView.bounds.width * CGFloat(length)
        
        viewControllersScrollView.delegate = self
    }
    
}


extension Array {
    func shiftLeft() -> [Element] {
        return Array(self[1 ..< count] + [self[0]])
    }
    
    func shiftRight() -> [Element] {
        return Array([self[count - 1]] + self[0 ..< count - 1])
    }
    
    mutating func shiftRightInPlace() {
        self = shiftRight()
    }
    
    mutating func shiftLeftInPlace() {
        self = shiftLeft()
    }
}
