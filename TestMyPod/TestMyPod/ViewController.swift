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
     
        self.view.backgroundColor = UIColor(red: 8.0/255.0, green: 86.0/255.0, blue: 152.0/255.0, alpha: 1)
        
        let firstViewController = UIStoryboard(name: "ViewControllers", bundle: nil).instantiateViewController(withIdentifier: "FirstViewController")
        let secondViewController = UIStoryboard(name: "ViewControllers", bundle: nil).instantiateViewController(withIdentifier: "SecondViewController")
        let thirdViewController = UIStoryboard(name: "ViewControllers", bundle: nil).instantiateViewController(withIdentifier: "ThirdViewController")
        let forthViewController = UIStoryboard(name: "ViewControllers", bundle: nil).instantiateViewController(withIdentifier: "ForthViewController")
        
        var frame = firstViewController.view.frame
        frame.size.height = 1000
        firstViewController.view.frame = frame
        
        mNavigationTabs.viewControllersArray = [firstViewController,secondViewController,thirdViewController, forthViewController]
        mNavigationTabs.viewControllersTitlesArray = [NSAttributedString(string: ""),NSAttributedString(string: ""),NSAttributedString(string: ""),NSAttributedString(string: "")]
        mNavigationTabs.activeTabFont = UIFont(name: "ArialHebrew", size: 12)!
        mNavigationTabs.inactiveTabFont = UIFont(name: "ArialHebrew", size: 10)!
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

