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
            
        if scrollView != viewControllersScrollView || currentPage == Int(scrollView.contentOffset.x / viewControllersScrollView.bounds.width) {
            return
        }
        // TODO:- Please fix orientation because it causes wrong page to appear
        if !isChangingOrientation {
            oldPage = currentPage
            currentPage = Int(scrollView.contentOffset.x / viewControllersScrollView.bounds.width)
            
            scrollToCurrentPage(currentPage: currentPage)

        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }

    public func scrollToCurrentPage(currentPage: Int) {
        
        if currentPage > viewControllersTitlesArray.count - 1 || oldPage > viewControllersTitlesArray.count - 1 {
            return
        }
        if Int(viewControllersScrollView.contentOffset.x / viewControllersScrollView.bounds.width) < currentPage {
            viewControllersScrollView.contentOffset.x = CGFloat(currentPage) * viewControllersScrollView.bounds.width
        }
        // Set font to inactivefont
        (tabsScrollView.subviews[oldPage] as? UIButton)?.backgroundColor = inactiveTabColor
        (tabsScrollView.subviews[oldPage] as? UIButton)?.titleLabel?.font = inactiveTabFont
        (tabsScrollView.subviews[oldPage] as? UIButton)?.titleLabel?.textColor = inactiveTabTextColor
        
        
        viewControllersArray[oldPage].viewWillDisappear(true)
        // Set font to inactivefont
        (tabsScrollView.subviews[currentPage] as? UIButton)?.backgroundColor = activeTabColor
        (tabsScrollView.subviews[currentPage] as? UIButton)?.titleLabel?.font = activeTabFont
        (tabsScrollView.subviews[currentPage] as? UIButton)?.titleLabel?.textColor = activeTabTextColor
        
        var currentTabOrigin: CGFloat = (CGFloat(currentPage) * calculatedTabWidth) + (CGFloat(currentPage) * tabInnerMargin) + tabOuterMargin
        var indicatorFrame = indicatorView.frame
        
        if tabsBarStatus == .center {
            currentTabOrigin = -tabsScrollView.bounds.width * 0.5 + 0.5 * calculatedTabWidth
            currentTabOrigin += calculatedTabWidth * CGFloat(currentPage) + (CGFloat(currentPage) * tabInnerMargin) + tabInnerMargin
            tabsScrollView.setContentOffset(CGPoint(x: currentTabOrigin, y: 0), animated: true)
            
            //Adjust indicator origin
            indicatorFrame.origin.x = currentTabOrigin + tabsScrollView.bounds.width * 0.5 - indicatorFrame.size.width / 2.0
        }
        else {
            if currentTabOrigin + calculatedTabWidth >= tabsScrollView.bounds.width + tabsScrollView.contentOffset.x {
                
                
                if Int(currentPage + 1) == viewControllersTitlesArray.count {
                    tabsScrollView.setContentOffset(CGPoint(x: tabsScrollView.contentSize.width - tabsScrollView.bounds.width, y: 0), animated: true)
                }
                else {
                    var movingStep = (CGFloat(currentPage) * calculatedTabWidth) + (CGFloat(currentPage - 1) * tabInnerMargin) + tabOuterMargin
                    if movingStep > abs(tabsScrollView.contentSize.width - tabsScrollView.bounds.width) {
                        movingStep = tabsScrollView.contentOffset.x + calculatedTabWidth
                    }
                    tabsScrollView.setContentOffset(CGPoint(x: movingStep, y: 0), animated: true)
                }
                
                
            } else if currentTabOrigin <= tabsScrollView.contentOffset.x {
                
                if currentPage == 0 {
                    tabsScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                } else {
                    tabsScrollView.setContentOffset(CGPoint(x: (CGFloat(currentPage) * calculatedTabWidth) + (CGFloat(currentPage - 1) * tabInnerMargin) + tabOuterMargin, y: 0), animated: true)
                }
            }
            
            //Adjust indicator origin
            indicatorFrame.origin.x = currentTabOrigin
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.indicatorView.frame = indicatorFrame
        })
        viewControllersArray[currentPage].viewWillAppear(true)
    }

}
