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
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        if scrollView == viewControllersScrollView {
            
            if currentPage == Int(scrollView.contentOffset.x / viewControllersScrollView.bounds.width) {
                return
            }
            
            
            // Set font to inactivefont
            (tabsScrollView.subviews[currentPage] as? UIButton)?.backgroundColor = inactiveTabColor
            (tabsScrollView.subviews[currentPage] as? UIButton)?.titleLabel?.font = inactiveTabFont
            (tabsScrollView.subviews[currentPage] as? UIButton)?.titleLabel?.textColor = inactiveTabTextColor
            
            
            viewControllersArray[currentPage].viewWillDisappear(true)
            
            currentPage = Int(scrollView.contentOffset.x / viewControllersScrollView.bounds.width)
            
            // Set font to inactivefont
            (tabsScrollView.subviews[currentPage] as? UIButton)?.backgroundColor = activeTabColor
            (tabsScrollView.subviews[currentPage] as? UIButton)?.titleLabel?.font = activeTabFont
            (tabsScrollView.subviews[currentPage] as? UIButton)?.titleLabel?.textColor = activeTabTextColor            
            
            let currentTabOrigin: CGFloat = (CGFloat(currentPage) * navigationTabWidth) + (CGFloat(currentPage) * tabInnerMargin) + tabOuterMargin
            
            
            if currentTabOrigin + navigationTabWidth >= tabsScrollView.bounds.width + tabsScrollView.contentOffset.x {
                
                
                if Int(currentPage + 1) == viewControllersTitlesArray.count {
                    tabsScrollView.setContentOffset(CGPoint(x: tabsScrollView.contentSize.width - tabsScrollView.bounds.width, y: 0), animated: true)
                }
                else {
                    var movingStep = (CGFloat(currentPage) * navigationTabWidth) + (CGFloat(currentPage - 1) * tabInnerMargin) + tabOuterMargin
                    if movingStep > abs(tabsScrollView.contentSize.width - tabsScrollView.bounds.width) {
                        movingStep = tabsScrollView.contentOffset.x + navigationTabWidth
                    }
                    tabsScrollView.setContentOffset(CGPoint(x: movingStep, y: 0), animated: true)
                }
                
                
            } else if currentTabOrigin <= tabsScrollView.contentOffset.x {
                
                if currentPage == 0 {
                    tabsScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                } else {
                    tabsScrollView.setContentOffset(CGPoint(x: (CGFloat(currentPage) * navigationTabWidth) + (CGFloat(currentPage - 1) * tabInnerMargin) + tabOuterMargin, y: 0), animated: true)
                }
                
            }
            
            
            //Adjust indicator origin
            var indicatorFrame = indicatorView.frame
            indicatorFrame.origin.x = currentTabOrigin
            indicatorView.frame = indicatorFrame
            
            viewControllersArray[currentPage].viewWillAppear(true)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
}
