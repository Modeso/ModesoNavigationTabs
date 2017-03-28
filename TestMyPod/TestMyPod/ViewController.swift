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
     
        let firstViewController = UIStoryboard(name: "ViewControllers", bundle: nil).instantiateViewController(withIdentifier: "FirstViewController")
        let secondViewController = UIStoryboard(name: "ViewControllers", bundle: nil).instantiateViewController(withIdentifier: "SecondViewController")
        let thirdViewController = UIStoryboard(name: "ViewControllers", bundle: nil).instantiateViewController(withIdentifier: "ThirdViewController")
        let forthViewController = UIStoryboard(name: "ViewControllers", bundle: nil).instantiateViewController(withIdentifier: "ForthViewController")
        
        mNavigationTabs.viewControllersArray = [firstViewController,secondViewController,thirdViewController, forthViewController]
        mNavigationTabs.viewControllersTitlesArray = [NSAttributedString(string: "First"),NSAttributedString(string: "Second"),NSAttributedString(string: "Third"),NSAttributedString(string: "Forth")]
        mNavigationTabs.activeTabFont = UIFont(name: "ArialHebrew", size: 12)!
        mNavigationTabs.inactiveTabFont = UIFont(name: "ArialHebrew", size: 10)!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "MNavigationTabs" {
            
            mNavigationTabs = segue.destination as? MNavigationTabsViewController
            
        }
    }

}

