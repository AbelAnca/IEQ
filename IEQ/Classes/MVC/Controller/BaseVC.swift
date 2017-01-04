//
//  BaseVC.swift
//  IEQ
//
//  Created by Abel Anca on 12/11/15.
//  Copyright © 2015 IEQ. All rights reserved.
//

import UIKit

class BaseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Public Methods
    
    func dismissViewController(_ animated: Bool) {
        navigationController?.dismiss(animated: animated, completion: { () -> Void in
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
