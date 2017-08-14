//
//  ForthViewController.swift
//  TestMyPod
//
//  Created by Mohammed Elsammak on 3/27/17.
//  Copyright © 2017 Modeso. All rights reserved.
//

import UIKit
import ModesoNavigationTabs

class ForthViewController: UIViewController, UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        (self.parent as? ModesoNavigationTabsViewController)?.handleScrollView(scrollView)
    }
}
