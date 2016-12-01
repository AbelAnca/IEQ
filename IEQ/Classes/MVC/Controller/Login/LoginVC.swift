//
//  LoginVC.swift
//  IEQ
//
//  Created by Abel Anca on 12/1/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import Alamofire
import KVNProgress

class LoginVC: BaseVC, UITextFieldDelegate {
    
    @IBOutlet var txfPhoneUseraemeOrEmail: UITextField!
    @IBOutlet var txfPassword: UITextField!
    @IBOutlet var btnLogin: UIButton!
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        txfPhoneUseraemeOrEmail.text = "ancaabel"
        txfPassword.text = "qwerty"
                
        setupUI()
    }

    // MARK: - Custom Methods
    func setupUI() {
        btnLogin.backgroundColor              = UIColor.clear
        btnLogin.layer.cornerRadius           = 8
        btnLogin.layer.borderWidth            = 0.2
        btnLogin.layer.borderColor            = UIColor.black.cgColor
        btnLogin.clipsToBounds                = true
    }
    
    func checkValidationForAllFields() -> Bool {
        var isValid = false
        
        //=>  It is username
        if txfPhoneUseraemeOrEmail.text!.utf16.count == 0 {
            //isValid = false
            return false
        }
        else {
            isValid = true
        }
        
        if self.txfPassword.text!.utf16.count == 0 {
            //isValid = false
            return false
        }
        else {
            isValid = true
        }
        
        return isValid
    }

    func login() {
        
        if checkValidationForAllFields() == true {
            //=>    Hide keyboard if visible
            resignAllResponders()
            
            //=>    Call API
            login_APICall()
        }
        else {
            let alert = Utils.okAlert("Attention", message: "Please enter username and password")
            present(alert, animated: true, completion: nil)
        }
    }
    
    func pushSignUpVC() {
        let signUpVC = storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    func resignAllResponders() {
        if txfPhoneUseraemeOrEmail.isFirstResponder {
            txfPhoneUseraemeOrEmail.resignFirstResponder()
        }
        
        if txfPassword.isFirstResponder {
            txfPassword.resignFirstResponder()
        }
    }
    
    // MARK: - API Methods
    
    func login_APICall() {
        
        KVNProgress.show(withStatus: "Please wait...")
        
        let parameters: Parameters = [
            "username": txfPhoneUseraemeOrEmail.text!,
            "password": txfPassword.text!
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json; charset=utf-8"
        ]
        
        Alamofire.request("\(K_API_MAIN_URL)\(k_API_User_Login)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { (response) -> Void in
                
                let apiManager              = APIManager()
                apiManager.handleResponse(response.response, json: response.result.value as AnyObject?)
                
                if let error = apiManager.error {
                    KVNProgress.dismiss()
                    
                    if let message = error.strMessage {
                        let alert = Utils.okAlert("Error", message: message)
                        self.present(alert, animated: true, completion: nil)
                    }
                    else {
                        let alert = Utils.okAlert("Error", message: "Something strange happened. Please try again!")
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
    
    // MARK: - Action Methods
    @IBAction func btnSignUp_Action(_ sender: AnyObject) {
        pushSignUpVC()
    }
    
    @IBAction func btnLogin_Action(_ sender: AnyObject) {
        login()
    }
    
    // MARK: - UITextFieldDelegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == txfPhoneUseraemeOrEmail {
            txfPhoneUseraemeOrEmail.resignFirstResponder()
            txfPassword.becomeFirstResponder()
        }
        else
            if textField == txfPassword {
                txfPassword.resignFirstResponder()
        }
        
        return false
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
