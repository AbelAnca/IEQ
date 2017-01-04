//
//  UserDefManager.swift
//  IEQ
//
//  Created by Abel Anca on 1/4/17.
//  Copyright © 2017 IEQ. All rights reserved.
//

import Foundation
import UIKit

class UserDefManager {
    static func logout() -> Void {
        appDelegate.curUser = nil
        
        // Remove from NSUserDefaults
        appDelegate.defaults.removeObject(forKey: k_UserDef_LoggedInUserID)
        appDelegate.defaults.removeObject(forKey: k_UserDef_NoOfAnswer)
        appDelegate.defaults.removeObject(forKey: k_UserDef_OrganizationID)
        appDelegate.defaults.synchronize()
        
        // Clean realm
        try! appDelegate.realm.write({ () -> Void in
            appDelegate.realm.deleteAll()
        })
        
        reset(true)
    }
    
    // Helper Methods
    
    static func reset(_ animated: Bool) -> Void {
        if let rootViewController = UIApplication.shared.keyWindow!.rootViewController as? UINavigationController {
            rootViewController.popToRootViewController(animated: animated)
        }
    }
}
