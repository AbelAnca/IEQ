//
//  PopoverRoleVC.swift
//  IEQ
//
//  Created by Abel Anca on 12/3/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit

protocol PopoverRoleVCDelegate {
    func didSelectDataInPopover(_ obj: String)
}

class PopoverRoleVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var delegate: PopoverRoleVCDelegate?
    
    var arrData: [String]?
    
    @IBOutlet var tblView: UITableView!
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let arrData = arrData {
            return arrData.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") 
        
        if let arrData = arrData {
            let name = arrData[indexPath.row]
            cell?.textLabel?.text = name
        }
        return cell!
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let arrData = arrData {
            let name             = arrData[indexPath.row]
            self.delegate?.didSelectDataInPopover(name)
        }
        dismiss(animated: true, completion: nil)
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
