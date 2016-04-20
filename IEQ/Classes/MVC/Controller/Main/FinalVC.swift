//
//  FinalVC.swift
//  IEQ
//
//  Created by Abel Anca on 12/11/15.
//  Copyright © 2015 IEQ. All rights reserved.
//

import UIKit

class FinalVC: UIViewController {
    
    @IBOutlet var btnLogout: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Setup UI
        btnLogout.layer.cornerRadius           = 8
        btnLogout.layer.borderWidth            = 1
        btnLogout.layer.borderColor            = UIColor.whiteColor().CGColor
    }
    
    // MARK: - Action Methods
    @IBAction func btnLogot_Action(sender: AnyObject) {
        
        appDelegate.curUser = nil
        
        // Remove from NSUserDefaults
        appDelegate.defaults.removeObjectForKey(k_UserDef_LoggedInUserID)
        appDelegate.defaults.removeObjectForKey(k_UserDef_Index)
        appDelegate.defaults.removeObjectForKey(k_UserDef_NoOfAnswer)
        appDelegate.defaults.removeObjectForKey(k_UserDef_OrganizationID)
        appDelegate.defaults.synchronize()

        // Clean realm
        try! appDelegate.realm.write({ () -> Void in
            appDelegate.realm.deleteAll()
        })
        
        // Present LoginVC
        let loginNC = storyboard?.instantiateViewControllerWithIdentifier("LoginVC_NC") as! UINavigationController
        navigationController?.popToRootViewControllerAnimated(true)
        navigationController?.presentViewController(loginNC, animated: true, completion: { () -> Void in

        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
