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
    var viewControllersArray: [UIViewController] = [] {
        didSet {
            adjustviewControllersScrollView()
        }
    }
    var viewControllersTitlesArray: [String] = []
    
    
    @IBOutlet weak var tabsScrollView: UIScrollView!
    @IBOutlet weak var viewControllersScrollView: UIScrollView!
    
    @IBOutlet weak var label: UILabel!
    override public func viewDidLoad() {
        super.viewDidLoad()

    }

    override public func loadView() {
        super.loadView()
        Bundle(for: MNavigationTabsViewController.self).loadNibNamed("MNavigationTabsViewController", owner: self, options: nil)
    }
    
    private func configureTabsMenuView() {
        
    }
    
    func adjustviewControllersScrollView() {
        var origin: CGFloat = 0.0
        for viewController in viewControllersArray {
            viewController.view.frame = CGRect(x: origin, y: 0.0, width: viewController.view.frame.size.width, height: viewController.view.frame.size.height)
            viewControllersScrollView.addSubview(viewController.view)
            origin += viewController.view.frame.size.width
        }
        viewControllersScrollView.contentSize = CGSize(width: origin, height: self.view.frame.size.height)
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
