//
//  MNavigationTabsConfigurations.swift
//  MNavigationTabs
//
//  Created by Mohammed Elsammak on 3/22/17.
//  Copyright © 2017 Modeso. All rights reserved.
//

import Foundation
public class MNavigationTabsConfigurations {
    
    // Singlton Object
    static let sharedInstance: MNavigationTabsConfigurations = MNavigationTabsConfigurations()
    
    // Inits
    private init() {
        
    }
    
    open var meuHeight: CGFloat = 34.0
    open var tabMargin: CGFloat = 15.0
    open var tabWidth: CGFloat = 111.0
    
}
