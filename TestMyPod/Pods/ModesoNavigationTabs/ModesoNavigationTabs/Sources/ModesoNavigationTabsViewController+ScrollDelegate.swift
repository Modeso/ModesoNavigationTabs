//
//  ModesoNavigationTabsViewController+ScrollDelegate.swift
//  ModesoNavigationTabs
//
//  Created by Mohammed Elsammak on 3/24/17.
//  Copyright © 2017 Modeso. All rights reserved.
//

import Foundation

extension ModesoNavigationTabsViewController: UIScrollViewDelegate {
    
    // MARK: - UIScrollView Methods
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tabsScrollView && enableCycles { // Reset tabsScrollView to give the illusion of infinite scrollview.
            resetTabsScrollView()
            shadowView.alpha = 0
        } else if scrollView == viewControllersScrollView {

            handleScrollView(scrollView)

        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == tabsScrollView { // Re-enable userInteraction after tabsscrollview stops animation, this is being done to avoid conflicts in animation/tapping.
            scrollView.isUserInteractionEnabled = true
        }
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setupCurrentPage(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

        if !enableCycles {
            if scrollView == viewControllersScrollView {
                
                oldPage = currentPage
                currentPage = Int(scrollView.contentOffset.x / viewControllersScrollView.bounds.width)
                startNavigating(toPage: self.currentPage)
            }
            return
        }
        

        handleTransitionWithDragging(scrollView)
    }
}
