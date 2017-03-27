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
            viewControllersArray[currentPage].viewWillDisappear(true)
            
            currentPage = Int(scrollView.contentOffset.x / viewControllersScrollView.bounds.width)
            let currentTabOrigin: CGFloat = (CGFloat(currentPage) * tabWidth) + (CGFloat(currentPage) * tabInnerMargin) + tabOuterMargin
            
            
            if currentTabOrigin + tabWidth >= tabsScrollView.bounds.width + tabsScrollView.contentOffset.x {
                
                
                if Int(currentPage + 1) == viewControllersTitlesArray.count {
                    tabsScrollView.setContentOffset(CGPoint(x: tabsScrollView.contentSize.width - tabsScrollView.bounds.width, y: 0), animated: true)
                }
                else {
                    var movingStep = (CGFloat(currentPage) * tabWidth) + (CGFloat(currentPage - 1) * tabInnerMargin) + tabOuterMargin
                    if movingStep > abs(tabsScrollView.contentSize.width - tabsScrollView.bounds.width) {
                        movingStep = tabsScrollView.contentOffset.x + tabWidth
                    }
                    tabsScrollView.setContentOffset(CGPoint(x: movingStep, y: 0), animated: true)
                }
                
                
            } else if currentTabOrigin <= tabsScrollView.contentOffset.x {
                
                if currentPage == 0 {
                    tabsScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                } else {
                    tabsScrollView.setContentOffset(CGPoint(x: (CGFloat(currentPage) * tabWidth) + (CGFloat(currentPage - 1) * tabInnerMargin) + tabOuterMargin, y: 0), animated: true)
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
