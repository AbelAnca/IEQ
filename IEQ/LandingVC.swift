//
//  LandingVC.swift
//  IEQ
//
//  Created by Abel Anca on 12/11/15.
//  Copyright © 2015 IEQ. All rights reserved.
//

import UIKit

class LandingVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let _ = appDelegate.curUser {
            if let _ = appDelegate.defaults.objectForKey(k_UserDef_Index) as? Int {
                pushToQuestionVC()
            }
            else {
                pushToEnableGPS()
            }
        }
        else {
            presentLoginVC()
        }
    }
    
    // MARK: - Custom Methods
    
    func presentLoginVC() {
        let loginNC = storyboard?.instantiateViewControllerWithIdentifier("LoginVC_NC") as! UINavigationController
        navigationController?.presentViewController(loginNC, animated: true, completion: nil)
    }
    
    func pushToQuestionVC() {
        let questionVC = self.storyboard?.instantiateViewControllerWithIdentifier("QuestionVC") as! QuestionVC
        self.navigationController?.pushViewController(questionVC, animated: true)
    }
    
    func pushToEnableGPS() {
        let enableGPSVC = self.storyboard?.instantiateViewControllerWithIdentifier("EnableGPSVC") as! EnableGPSVC
        self.navigationController?.pushViewController(enableGPSVC, animated: true)
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
