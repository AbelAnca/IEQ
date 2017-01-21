//
//  FinalVC.swift
//  IEQ
//
//  Created by Abel Anca on 12/11/15.
//  Copyright © 2015 IEQ. All rights reserved.
//

import UIKit
import MessageUI

class FinalVC: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var btnContactUs: UIButton!

    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Custom Methods
    
    func setupUI() {
        // Setup UI
        btnLogout.layer.cornerRadius                = 8
        btnLogout.layer.borderWidth                 = 1
        btnLogout.layer.borderColor                 = UIColor.white.cgColor
        
        btnContactUs.layer.cornerRadius             = 8
        btnContactUs.layer.borderWidth              = 1
        btnContactUs.layer.borderColor              = UIColor.white.cgColor
    }
    
    // MARK: - Action Methods
    @IBAction func btnLogot_Action(_ sender: AnyObject) {
       UserDefManager.logout()
    }

    @IBAction func btnContactUs(_ sender: Any) {
        showEmailError()
    }
    
    // MARK: - Email Methods
    
    func showEmailError() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController       = configuredMailComposeViewController()
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
        else {
            showSendMailErrorAlert()
        }
    }
    
    fileprivate func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC                  = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate  = self
        
        let subject             = "Contact"
        let messageBody         = "Hey IEQ, \n"
        
        mailComposerVC.setToRecipients(["support@rweducate.com"])
        mailComposerVC.setSubject(subject)
        mailComposerVC.setMessageBody(messageBody, isHTML: false)
        
        return mailComposerVC
    }
    
    fileprivate func showSendMailErrorAlert() {
        let alert = Utils.okAlert("Oops", message: "Your device doesn't have any mail accounts added.")
        present(alert, animated: true, completion: nil)
    }
    
    internal func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .sent:
            controller.dismiss(animated: true, completion: {
            })
            
        default:
            controller.dismiss(animated: true, completion: {
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    // MARK: - MemoryManagement Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
