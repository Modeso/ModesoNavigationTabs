//
//  MNavigationTabsViewController.swift
//  MNavigationTabs
//
//  Created by Mohammed Elsammak on 3/22/17.
//  Copyright © 2017 Modeso. All rights reserved.
//

import UIKit

public class MNavigationTabsViewController: UIViewController {

    var color: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    var tabWidth: CGFloat = 111.0
    var tabsInbetweenMargin: CGFloat = 10.0
    var tabLeadingTrailingMargin: CGFloat = 10.0
    var indicatorHeight: CGFloat = 20.0
    var viewControllerWidth: CGFloat = 320.0
    var indicatorView: UIView!        
    
    public var viewControllersArray: [UIViewController] = [] {
        didSet {
            adjustViewControllersScrollView()
        }
    }
    public var viewControllersTitlesArray: [String] = [] {
        didSet {
            adjustTitlesScrollView()
        }
    }
    
    
    @IBOutlet weak var tabsScrollView: UIScrollView!
    @IBOutlet weak var viewControllersScrollView: UIScrollView!
    
    @IBOutlet weak var label: UILabel!
    override public func viewDidLoad() {
        super.viewDidLoad()
        addNavigationIndicator()
        viewControllerWidth = viewControllersScrollView.frame.size.width
    }

    override public func loadView() {
        super.loadView()
        Bundle(for: MNavigationTabsViewController.self).loadNibNamed("MNavigationTabsViewController", owner: self, options: nil)
    }
    
    private func configureTabsMenuView() {
        
    }
    
    func adjustViewControllersScrollView() {
        var origin: CGFloat = 0.0
        for viewController in viewControllersArray {
            viewController.view.frame = CGRect(x: origin, y: 0.0, width: viewController.view.frame.size.width, height: viewController.view.frame.size.height)
            viewControllersScrollView.addSubview(viewController.view)
            origin += viewController.view.frame.size.width
        }
        viewControllersScrollView.contentSize = CGSize(width: origin, height: viewControllersScrollView.frame.size.height)
    }
    
    func adjustTitlesScrollView() {
        var origin: CGFloat = tabLeadingTrailingMargin
        var index:Int = 0
        for title in viewControllersTitlesArray {
            let button = UIButton(frame: CGRect(x: origin, y: 0, width: tabWidth, height: 33))
            button.setTitle(title, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(selectPage(sender:)), for: .touchUpInside)
            tabsScrollView.addSubview(button)
            origin += button.frame.size.width + tabsInbetweenMargin
            index += 1
        }
        tabsScrollView.contentSize = CGSize(width: origin + tabLeadingTrailingMargin, height: tabsScrollView.frame.size.height)
        tabsScrollView.bringSubview(toFront: indicatorView)
    }
    
    func addNavigationIndicator() {
        indicatorView = UIView(frame: CGRect(x: tabLeadingTrailingMargin, y: tabsScrollView.frame.size.height - indicatorHeight, width: tabWidth, height: indicatorHeight))
        tabsScrollView.addSubview(indicatorView)
    }
    
    func selectPage(sender: UIButton) {
        viewControllersScrollView.contentOffset = CGPoint(x: CGFloat(sender.tag) * viewControllerWidth, y: 0)
    }

}

@IBDesignable extension MNavigationTabsViewController {
    @IBInspectable var labelTextColor: UIColor {
        set {
            color = newValue
        }
        get {
            return color
        }
    }
}




