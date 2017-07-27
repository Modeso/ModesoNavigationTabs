//
//  MNavigationTabsViewController.swift
//  MNavigationTabs
//
//  Created by Mohammed Elsammak on 3/22/17.
//  Copyright © 2017 Modeso. All rights reserved.
//

import UIKit
public enum TabsScrollStatus: Int {
    case fixed
    case scrollable
    case fit
    case center
}
public class MNavigationTabsViewController: UIViewController {
    
    /// Single tab width
    public var navigationTabWidth: CGFloat = 111.0
    /// Calculated tab width
    public var calculatedTabWidth: CGFloat = 111.0
    /// Tab Colors
    public var activeTabColor: UIColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
    public var inactiveTabColor: UIColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
    /// Active tab text color
    public var activeTabTextColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    /// Inactive tab text color
    public var inactiveTabTextColor: UIColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
    /// Margin between two tabs
    public var tabInnerMargin: CGFloat = 10.0
    /// Leading and Trailing margin of the first and last tab
    public var tabOuterMargin: CGFloat = 10.0
    /// Tab indicator height
    public var indicatorViewHeight: CGFloat = 5.0
    /// Tab indicator color
    public var indicatorColor: UIColor = #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
    /// Navigation bar height
    public var navigationBarHeight: CGFloat = 33
    /// Single tab height
    public var navigationTabHeight: CGFloat = 33
    /// Tabs corner radius
    public var tabsCornerRadius: CGFloat = 0
    /// Navigation bar color
    public var navigationBarColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    /// ScrollView nackground color
    public var scrollViewBackgroundColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) {
        didSet {
            if viewControllersScrollView != nil {
                viewControllersScrollView.backgroundColor = scrollViewBackgroundColor
            }
        }
    }
    
    /// Bounce viewcontrollers
    public var enableBounce: Bool = false
    
    /// infinite viewcontrollers
    public var enableCycles: Bool = false
    
    /// Allow tabs resizing with animation
    public var enableResizingAnimated: Bool = false
    
    /**
     * State of the Navigation tabs views.
     * fixed: Navigation tabs will use tabWidth property and extend beyond screen bounds without scrolling ability.
     * scrollable: Navigation tabs will use tabWidth property and extend beyond screen bounds with scrolling ability.
     * fit: Navigation tabs will adjust its width so all tabs fit in a single screen without scrolling ability.
     *
     **/
    public var tabsBarStatus: TabsScrollStatus = .fit
    
    /// ViewControllers array to switch between them.
    public var viewControllersArray: [UIViewController] = []
    /// Titles array to use it in tabs navigation bar.
    public var viewControllersTitlesArray: [NSAttributedString] = []
    /// Single Tab font
    public var inactiveTabFont: UIFont = UIFont.systemFont(ofSize: 12)
    public var activeTabFont: UIFont = UIFont.systemFont(ofSize: 12)
    
    /// A small view appears on the current active tab
    internal var indicatorView: UIView!
    internal var currentPage: Int = 0
    internal var oldPage: Int = 0
    internal var viewIsSetup = false
    /// Orientation is not supporting in the library and it causes issues that it moves to first Tab.
    internal var isChangingOrientation: Bool = false
    /// Used only in case of cyclic case, useing this array to know where does each viewcontroller locate relative to each other, example it starts as [1,2,3,4,...] but it can ends as [2,3,4,1,..] so it used to get current position of viewcotroller #4 which is 2.
    internal var mappingArray: [Int] = []
    /// Last tab selected, used to get whether user tab another tab on the left or on the right to it can be moved to the left or to the right.
    internal var lastSelectedTag = 0
    internal var initialContentOffset: CGPoint = .zero
    // IBOutlets
    @IBOutlet weak var tabsScrollView: UIScrollView!
    @IBOutlet weak var viewControllersScrollView: UIScrollView!
    @IBOutlet weak var tabsBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var shadowView: UIView!
    
    // MARK:- Views cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        tabsBarHeightConstraint.constant = navigationBarHeight
        tabsScrollView.backgroundColor = tabsBkgColor
        viewControllersScrollView.backgroundColor = scrollViewBackgroundColor        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rotated()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        isChangingOrientation = true
        
        coordinator.animate(alongsideTransition: nil, completion: { _ in
            self.isChangingOrientation = false
        })
    }
    
    func rotated() {
        
        currentPage = 0
        oldPage = 0
        lastSelectedTag = 0
        
        addTitlesScrollViews()
        adjustTitleViewsFrames()
        adjustViewControllersFrames()
        
        if enableResizingAnimated {
            DispatchQueue.main.async {
                self.adjustTabsView(forPage: 0)
            }
        } else {
            adjustTabsViewStyle()
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !viewIsSetup {
            updateUI()
        }
    }
    /// To be called everytime user add/remove to ViewControllers array or tabs array
    public func updateUI() {
        // Error checking
        if viewControllersArray.count == 0 || viewControllersTitlesArray.count == 0 || viewControllersTitlesArray.count != viewControllersArray.count {
            assertionFailure("Make sure you have the same amount of non-zero items in viewControllersTitlesArray and viewControllersArray")
            return
        }
        
        mappingArray = Array(0 ..< viewControllersArray.count)
        addViewControllersScrollViews()
        addTitlesScrollViews()
        addNavigationIndicator()
        
        if enableCycles {
            enableBounce = false
            tabsBarStatus = .scrollable
            indicatorView.isHidden = true
        }
        if tabsBarStatus == .scrollable {
            tabsScrollView.isScrollEnabled = true
            tabsScrollView.setContentOffset(CGPoint.zero, animated: true)
        }
        
        if enableResizingAnimated {
            indicatorView.isHidden = true
        }
        
        viewControllersScrollView.bounces = enableBounce
        
        DispatchQueue.main.async {
            self.adjustTabsView(forPage: 0)
        }
        
    }
    override public func loadView() {
        super.loadView()
        Bundle(for: MNavigationTabsViewController.self).loadNibNamed("MNavigationTabsViewController", owner: self, options: nil)
    }
    
    // MARK:- Creating views
    /// Add ViewControllers to viewControllersScrollView
    fileprivate func addViewControllersScrollViews() {
        
        for view in viewControllersScrollView.subviews{
            view.removeFromSuperview()
        }
        
        for viewController in self.childViewControllers {
            viewController.removeFromParentViewController()
        }
        
        var origin: CGFloat = 0.0
        var index: Int = 0
        for viewController in viewControllersArray {
            viewController.view.frame = CGRect(x: origin, y: 0.0, width: viewControllersScrollView.bounds.width, height: viewController.view.bounds.height)
            self.addChildViewController(viewController)
            viewControllersScrollView.addSubview(viewController.view)
            viewController.didMove(toParentViewController: self)
            origin += viewControllersScrollView.bounds.width
            viewController.view.tag = index
            index += 1
        }
        
        viewControllersScrollView.contentSize = CGSize(width: origin, height: self.view.frame.size.height - navigationBarHeight)
        viewControllersScrollView.setContentOffset(CGPoint(x: viewControllersScrollView.bounds.width * CGFloat(currentPage), y: 0), animated: true)
        viewIsSetup = true
    }
    /// Add titles to tabsScrollView
    fileprivate func addTitlesScrollViews() {
        
        for view in tabsScrollView.subviews{
            view.removeFromSuperview()
        }
        
        var origin: CGFloat = tabOuterMargin
        var index:Int = 0
        
        // Special case if .fit status is enabled, adjust tabWidth
        if tabsBarStatus == .fit {
            calculatedTabWidth = (tabsScrollView.bounds.width -  ((2 * tabOuterMargin) + CGFloat(viewControllersTitlesArray.count - 1) * tabInnerMargin)) / CGFloat(viewControllersTitlesArray.count)
        } else {
            calculatedTabWidth = navigationTabWidth
        }
        
        var numberOfDummyRepetitions = 1
        if enableCycles {
            numberOfDummyRepetitions = 4 // In case of cycles, add dummy tabs to the left and to the right so user feels it's circular.
        }
        for _ in 0 ..< numberOfDummyRepetitions {
            for title in viewControllersTitlesArray {
                let button = UIButton(frame: CGRect(x: origin, y: 0, width: calculatedTabWidth, height: navigationTabHeight))
                button.backgroundColor = inactiveTabColor
                button.setAttributedTitle(title, for: .normal)
                button.titleLabel?.font = inactiveTabFont
                button.titleLabel?.textColor = inactiveTabTextColor
                button.tag = index
                button.addTarget(self, action: #selector(selectPage(sender:)), for: .touchUpInside)
                tabsScrollView.addSubview(button)
                button.clipsToBounds = true
                button.layer.cornerRadius = tabsCornerRadius
                origin += button.frame.size.width + tabInnerMargin
                index += 1
            }
        }
        
    }
    
    /// Add indicator view to tabsScrollView
    fileprivate func addNavigationIndicator() {
        
        if indicatorView != nil {
            indicatorView.removeFromSuperview()
        }
        
        let tabOrigin = (CGFloat(currentPage) * calculatedTabWidth) + (CGFloat(currentPage) * tabInnerMargin) + tabOuterMargin
        
        indicatorView = UIView(frame: CGRect(x: tabOrigin, y: tabsScrollView.frame.size.height - indicatorViewHeight, width: calculatedTabWidth, height: indicatorViewHeight))
        indicatorView.backgroundColor = indicatorColor
        tabsScrollView.addSubview(indicatorView)
    }
    
    // MARK:- Adjusting frames
    fileprivate func adjustTitleViewsFrames() {
        
        var origin: CGFloat = tabOuterMargin
        
        if tabsBarStatus == .fit {
            calculatedTabWidth = (tabsScrollView.bounds.width -  ((2 * tabOuterMargin) + CGFloat(viewControllersTitlesArray.count - 1) * tabInnerMargin)) / CGFloat(viewControllersTitlesArray.count)
        } else {
            calculatedTabWidth = navigationTabWidth
        }
        
        for button in tabsScrollView.subviews {
            if let button = button as? UIButton {
                button.frame = CGRect(x: origin, y: 0, width: calculatedTabWidth, height: navigationTabHeight)
                origin += button.frame.size.width + tabInnerMargin
            }
        }
        
        // origin here equals width of all tabs + inner margin on the right so we subtract it from total width
        tabsScrollView.contentSize = CGSize(width: origin + tabOuterMargin - tabInnerMargin, height: tabsScrollView.frame.size.height)
        
        var tabOrigin = (CGFloat(currentPage) * calculatedTabWidth) + (CGFloat(currentPage) * tabInnerMargin) + tabOuterMargin
        
        if tabsBarStatus == .center {
            let initialOrigin = -tabsScrollView.bounds.width * 0.5 + 0.5 * navigationTabWidth + tabInnerMargin
            tabsScrollView.setContentOffset(CGPoint(x: initialOrigin, y: 0), animated: true)
            tabOrigin = tabInnerMargin
        }
        
        // Set indicator to the first tab
        indicatorView.frame = CGRect(x: tabOrigin, y: tabsScrollView.frame.size.height - indicatorViewHeight, width: calculatedTabWidth, height: indicatorViewHeight)
        
        if enableCycles {
            tabsScrollView.contentOffset.x = CGFloat(viewControllersArray.count) * calculatedTabWidth + CGFloat(viewControllersArray.count) * tabInnerMargin
        }
        
    }
    fileprivate func adjustViewControllersFrames() {
        
        var index: CGFloat = 0.0
        var maximumHeight = viewControllersScrollView.bounds.width
        for newView in viewControllersScrollView.subviews {
            newView.frame = CGRect(x: index, y: 0.0, width: viewControllersScrollView.bounds.width, height: newView.bounds.height)
            index += viewControllersScrollView.bounds.width
            maximumHeight = max(maximumHeight, newView.bounds.height)
        }
        
        viewControllersScrollView.contentSize = CGSize(width: index, height: maximumHeight)
        viewControllersScrollView.setContentOffset(CGPoint(x: viewControllersScrollView.bounds.width * CGFloat(currentPage), y: 0), animated: false)
        
    }
    public func adjustTabsViewStyle() {
        
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
        let activeArr = tabsScrollView.subviews.filter{ ($0.tag - indexOfCurrentPage) % viewControllersArray.count == 0 }
        for activeView in activeArr {
            
            (activeView as? UIButton)?.backgroundColor = activeTabColor
            (activeView as? UIButton)?.titleLabel?.font = activeTabFont
            (activeView as? UIButton)?.titleLabel?.textColor = activeTabTextColor
            if activeView.tag >= viewControllersArray.count && activeView.tag < viewControllersArray.count * 2 {
                lastSelectedTag = activeView.tag
            }
            
            if enableResizingAnimated {
                UIView.animate(withDuration: 0.2, animations: {
                    activeView.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
                })
            }
        }

    }
    // MARK:- IBActions
    @objc fileprivate func selectPage(sender: UIButton) {
        
        if enableCycles && abs(sender.tag - lastSelectedTag) % viewControllersArray.count == 0 { // Tab same selected page
            return
        }
        // When user tab any button, it should reprder all viewcontroller to its initial state
        let currentIndex = sender.tag % viewControllersArray.count
        adjustViewControllersFrames()
        viewControllersArray = viewControllersArray.sorted( by: { $0.view.tag < $1.view.tag })
        viewControllersScrollView.contentOffset.x =  CGFloat(mappingArray.index(of: currentPage)!) * viewControllersScrollView.frame.size.width
        mappingArray = Array(0 ..< viewControllersArray.count)
        currentPage = currentIndex
        
        var direction = 0
        
        if enableCycles {
            
            if sender.tag >= viewControllersArray.count * 2 { // User selects tab on the far right, shifting to right [1,2,3,4] -> [4,1,2,3] switching from 4 to 1 runs smoothly (forward).
                shiftViewsToRight()
                currentPage = (1 + currentIndex) % viewControllersArray.count // As view shifts by 1 to the right, currentPage will be increased by 1 too.
                viewControllersScrollView.setContentOffset(CGPoint(x: CGFloat(currentPage) * viewControllersScrollView.frame.size.width, y: 0), animated: true)
            } else if sender.tag <= viewControllersArray.count - 1 { // User selects tab on the far left, shifting to left [1,2,3,4] -> [2,3,4,1] switching from 1 to 4 runs smoothly (backward).
                shiftViewsToLeft()
                currentPage = viewControllersArray.count - 2 // The current index of the "to go to page, here in the previous comment the index of 4 is count - 2"
                viewControllersScrollView.setContentOffset(CGPoint(x: CGFloat(currentPage) * viewControllersScrollView.frame.size.width, y: 0), animated: true)
            } else{
                viewControllersScrollView.setContentOffset(CGPoint(x: CGFloat(currentPage) * viewControllersScrollView.frame.size.width, y: 0), animated: true)
            }
            
            // If user selects tab on the right, direction = -1 otherwise direction = 1
            sender.tag > lastSelectedTag ? (direction = -1) : (direction = 1)
            lastSelectedTag = sender.tag
            
        } else {
            viewControllersScrollView.setContentOffset(CGPoint(x: CGFloat(currentPage) * viewControllersScrollView.frame.size.width, y: 0), animated: true)
        }
        
        DispatchQueue.main.async {
            self.adjustTabsView(forPage: self.currentPage, direction: direction)
        }
        
    }
    
}
