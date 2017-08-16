//
//  ThirdViewController.swift
//  TestMyPod
//
//  Created by Mohammed Elsammak on 3/23/17.
//  Copyright © 2017 Modeso. All rights reserved.
//

import UIKit
import ModesoNavigationTabs

class ThirdViewController: UIViewController, UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        (self.parent as? ModesoNavigationTabsViewController)?.handleScrollView(scrollView)
    }
}
