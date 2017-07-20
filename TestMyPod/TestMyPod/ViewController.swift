//
//  ViewController.swift
//  TestMyPod
//
//  Created by Mohammed Elsammak on 3/22/17.
//  Copyright © 2017 Modeso. All rights reserved.
//

import UIKit
import MNavigationTabs

class ViewController: UIViewController {

    var mNavigationTabs: MNavigationTabsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
//        self.view.backgroundColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 177.0/255.0, alpha: 1)
        
        let firstViewController = UIStoryboard(name: "ViewControllers", bundle: nil).instantiateViewController(withIdentifier: "FirstViewController")
        let secondViewController = UIStoryboard(name: "ViewControllers", bundle: nil).instantiateViewController(withIdentifier: "SecondViewController")
        let thirdViewController = UIStoryboard(name: "ViewControllers", bundle: nil).instantiateViewController(withIdentifier: "ThirdViewController")
        let forthViewController = UIStoryboard(name: "ViewControllers", bundle: nil).instantiateViewController(withIdentifier: "ForthViewController")
        
        mNavigationTabs.viewControllersArray = [firstViewController,secondViewController,thirdViewController, forthViewController]
        mNavigationTabs.viewControllersTitlesArray = [NSAttributedString(string: "Page One"),NSAttributedString(string: "Page Two"),NSAttributedString(string: "Page Three"),NSAttributedString(string: "Page Four")]
        mNavigationTabs.activeTabFont = UIFont(name: "Menlo", size: 12)!
        mNavigationTabs.inactiveTabFont = UIFont(name: "Menlo", size: 10)!
        mNavigationTabs.updateUI()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "MNavigationTabs" {
            
            mNavigationTabs = segue.destination as? MNavigationTabsViewController
            
        }
    }

}

