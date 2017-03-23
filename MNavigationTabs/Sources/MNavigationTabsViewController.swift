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

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
