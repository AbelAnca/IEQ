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

class SignUpVC: BaseVC, UITextFieldDelegate, PopoverRoleVCDelegate {
  
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
        
        setupUI()
    }

    // MARK: - Custom Methods
    
    func setupUI() {
        btnEnterTheApp.backgroundColor              = UIColor.clear
        btnEnterTheApp.layer.cornerRadius           = 8
        btnEnterTheApp.layer.borderWidth            = 0.2
        btnEnterTheApp.layer.borderColor            = UIColor.black.cgColor
        btnEnterTheApp.clipsToBounds                = true
        
        btnBack.layer.cornerRadius                  = btnBack.frame.size.height / 2
        btnBack.clipsToBounds                       = true
        
    }
    
    func pushQuestionVC() {
        let questionVC = storyboard?.instantiateViewController(withIdentifier: "QuestionVC") as! QuestionVC
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
            present(alert, animated: true, completion: nil)
        }
    }
    
    func resignAllResponders() {
        if txfUsername.isFirstResponder {
            txfUsername.resignFirstResponder()
        }
        
        if txfFirstName.isFirstResponder {
            txfFirstName.resignFirstResponder()
        }
        
        if txfLastName.isFirstResponder {
            txfLastName.resignFirstResponder()
        }
        
        if txfEmailAddress.isFirstResponder {
            txfEmailAddress.resignFirstResponder()
        }
        
        if txfPhoneNumber.isFirstResponder {
            txfPhoneNumber.resignFirstResponder()
        }
        
        if txfPassword.isFirstResponder {
            txfPassword.resignFirstResponder()
        }
        
        if txfConfirmPass.isFirstResponder{
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
            if !Utils.isValidPhoneNumber(phoneNumber: phone) {
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
        
        let dictParams : Parameters             = ["username": "\(txfUsername.text!)",
                                                      "firstName": "\(txfFirstName.text!)",
                                                      "lastName": "\(txfLastName.text!)",
                                                      "email": "\(txfEmailAddress.text!)",
                                                      "phone": "\(txfPhoneNumber.text!)",
                                                      "password": "\(txfPassword.text!)",
                                                      "selectedRoles": [selectedRole!]]
        print(dictParams)
        
        KVNProgress.show(withStatus: "Please wait...")
        
        Alamofire.request("\(K_API_MAIN_URL)\(k_API_User_Register)", method: .post, parameters: dictParams, encoding: JSONEncoding.default, headers: appDelegate.headers)
            .responseJSON { (response) -> Void in
                
                let apiManager              = APIManager()
                apiManager.handleResponse(response.response, json: response.result.value as AnyObject?)
                
                if let error = apiManager.error {
                    if let message = error.strMessage {
                        KVNProgress.dismiss()
                        
                        let alert = Utils.okAlert("Error", message: message)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                else
                    if let data = apiManager.data {
                        if let user = RLMManager.sharedInstance.saveUser(data) {
                            KVNProgress.showSuccess(withStatus: "Successfully logged in as \(user.username)", completion: { () -> Void in
                                self.dismissViewController(true)
                                
                                //=>     Call this method to set custom headers to alamofire manager
                                appDelegate.setupAlamofireManager()
                            })
                            
                            return
                        }
                        else {
                            KVNProgress.showError(withStatus: "Failed to save user locally. Please try again!")
                        }
                    }
                    else {
                        KVNProgress.showError(withStatus: "Failed to LOGIN. Please try again!")
                    }
        }
        
    }
    
    func getRoles_APICall() {
        
        btnSelectRole.isHidden = true
        spinner.startAnimating()
        
        Alamofire.request("\(K_API_MAIN_URL)\(k_API_Roles)", encoding: JSONEncoding.default, headers: appDelegate.headers)
            .responseJSON { response in // method defaults to `.get`
                
                let apiManager              = APIManager()
                apiManager.handleResponse(response.response, json: response.result.value as AnyObject?)
                
                if let error = apiManager.error {
                    if let message = error.strMessage {
                        self.spinner.stopAnimating()
                        self.btnSelectRole.isHidden = false
                        
                        let alert = Utils.okAlert("Error", message: message)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                else
                    if let data = apiManager.data {
                        if let items = data["items"] as? [[String: AnyObject]] {
                            self.arrRoles = items
                            self.spinner.stopAnimating()
                            self.btnSelectRole.isHidden = false
                        }
                }
                self.spinner.stopAnimating()
                self.btnSelectRole.isHidden = false
        }
    }
    
    // MARK: - Action Methods
    
    
    @IBAction func btnSignUp_Action(_ sender: AnyObject) {
        register()
    }
    
    @IBAction func btnBack_Action(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSelectRole_Action(_ sender: AnyObject) {

        let dsPopoverVC                             = self.storyboard?.instantiateViewController(withIdentifier: "PopoverRoleVC") as! PopoverRoleVC
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

        dsPopoverVC.modalPresentationStyle   = UIModalPresentationStyle.popover
        dsPopoverVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.right
        dsPopoverVC.popoverPresentationController?.sourceView = btnSelectRole
        dsPopoverVC.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: btnSelectRole.frame.size.width, height: btnSelectRole.frame.size.height)
        dsPopoverVC.preferredContentSize = CGSize(width: 250,height: CGFloat(44 * arrNames.count))
        
        present(dsPopoverVC, animated: true, completion: nil)
    }
    
    // MARK: - UITextFieldDelegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
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
    func didSelectDataInPopover(_ obj: String) {
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
