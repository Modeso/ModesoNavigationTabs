//
//  MNavigationTabsViewController.swift
//  MNavigationTabs
//
//  Created by Mohammed Elsammak on 3/22/17.
//  Copyright © 2017 Modeso. All rights reserved.
//

import UIKit
enum TabsScrollStatus: Int {
    case fixed
    case scrollable
    case fit
}
public class MNavigationTabsViewController: UIViewController {
    
    /// Single tab width
    var tabWidth: CGFloat = 111.0
    /// Tab Color
    var tabColor: UIColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
    /// Margin between two tabs
    var tabInnerMargin: CGFloat = 10.0
    /// Leading and Trailing margin of the first and last tab
    var tabOuterMargin: CGFloat = 10.0
    /// Tab indicator height
    var indicatorHeight: CGFloat = 5.0
    /// Tab indicator color
    var indicatorColor: UIColor = #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
    /// Navigation bar height
    var navigationBarHeight: CGFloat = 33
    /// Navigation bar color
    var navigationBarColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    /// Bounce viewcontrollers
    var enableBounce: Bool = false
    /**
     * State of the Navigation tabs views.
     * fixed: Navigation tabs will use tabWidth property and extend beyond screen bounds without scrolling ability.
     * scrollable: Navigation tabs will use tabWidth property and extend beyond screen bounds with scrolling ability.
     * fit: Navigation tabs will adjust its width so all tabs fit in a single screen without scrolling ability.
     *
     **/
    var tabsBarStatus: TabsScrollStatus = .fit
    
    /// ViewControllers array to switch between them.
    public var viewControllersArray: [UIViewController] = []
    /// Titles array to use it in tabs navigation bar.
    public var viewControllersTitlesArray: [String] = []
    /// Single Tab font
    public var tabFont: UIFont = UIFont.systemFont(ofSize: 12)
    
    internal var indicatorView: UIView!
    
    // IBOutlets
    @IBOutlet weak var tabsScrollView: UIScrollView!
    @IBOutlet weak var viewControllersScrollView: UIScrollView!
    @IBOutlet weak var tabsBarHeightConstraint: NSLayoutConstraint!
    
    // MARK:- Views cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if tabsBarStatus == .fixed || tabsBarStatus == .fit {
            tabsScrollView.isScrollEnabled = false
        }
        
        tabsBarHeightConstraint.constant = navigationBarHeight
        tabsScrollView.backgroundColor = tabsBarBackgroundColor
        viewControllersScrollView.bounces = enableBounce
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        adjustViewControllersScrollView()
        adjustTitlesScrollView()
        addNavigationIndicator()
    }
    override public func loadView() {
        super.loadView()
        Bundle(for: MNavigationTabsViewController.self).loadNibNamed("MNavigationTabsViewController", owner: self, options: nil)
    }
    
    // MARK:- Creating views
    /// Add ViewControllers to viewControllersScrollView
    fileprivate func adjustViewControllersScrollView() {
        var origin: CGFloat = 0.0
        for viewController in viewControllersArray {
            viewController.view.frame = CGRect(x: origin, y: 0.0, width: viewControllersScrollView.bounds.width, height: viewController.view.frame.size.height)
            viewControllersScrollView.addSubview(viewController.view)
            origin += viewControllersScrollView.bounds.width
        }
        viewControllersScrollView.contentSize = CGSize(width: origin, height: self.view.frame.size.height - navigationBarHeight)
    }
    /// Add titles to tabsScrollView
    fileprivate func adjustTitlesScrollView() {
        var origin: CGFloat = tabOuterMargin
        var index:Int = 0
        
        // Special case if .fit status is enabled, adjust tabWidth
        if tabsBarStatus == .fit {
            tabWidth = (tabsScrollView.bounds.width -  ((2 * tabOuterMargin) + CGFloat(viewControllersTitlesArray.count - 1) * tabInnerMargin)) / CGFloat(viewControllersTitlesArray.count)
        }
        for title in viewControllersTitlesArray {
            let button = UIButton(frame: CGRect(x: origin, y: 0, width: tabWidth, height: 33))
            button.backgroundColor = tabColor
            button.setTitle(title, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(selectPage(sender:)), for: .touchUpInside)
            tabsScrollView.addSubview(button)
            origin += button.frame.size.width + tabInnerMargin
            index += 1
        }
        tabsScrollView.contentSize = CGSize(width: origin + tabOuterMargin - tabInnerMargin, height: tabsScrollView.frame.size.height)
    }
    
    fileprivate func addNavigationIndicator() {
        indicatorView = UIView(frame: CGRect(x: tabOuterMargin, y: tabsScrollView.frame.size.height - indicatorHeight, width: tabWidth, height: indicatorHeight))
        indicatorView.backgroundColor = indicatorColor
        tabsScrollView.addSubview(indicatorView)
    }
    
    // MARK:- IBActions
    @objc fileprivate func selectPage(sender: UIButton) {
        viewControllersScrollView.setContentOffset(CGPoint(x: CGFloat(sender.tag) * viewControllersScrollView.frame.size.width, y: 0), animated: true)
    }
    
}






