//
//  SignUpVC.swift
//  IEQ
//
//  Created by Abel Anca on 12/3/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import Alamofire
import KVNProgress

class SignUpVC: UIViewController, UITextFieldDelegate, PopoverRoleVCDelegate {
  
    @IBOutlet var txfUsername: UITextField!
    @IBOutlet var txfFirstName: UITextField!
    @IBOutlet var txfLastName: UITextField!
    @IBOutlet var txfEmailAddress: UITextField!
    @IBOutlet var txfPhoneNumber: UITextField!
    @IBOutlet var txfPassword: UITextField!
    @IBOutlet var txfConfirmPass: UITextField!
    @IBOutlet var btnSelectRole: UIButton!
    @IBOutlet var txfRole: UITextField!
    
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var btnEnterTheApp: UIButton!
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    var arrRoles: [[String: AnyObject]]?
    var selectedRole : [String: AnyObject]?
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getRoles_APICall()
        
        txfUsername.text = "ancaabel"
        txfFirstName.text = "Anca"
        txfLastName.text = "Abel"
        txfEmailAddress.text = "abel.anca95@gmail.com"
        txfPhoneNumber.text = "0754823095"
        txfPassword.text = "qwerty"
        txfConfirmPass.text = "qwerty"
        
        setupUI()
    }

    // MARK: - Custom Methods
    
    func setupUI() {
        btnEnterTheApp.backgroundColor              = UIColor.clearColor()
        btnEnterTheApp.layer.cornerRadius           = 8
        btnEnterTheApp.layer.borderWidth            = 0.2
        btnEnterTheApp.layer.borderColor            = UIColor.blackColor().CGColor
        btnEnterTheApp.clipsToBounds                = true
        
        btnBack.layer.cornerRadius                  = btnBack.frame.size.height / 2
        btnBack.clipsToBounds                       = true
        
    }
    
    func pushQuestionVC() {
        let questionVC = storyboard?.instantiateViewControllerWithIdentifier("QuestionVC") as! QuestionVC
        navigationController?.pushViewController(questionVC, animated: true)
    }
    
    func register() {
        if canRegister() == true {
            
            //=>    Hide keyboard if visible
            resignAllResponders()
            
            //=>    Call API
            registerAccount_APICall()
            
        }
        else {
            let alert = Utils.okAlert("Attention", message: "Please complete all the fields")
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func resignAllResponders() {
        if txfUsername.isFirstResponder() {
            txfUsername.resignFirstResponder()
        }
        
        if txfFirstName.isFirstResponder() {
            txfFirstName.resignFirstResponder()
        }
        
        if txfLastName.isFirstResponder() {
            txfLastName.resignFirstResponder()
        }
        
        if txfEmailAddress.isFirstResponder() {
            txfEmailAddress.resignFirstResponder()
        }
        
        if txfPhoneNumber.isFirstResponder() {
            txfPhoneNumber.resignFirstResponder()
        }
        
        if txfPassword.isFirstResponder() {
            txfPassword.resignFirstResponder()
        }
        
        if txfConfirmPass.isFirstResponder(){
            txfConfirmPass.resignFirstResponder()
        }
    }
    
    func canRegister() -> Bool {
       
        if let username = txfUsername.text {
            if !Utils.isValidUsername(username) {
                return false
            }
        }
        
        if let firstName = txfFirstName.text {
            if !Utils.isValidFirstName(firstName) {
                return false
            }
        }
        
        if let lastName = txfLastName.text {
            if !Utils.isValidLastName(lastName) {
                return false
            }
        }
        
        if let email = txfEmailAddress.text {
            if !Utils.isValidEmail(email) {
                return false
            }
        }
        
        if let phone = txfPhoneNumber.text {
            if !Utils.isValidPhoneNumber(phone) {
                return false
            }
        }
        
        if let password = txfPassword.text {
            if !Utils.isValidPassword(password) {
                return false
            }
            
            if let confirmPass = txfConfirmPass.text {
                if password != confirmPass {
                    return false
                }
            }
        }
        
        if let role = txfRole.text {
            if !Utils.isValidRole(role) {
                return false
            }
        }

        return true
    }
    
    // MARK: - API Methods
    
    func registerAccount_APICall() {
        
        let dictParams : [String : AnyObject]      = ["username": "\(txfUsername.text!)" , "firstName": "\(txfFirstName.text!)", "lastName": "\(txfLastName.text!)", "email": "\(txfEmailAddress.text!)", "phone": "\(txfPhoneNumber.text!)", "password": "\(txfPassword.text!)", "selectedRoles": [selectedRole!] ]
        print(dictParams)
        
        KVNProgress.showWithStatus("Please wait...")
        
        Alamofire.request(.POST, "\(K_API_MAIN_URL)\(k_API_User_Register)", parameters: dictParams, encoding: .JSON)
            .responseJSON { (response) -> Void in
                
                let apiManager              = APIManager()
                apiManager.handleResponse(response.response, json: response.result.value)
                
                if let error = apiManager.error {
                    if let message = error.strMessage {
                        KVNProgress.dismiss()
                        
                        let alert = Utils.okAlert("Error", message: message)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
                else
                    if let data = apiManager.data {
                        if let token = data["authorization"] as? String {
                            if let username = data["username"] as? String {
                                if let id = data["id"] as? String {
                                    
                                    appDelegate.defaults.setObject(id, forKey: k_UserDef_LoggedInUserID)
                                    appDelegate.defaults.synchronize()
                                    
                                    let user = User()
                                    user.u_id = id
                                    user.u_token = token
                                    user.u_username = username
                                    
                                    try! appDelegate.realm.write {
                                        appDelegate.realm.add(user)
                                    }
                                    
                                    appDelegate.curUser = user
                                    
                                    //>     Call this method to set custom headers to alamofire manager
                                    //appDelegate.setupAlamofireManager()
                                }
                            }
                        }
                        KVNProgress.dismiss()
                        
                        self.pushQuestionVC()
                }
                KVNProgress.dismiss()
        }
        
    }
    
    func getRoles_APICall() {
        
        btnSelectRole.hidden = true
        spinner.startAnimating()
        
        Alamofire.request(.GET, "\(K_API_MAIN_URL)\(k_API_Roles)")
            .responseJSON { (response) -> Void in
                
                let apiManager              = APIManager()
                apiManager.handleResponse(response.response, json: response.result.value)
                
                if let error = apiManager.error {
                    if let message = error.strMessage {
                        self.spinner.stopAnimating()
                        self.btnSelectRole.hidden = false
                        
                        let alert = Utils.okAlert("Error", message: message)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
                else
                    if let data = apiManager.data {
                        if let items = data["items"] as? [[String: AnyObject]] {
                            self.arrRoles = items
                            self.spinner.stopAnimating()
                            self.btnSelectRole.hidden = false
                        }
                }
                self.spinner.stopAnimating()
                self.btnSelectRole.hidden = false
        }
    }
    
    // MARK: - Action Methods
    
    
    @IBAction func btnSignUp_Action(sender: AnyObject) {
        register()
    }
    
    @IBAction func btnBack_Action(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnSelectRole_Action(sender: AnyObject) {

        let dsPopoverVC                             = self.storyboard?.instantiateViewControllerWithIdentifier("PopoverRoleVC") as! PopoverRoleVC
        dsPopoverVC.delegate                        = self
        
        var arrNames = [String]()
        
        if let arrRoles = arrRoles {
            for role in arrRoles {
                if let name = role["name"] {
                    arrNames.append(name as! String)
                }
            }
        }
        
        dsPopoverVC.arrData = arrNames

        dsPopoverVC.modalPresentationStyle   = UIModalPresentationStyle.Popover
        dsPopoverVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.Right
        dsPopoverVC.popoverPresentationController?.sourceView = btnSelectRole
        dsPopoverVC.popoverPresentationController?.sourceRect = CGRectMake(0, 0, btnSelectRole.frame.size.width, btnSelectRole.frame.size.height)
        dsPopoverVC.preferredContentSize = CGSizeMake(250,CGFloat(44 * arrNames.count))
        
        presentViewController(dsPopoverVC, animated: true, completion: nil)
    }
    
    // MARK: - UITextFieldDelegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == txfUsername {
            txfUsername.resignFirstResponder()
            txfFirstName.becomeFirstResponder()
        }
        else
            if textField == txfFirstName {
                txfFirstName.resignFirstResponder()
                txfLastName.becomeFirstResponder()
            }
            else
                if textField == txfLastName {
                    txfLastName.resignFirstResponder()
                    txfEmailAddress.becomeFirstResponder()
                }
                else
                    if textField == txfEmailAddress {
                        txfEmailAddress.resignFirstResponder()
                        txfPhoneNumber.becomeFirstResponder()
                    }
                    else
                        if textField == txfPhoneNumber {
                            txfPhoneNumber.resignFirstResponder()
                            txfPassword.becomeFirstResponder()
                        }
                        else
                            if textField == txfPassword {
                                txfPassword.resignFirstResponder()
                                txfConfirmPass.becomeFirstResponder()
                            }
                            else
                                if textField == txfConfirmPass {
                                    txfConfirmPass.resignFirstResponder()
        }
        
        return false
    }
    
    // MARK: - PopOverRoleVCDelegate Methods
    func didSelectDataInPopover(obj: String) {
        txfRole.text = obj
        
        if let arrRoles = arrRoles {
            for role in arrRoles {
                if let name = role["name"] as? String {
                    if name == obj {
                        selectedRole = role
                    }
                }
            }
        }
    }

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
