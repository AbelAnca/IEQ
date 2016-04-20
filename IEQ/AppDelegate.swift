//
//  AppDelegate.swift
//  IEQ
//
//  Created by Abel Anca on 12/1/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import KVNProgress

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var curUser: User?
    
    var realm: Realm!
    
    //>     Creating an Instance of the Alamofire Manager
    var manager = Manager.sharedInstance
    
    let defaults = NSUserDefaults.standardUserDefaults()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        self.realm      = try! Realm()
        
        loadCurrentUser()
        
        setupAlamofireManager()
        
        let configuration = KVNProgressConfiguration()
        configuration.minimumErrorDisplayTime = 2.0
        KVNProgress.setConfiguration(configuration)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }

    
    // MARK: - Custom Methods
    
    
    func setupAlamofireManager() {
        
        var dictDefaultHeaders      = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
        
        //>     Specifying the Headers we need
        if let currentUser = curUser {
            dictDefaultHeaders["X-IQE-Auth"]        = "\(currentUser.token)"
            dictDefaultHeaders["content-type"]      = "application/json; charset=utf-8"
            //dictDefaultHeaders["content-length"]    = "264"
        }
        
        let configuration       = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = dictDefaultHeaders
        
        self.manager            = Alamofire.Manager(configuration: configuration)
    }

    
    func loadCurrentUser() {
        if let strID = self.defaults.objectForKey(k_UserDef_LoggedInUserID) as? String {
            if let user = User.getUserWithID(strID, realm: appDelegate.realm) {
                curUser = user
            }
        }
    }
}

// MARK: - Convenience Constructors
let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
