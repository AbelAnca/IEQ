//
//  FinalVC.swift
//  IEQ
//
//  Created by Abel Anca on 12/11/15.
//  Copyright © 2015 IEQ. All rights reserved.
//

import UIKit

class FinalVC: UIViewController {
    
    @IBOutlet weak var btnLogout: UIButton!

    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Custom Methods
    
    func setupUI() {
        // Setup UI
        btnLogout.layer.cornerRadius           = 8
        btnLogout.layer.borderWidth            = 1
        btnLogout.layer.borderColor            = UIColor.white.cgColor
    }
    
    // MARK: - Action Methods
    @IBAction func btnLogot_Action(_ sender: AnyObject) {
       UserDefManager.logout()
    }

    // MARK: - MemoryManagement Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
