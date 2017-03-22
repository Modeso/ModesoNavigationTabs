//
//  MNavigationTabs.swift
//  MNavigationTabs
//
//  Created by Mohammed Elsammak on 3/22/17.
//  Copyright © 2017 Modeso. All rights reserved.
//

import Foundation
class MNavigationTabs: UIViewController {
    
    var viewControllersArray: [UIViewController] = []
    var tabsScrollView: UIScrollView = UIScrollView()
    var controllersScrollView: UIScrollView = UIScrollView()
    
    public init(viewControllers: [UIViewController], frame: CGRect) {
        super.init(nibName: nil, bundle: nil)
        self.viewControllersArray = viewControllers
        self.view.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
