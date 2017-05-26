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
    /// Navigation bar color
    public var navigationBarColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    /// ScrollView nackground color
    public var scrollViewBackgroundColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    
    /// Bounce viewcontrollers
    public var enableBounce: Bool = false
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
    
    internal var indicatorView: UIView!
    internal var currentPage: Int = 0
    internal var oldPage: Int = 0
    internal var viewIsSetup = false
    /// Orientation is not supporting in the library and it causes issues that it moves to first Tab.
    internal var isChangingOrientation: Bool = false
    
    // IBOutlets
    @IBOutlet weak var tabsScrollView: UIScrollView!
    @IBOutlet weak var viewControllersScrollView: UIScrollView!
    @IBOutlet weak var tabsBarHeightConstraint: NSLayoutConstraint!
    
    // MARK:- Views cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if tabsBarStatus == .scrollable {
            tabsScrollView.isScrollEnabled = true
        }
        
        tabsBarHeightConstraint.constant = navigationBarHeight
        tabsScrollView.backgroundColor = tabsBkgColor
        viewControllersScrollView.backgroundColor = scrollViewBackgroundColor
        viewControllersScrollView.bounces = enableBounce
        
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
        self.adjustTitleViewsFrames()
        self.adjustViewControllersFrames()
        
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !viewIsSetup {
            updateUI()
        }
    }
    
    public func updateUI() {
        // Error checking
        if viewControllersArray.count == 0 || viewControllersTitlesArray.count == 0 {
            return
        }
        adjustViewControllersScrollView()
        adjustTitlesScrollView()
        addNavigationIndicator()
        
        if tabsBarStatus == .scrollable {
            tabsScrollView.isScrollEnabled = true
            tabsScrollView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    override public func loadView() {
        super.loadView()
        Bundle(for: MNavigationTabsViewController.self).loadNibNamed("MNavigationTabsViewController", owner: self, options: nil)
    }
    
    // MARK:- Creating views
    /// Add ViewControllers to viewControllersScrollView
    fileprivate func adjustViewControllersScrollView() {
        
        for view in viewControllersScrollView.subviews{
            view.removeFromSuperview()
        }
        
        for viewController in self.childViewControllers {
            viewController.removeFromParentViewController()
        }
        
        var origin: CGFloat = 0.0
        for viewController in viewControllersArray {
            viewController.view.frame = CGRect(x: origin, y: 0.0, width: viewControllersScrollView.bounds.width, height: viewControllersScrollView.bounds.height)
            self.addChildViewController(viewController)
            viewControllersScrollView.addSubview(viewController.view)
            viewController.didMove(toParentViewController: self)
            origin += viewControllersScrollView.bounds.width
        }
        viewControllersScrollView.contentSize = CGSize(width: origin, height: self.view.frame.size.height - navigationBarHeight)
        currentPage = 0
        viewControllersScrollView.setContentOffset(CGPoint.zero, animated: true)
        viewIsSetup = true
    }
    /// Add titles to tabsScrollView
    fileprivate func adjustTitlesScrollView() {
        
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
        for title in viewControllersTitlesArray {
            let button = UIButton(frame: CGRect(x: origin, y: 0, width: calculatedTabWidth, height: navigationBarHeight))
            button.backgroundColor = inactiveTabColor
            button.setAttributedTitle(title, for: .normal)
            button.titleLabel?.font = inactiveTabFont
            button.titleLabel?.textColor = inactiveTabTextColor
            button.tag = index
            button.addTarget(self, action: #selector(selectPage(sender:)), for: .touchUpInside)
            tabsScrollView.addSubview(button)
            origin += button.frame.size.width + tabInnerMargin
            index += 1
        }
        tabsScrollView.contentSize = CGSize(width: origin + tabOuterMargin - tabInnerMargin, height: tabsScrollView.frame.size.height)
        
        (tabsScrollView.subviews[0] as? UIButton)?.backgroundColor = activeTabColor
        (tabsScrollView.subviews[0] as? UIButton)?.titleLabel?.font = activeTabFont
        (tabsScrollView.subviews[0] as? UIButton)?.titleLabel?.textColor = activeTabTextColor
    }
    
    fileprivate func addNavigationIndicator() {
        
        if indicatorView != nil {
            indicatorView.removeFromSuperview()
        }
        
        indicatorView = UIView(frame: CGRect(x: tabOuterMargin, y: tabsScrollView.frame.size.height - indicatorViewHeight, width: calculatedTabWidth, height: indicatorViewHeight))
        indicatorView.backgroundColor = indicatorColor
        tabsScrollView.addSubview(indicatorView)
    }
    
    // MARK:- Adjusting views
    fileprivate func adjustTitleViewsFrames() {
        
        var origin: CGFloat = tabOuterMargin
        
        if tabsBarStatus == .fit {
            calculatedTabWidth = (tabsScrollView.bounds.width -  ((2 * tabOuterMargin) + CGFloat(viewControllersTitlesArray.count - 1) * tabInnerMargin)) / CGFloat(viewControllersTitlesArray.count)
        } else {
            calculatedTabWidth = navigationTabWidth
        }
        
        for button in tabsScrollView.subviews {
            
            button.frame = CGRect(x: origin, y: 0, width: calculatedTabWidth, height: navigationBarHeight)
            origin += button.frame.size.width + tabInnerMargin
        }
        
        let tabOrigin = (CGFloat(currentPage) * calculatedTabWidth) + (CGFloat(currentPage) * tabInnerMargin) + tabOuterMargin
        indicatorView.frame = CGRect(x: tabOrigin, y: tabsScrollView.frame.size.height - indicatorViewHeight, width: calculatedTabWidth, height: indicatorViewHeight)
    }
    fileprivate func adjustViewControllersFrames() {
        
        var index: CGFloat = 0.0
        for newView in viewControllersScrollView.subviews {
            newView.frame = CGRect(x: index, y: 0.0, width: viewControllersScrollView.bounds.width, height: viewControllersScrollView.bounds.height)
            index += viewControllersScrollView.bounds.width
        }
        
        viewControllersScrollView.contentSize = CGSize(width: index, height: self.view.frame.size.height - navigationBarHeight)
        
        
        viewControllersScrollView.setContentOffset(CGPoint(x: viewControllersScrollView.bounds.width * CGFloat(currentPage), y: 0), animated: false)
        
    }
    // MARK:- IBActions
    @objc fileprivate func selectPage(sender: UIButton) {
        viewControllersScrollView.setContentOffset(CGPoint(x: CGFloat(sender.tag) * viewControllersScrollView.frame.size.width, y: 0), animated: true)
    }
    
}






