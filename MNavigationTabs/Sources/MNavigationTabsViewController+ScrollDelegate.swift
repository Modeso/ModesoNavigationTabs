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
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == viewControllersScrollView {

            let currentPage = scrollView.contentOffset.x / viewControllerWidth
            let currentTabOrigin: CGFloat = (CGFloat(currentPage) * tabWidth) + (CGFloat(currentPage) * tabsInbetweenMargin) + tabLeadingTrailingMargin
            
            tabsScrollView.setContentOffset(CGPoint(x: currentTabOrigin, y: 0), animated: true)
            
            //Adjust indicator origin
            var indicatorFrame = indicatorView.frame
            indicatorFrame.origin.x = currentTabOrigin
            indicatorView.frame = indicatorFrame
        }
    }    
}
