//
//  ModesoNavigationTabsViewController+extension.swift
//  ModesoNavigationTabs
//
//  Created by Reem Hesham on 8/9/17.
//  Copyright © 2017 Modeso. All rights reserved.
//

import Foundation

/// used to detect current scrolling direction
extension ModesoNavigationTabsViewController {
    
    func determineScrollDirection(_ scrollView: UIScrollView) -> ScrollDirection {
        var scrollDirection: ScrollDirection
        // If the scrolling direction is changed on both X and Y it means the
        // scrolling started in one corner and goes diagonal. This will be
        // called ScrollDirectionCrazy
        if initialContentOffset.x != scrollView.contentOffset.x && initialContentOffset.y != scrollView.contentOffset.y {
            scrollDirection = .crazy
        }
        else {
            if initialContentOffset.x > scrollView.contentOffset.x {
                scrollDirection = .left
            }
            else if initialContentOffset.x < scrollView.contentOffset.x {
                scrollDirection = .right
            }
            else if initialContentOffset.y > scrollView.contentOffset.y {
                scrollDirection = .up
            }
            else if initialContentOffset.y < scrollView.contentOffset.y {
                scrollDirection = .down
            }
            else {
                scrollDirection = .none
            }
        }
        return scrollDirection
    }
    func determineScrollDirectionAxis(_ scrollView: UIScrollView) -> ScrollDirection {
        let scrollDirection = determineScrollDirection(scrollView)
        switch scrollDirection {
        case .left, .right:
            return .horizontal
        case .up, .down:
            return .vertical
        default:
            return .none
        }
    }

