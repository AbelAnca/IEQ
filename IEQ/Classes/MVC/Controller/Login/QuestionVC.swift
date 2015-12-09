//
//  QuestionVC.swift
//  IEQ
//
//  Created by Abel Anca on 12/8/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

class QuestionVC: UIViewController {

    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loadQuestion_APICall()
        
        /*
        let user = appDelegate.realm.objects(User)
        print(user)
        */
    }

    // MARK: - Custom Methods
    
    // MARK: - API Methods
    
    func loadQuestion_APICall() {
        
        if let user = appDelegate.curUser {
            
            var dictDefaultHeaders      = [String : String]()
            
            dictDefaultHeaders["X-IQE-Auth"] = "\(user.u_token)"
            dictDefaultHeaders["content-type"] = "application/json; charset=utf-8"
            
            
            Alamofire.request(.GET, "\(K_API_MAIN_URL)\(k_API_Question)", parameters: nil, encoding: .JSON, headers: dictDefaultHeaders)
                .responseJSON { (response) -> Void in
                    let apiManager              = APIManager()
                    apiManager.handleResponse(response.response, json: response.result.value)
                    
                    if let error = apiManager.error {
                        if let message = error.strMessage {
                            let alert = Utils.okAlert("Error", message: message)
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                    else
                        if let data = apiManager.data {
                            print(data)
                            
                            /*
                            if let items = data["items"] as? [[String: AnyObject]] {
                            for item in items {
                            print(item["title"])
                            }
                            }
                            */
                            
                            
                    }
            }
        }
    }
    
    // MARK: - Action Methods
    
    // MARK: - MemoryManagement Methods
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
