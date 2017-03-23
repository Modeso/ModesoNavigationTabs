//
//  MNavigationTabsViewController.swift
//  MNavigationTabs
//
//  Created by Mohammed Elsammak on 3/22/17.
//  Copyright © 2017 Modeso. All rights reserved.
//

import UIKit

public class MNavigationTabsViewController: UIViewController {

    var color: UIColor!
    @IBOutlet weak var label: UILabel!
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        label.textColor = color
    }

    override public func loadView() {
        super.loadView()
        Bundle(for: MNavigationTabsViewController.self).loadNibNamed("MNavigationTabsViewController", owner: self, options: nil)
    }

}

@IBDesignable extension MNavigationTabsViewController {
    @IBInspectable var labelTextColor: UIColor? {
        set {
            color = newValue
        }
        get {
            return color
        }
    }
}