    /**
     Public method to scroll to current page
     
     - Parameter currentPage: Page index to navigate to.
     - Parameter isScrollDelayed: Most of the time this API is getting called right after updateUI and initialization is done, so in order to avoid conflicted animations this parameter is used. Default is `true` which will scroll to currentPage after 1 second. If you call this method after creation of the ModesoNavigationTabs and after calling updateUI() method by sometimes, set this flag to `false`
     */
    public func scrollToCurrentPage(currentPage: Int, isScrollDelayed: Bool = true) {
        
        if viewControllersScrollView.isDragging || viewControllersScrollView.isDecelerating { // Prevent scrolling in case scrollView is in move
            return
        }
        
        let time = isScrollDelayed ? 1.0 : 0.0
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            self.currentPage = currentPage
            self.startNavigating(toPage: currentPage)
        }
    }
    
    /**
     Adjust tabsScrollView ot the current selected tab
     
     - Parameter currentPage:  The current selected tab.
     - Parameter direction: optional with default 0, -1 means go to right and 1 means go to left.
     */
    
    internal func adjustTabsView(forPage currentPage:Int, direction: Int = 0) {
        
        guard let indexOfCurrentPage = mappingArray.index(of: currentPage) else {
            return
        }
        
        
        adjustTabsViewStyle()
        
        adjustCurrentTabOrigin(indexOfCurrentPage, direction: direction)
    }
    /// Shifting views to right [1,2,3,4] -> [4,1,2,3]
    public func shiftViewsToRight() {
        
        viewControllersScrollView.delegate = nil
        let length = viewControllersArray.count - 1
        var origin: CGFloat = 0.0
        viewControllersArray[length].view.frame = CGRect(x: origin, y: 0, width: viewControllersScrollView.bounds.width, height: viewControllersArray[length].view.bounds.height)
        origin += viewControllersScrollView.bounds.width
        
        for i in 0..<length  {
            viewControllersArray[i].view.frame = CGRect(x: origin, y: 0, width: viewControllersScrollView.bounds.width, height: viewControllersArray[i].view.bounds.height)
            origin += viewControllersScrollView.bounds.width
        }
        viewControllersArray.shiftRightInPlace()
        mappingArray.shiftLeftInPlace()
        viewControllersScrollView.contentOffset.x = 0
        viewControllersScrollView.delegate = self
        
    }
    /// Shifting views to left [1,2,3,4] -> [2,3,4,1]
    public func shiftViewsToLeft() {
        
        viewControllersArray.shiftLeftInPlace()
        mappingArray.shiftRightInPlace()
        
        viewControllersScrollView.delegate = nil
        
        let length = viewControllersArray.count - 1
        var origin: CGFloat = 0.0
        
        for i in 0..<length  {
            viewControllersArray[i].view.frame = CGRect(x: origin, y: 0, width: viewControllersScrollView.bounds.width, height: viewControllersArray[i].view.bounds.height)
            origin += viewControllersScrollView.bounds.width
        }
        viewControllersArray[length].view.frame = CGRect(x: origin, y: 0, width: viewControllersScrollView.bounds.width, height: viewControllersArray[length].view.bounds.height)
        viewControllersScrollView.contentOffset.x = viewControllersScrollView.bounds.width * CGFloat(length)
        viewControllersScrollView.delegate = self
    }
    
    
    //MARK:- Private APIs
    public func startNavigating(toPage currentPage: Int) {
        
        if currentPage > viewControllersTitlesArray.count - 1 || oldPage > viewControllersTitlesArray.count - 1 {
            return
        }
        
        DispatchQueue.main.async {
            self.adjustTabsView(forPage: currentPage)
        }
        
    }
    /// Reset scrollview to first/last chunk before navigating to any item in the middle chunk
    fileprivate func setScrollView(scrollView: UIScrollView, toOffset offset: CGFloat) {
        if scrollView != tabsScrollView {
            return
        }
        let count = viewControllersArray.count
        var  diff = CGFloat(count) * calculatedTabWidth + CGFloat(count) * tabInnerMargin // Must be stopped at a specific point [1,2,3,4,1,2,3,|4,1,2,3|,4]
        
        // Set delegate to nil to avoid calling delegate methods when resetting
        tabsScrollView.delegate = nil
        if offset < scrollView.contentOffset.x { // Navigate to point in the left side
            
            diff = scrollView.contentOffset.x - diff
            tabsScrollView.setContentOffset(CGPoint(x: diff, y: 0), animated: false)
        } else if offset > scrollView.contentOffset.x {
            diff = scrollView.contentOffset.x + diff
            tabsScrollView.setContentOffset(CGPoint(x: diff, y: 0), animated: false)
        }
        tabsScrollView.delegate = self
        
    }
    /// Reset tabsScrollView when user scroll so it creates teh effect of circular UISCrollView
    public func resetTabsScrollView() {
        
        let contentWidth = (CGFloat(viewControllersArray.count) * calculatedTabWidth) + (CGFloat(viewControllersArray.count - 1) * tabInnerMargin) + tabOuterMargin
        if  contentWidth <= tabsScrollView.bounds.width { // In case of all scrollable items < width of screen so same item will appear twice (1,2,3,4,1,2,3,4) appears in the screen without dragging
            handleTabsJumpDirectionForSmallTabsWidth()
            
        } else { // Normal case, (1,2,3,4) only appears and left and right bunches are out of bounds
            handleTabsJumpDirectionForNormalTabsWidth()
        }
    }
    
    public func handleScrollView(_ scrollView: UIScrollView) {
        let scrollDirection: ScrollDirection = determineScrollDirectionAxis(scrollView)
        if scrollDirection == .vertical { // User move viewcontroller itself vertically.
            handleViewControllerShadow(scrollView)
        }
        else if scrollDirection == .horizontal {
            scrollView.isPagingEnabled = true
            scrollView.contentOffset.y = 0
        }
        else if scrollDirection == .none && scrollView.contentOffset.y == 0 {
            // Hide shadow
            shadowView.alpha = 0
        }
        else {
            freezScrollView(scrollView)
        }
    }
    
    public func setupCurrentPage(_ scrollView: UIScrollView) {
        if scrollView != viewControllersScrollView {
            return
        }
        
        oldPage = currentPage
        currentPage = Int(scrollView.contentOffset.x / viewControllersScrollView.bounds.width)
        startNavigating(toPage: self.currentPage)
    }
    
    public func updateContentOffset(_ scrollView: UIScrollView) {
        if scrollView == viewControllersScrollView {
            initialContentOffset = scrollView.contentOffset // USed to get direction of scrolling
        }
    }
    
    public func handleTransitionWithDragging(_ scrollView: UIScrollView) {
        // enableCycles is true, start shuffle and reorder viewControllers
        let translation = viewControllersScrollView.panGestureRecognizer.translation(in: viewControllersScrollView.superview)
        
        if scrollView == tabsScrollView {
            resetTabsScrollView()
        }
        
        
        let length = viewControllersArray.count - 1
        if translation.x < 0 && currentPage == length { // User drag to the left, show first in the last position [1,2,3,4] -> [2,3,4,1]
            shiftViewsToRight()
        } else if translation.x > 0 && currentPage == 0 {// User drag to the right, show last in the first position [1,2,3,4] -> [4,1,2,3]
            shiftViewsToLeft()
        }
    }
    
    fileprivate func adjustCurrentTabOrigin(_ indexOfCurrentPage: Int, direction: Int) {
        
        adjustTabsViewStyle()
        
        var currentTabOrigin: CGFloat = (CGFloat(indexOfCurrentPage) * calculatedTabWidth) + (CGFloat(indexOfCurrentPage) * tabInnerMargin) + tabOuterMargin
        var indicatorFrame = indicatorView.frame
        
        if tabsBarStatus == .center { // In case of center, always center the current selected tab
            currentTabOrigin = -tabsScrollView.bounds.width * 0.5 + 0.5 * calculatedTabWidth
            currentTabOrigin += calculatedTabWidth * CGFloat(indexOfCurrentPage) + (CGFloat(indexOfCurrentPage) * tabInnerMargin) + tabInnerMargin
            tabsScrollView.setContentOffset(CGPoint(x: currentTabOrigin, y: 0), animated: true)
            
            //Adjust indicator origin
            indicatorFrame.origin.x = currentTabOrigin + tabsScrollView.bounds.width * 0.5 - indicatorFrame.size.width / 2.0
        }
        else {
            handleOutboundsCases(indexOfCurrentPage, currentTabOrigin: currentTabOrigin)
            handleInboundsCases(indexOfCurrentPage, currentTabOrigin: currentTabOrigin, direction: direction)
            //Adjust indicator origin
            indicatorFrame.origin.x = currentTabOrigin
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.indicatorView.frame = indicatorFrame
        })
    }
    
    fileprivate func handleTabsJumpDirectionForSmallTabsWidth() {
        // current position is on the left bunch, jump to right bunch
        if tabsScrollView.contentOffset.x <= (CGFloat(viewControllersArray.count - 1) * calculatedTabWidth) {
            tabsScrollView.contentOffset.x = CGFloat(viewControllersArray.count + viewControllersArray.count - 1) * calculatedTabWidth + tabInnerMargin + tabOuterMargin
        }
        else if tabsScrollView.contentOffset.x + tabsScrollView.bounds.width == tabsScrollView.contentSize.width { // current position is on the right bunch, jump to left bunch
            tabsScrollView.contentOffset.x = CGFloat(viewControllersArray.count - 1) * calculatedTabWidth + tabOuterMargin
        }
    }
    
    fileprivate func handleTabsJumpDirectionForNormalTabsWidth() {
        // current position is on the left bunch, jump to right bunch
        if tabsScrollView.contentOffset.x <= (CGFloat(viewControllersArray.count - 1) * calculatedTabWidth + CGFloat(viewControllersArray.count - 2) * tabInnerMargin + tabOuterMargin )  {
            tabsScrollView.contentOffset.x = CGFloat(viewControllersArray.count + viewControllersArray.count - 1) * calculatedTabWidth + CGFloat(viewControllersArray.count + viewControllersArray.count - 2) * tabInnerMargin + tabOuterMargin
        } else if tabsScrollView.contentOffset.x >= (CGFloat(viewControllersArray.count * 2) * calculatedTabWidth  + CGFloat(viewControllersArray.count * 2) * tabInnerMargin + tabOuterMargin) {
            tabsScrollView.contentOffset.x = CGFloat(viewControllersArray.count) * calculatedTabWidth + CGFloat(viewControllersArray.count) * tabInnerMargin + tabOuterMargin
        }
    }
    
    fileprivate func handleViewControllerShadow(_ scrollView: UIScrollView) {
        let index = mappingArray.index(of: currentPage)!
        if scrollView.subviews[index].bounds.height <= scrollView.bounds.height + tabsScrollView.bounds.height { // Do nothing if height of current viewcontroller < content height
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
        }
        
        scrollView.isPagingEnabled = false // Disable paging for vertical scrolling
        if scrollView.contentOffset.y <= 0 { //Hide shadow
            shadowView.alpha = 0
        } else { //Display shadow
            shadowView.alpha = 1
        }
    }
    
    fileprivate func freezScrollView(_ scrollView: UIScrollView) {
        // This is probably crazy movement: diagonal scrolling
        var newOffset = CGPoint.zero
        if abs(scrollView.contentOffset.x) > abs(scrollView.contentOffset.y) {
            newOffset = CGPoint(x: scrollView.contentOffset.x, y: initialContentOffset.y)
        }
        else {
            newOffset = CGPoint(x: initialContentOffset.x, y: scrollView.contentOffset.y)
        }
        // Setting the new offset to the scrollView makes it behave like a proper
        // directional lock, that allows you to scroll in only one direction at any given time
        scrollView.contentOffset = newOffset
    }
    
    fileprivate func handleOutboundsCases(_ indexOfCurrentPage: Int, currentTabOrigin: CGFloat) {
        if currentTabOrigin + calculatedTabWidth >= tabsScrollView.bounds.width + tabsScrollView.contentOffset.x { // Tab is Out of bounds of the screen
            adjustLastTab(indexOfCurrentPage, currentTabOrigin: currentTabOrigin)
            adjustScrollViewTabs(indexOfCurrentPage)
        }
    }
    
    fileprivate func handleInboundsCases(_ indexOfCurrentPage: Int, currentTabOrigin: CGFloat, direction: Int) {
        let translation = viewControllersScrollView.panGestureRecognizer.translation(in: viewControllersScrollView.superview) // Used to get scrolling direction
        if currentTabOrigin <= tabsScrollView.contentOffset.x { // Tab is small and inbound of the screen
            
            //Disable interaction to avoid conflicts in multiple taps.
            tabsScrollView.isUserInteractionEnabled = false
            // In case of enabledCycles = true, we add dummy views to the left and to the right, we start fro the end of the left dummy bunch.
            let startingIndex = CGFloat(viewControllersArray.count) * calculatedTabWidth + CGFloat(viewControllersArray.count) * tabInnerMargin
            let pointToNavigateTo = (CGFloat(indexOfCurrentPage) * calculatedTabWidth) + (CGFloat(indexOfCurrentPage) * tabInnerMargin) + startingIndex
            
            // If to jump to first page
            if indexOfCurrentPage == 0 {
                // if cycles are enabled, we check direction in which user swipes/taps. tapsScrollView and viewControllersScrollView should follow same direction in the animation.
                jumpToFirstPage(indexOfCurrentPage, direction: direction, translation: translation, pointToNavigateTo: pointToNavigateTo)
            } else {
                jumpToOtherPages(indexOfCurrentPage, direction: direction, translation: translation, pointToNavigateTo: pointToNavigateTo)
            }
        }
    }
    
    fileprivate func adjustLastTab(_ indexOfCurrentPage: Int, currentTabOrigin: CGFloat) {
        if Int(indexOfCurrentPage + 1) == viewControllersTitlesArray.count { // Last tab
            if calculatedTabWidth == tabsScrollView.bounds.width { // if last tab width exactly equal current tabsScrollView width
                tabsScrollView.setContentOffset(CGPoint(x: currentTabOrigin, y: 0), animated: true)
            } else { // last tab will be adjusted to have tabOuterMargin to the right
                tabsScrollView.setContentOffset(CGPoint(x: tabsScrollView.contentSize.width - tabsScrollView.bounds.width, y: 0), animated: true)
            }
        }
    }
    
    fileprivate func adjustScrollViewTabs(_ indexOfCurrentPage: Int) {
        // Any other tab
        if Int(indexOfCurrentPage + 1) == viewControllersTitlesArray.count {
            return
        }        
        var movingStep = (CGFloat(indexOfCurrentPage) * calculatedTabWidth) + (CGFloat(indexOfCurrentPage - 1) * tabInnerMargin) + tabOuterMargin
        if movingStep > abs(tabsScrollView.contentSize.width - tabsScrollView.bounds.width) {
            movingStep = tabsScrollView.contentOffset.x + calculatedTabWidth
        }
        tabsScrollView.setContentOffset(CGPoint(x: movingStep, y: 0), animated: true)
    }
    
    fileprivate func jumpToFirstPage(_ indexOfCurrentPage: Int, direction: Int, translation: CGPoint, pointToNavigateTo: CGFloat) {
        
        if enableCycles {
            // User drag/scroll to the right, we reset tabsScrollView to animate from dummy bunch to the center bunch
            if (direction == 0 && translation.x < 0) || direction == -1 {
                setScrollView(scrollView: tabsScrollView, toOffset: pointToNavigateTo)
            }
            
            // Start animate to center bunch.
            UIView.animate(withDuration: 0.3, animations: { //walkaround as setContentOffset with Animation causes unexpected behavior sometimes.
                self.tabsScrollView.contentOffset.x = pointToNavigateTo
            }, completion: { _ in
                self.tabsScrollView.isUserInteractionEnabled = true
            })
        }
        else { // enableCycle = false, simply animate to (0,0)
            tabsScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            self.tabsScrollView.isUserInteractionEnabled = true
        }
    }
    
    fileprivate func jumpToOtherPages(_ indexOfCurrentPage: Int, direction: Int, translation: CGPoint, pointToNavigateTo: CGFloat) {
        // jump to any other page.
        if !enableCycles {
            // if enableCycle = false, simply scroll to current selected index.
            tabsScrollView.setContentOffset(CGPoint(x: (CGFloat(indexOfCurrentPage) * calculatedTabWidth) + (CGFloat(indexOfCurrentPage - 1) * tabInnerMargin) + tabOuterMargin, y: 0), animated: true)
            self.tabsScrollView.isUserInteractionEnabled = true
            return
        }
        // user in the last page and scrolls/drags to the left
        if (direction == 0 && indexOfCurrentPage == viewControllersArray.count - 1 && translation.x > 0) || (direction == 1 && indexOfCurrentPage == viewControllersArray.count - 1) {
            setScrollView(scrollView: tabsScrollView, toOffset: pointToNavigateTo)
        }
        
        // Animate to the middle bunch
        UIView.animate(withDuration: 0.3, animations: { //walkaround as setContentOffset with Animation causes unexpected behavior sometimes.
            self.tabsScrollView.contentOffset.x = pointToNavigateTo
        }, completion: { _ in
            self.tabsScrollView.isUserInteractionEnabled = true
        })
    }
}
