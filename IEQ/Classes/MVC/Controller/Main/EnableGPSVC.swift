//
//  EnableGPSVC.swift
//  IEQ
//
//  Created by Abel Anca on 4/6/16.
//  Copyright © 2016 IEQ. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import KVNProgress
import CoreLocation

class EnableGPSVC: UIViewController, CLLocationManagerDelegate, PopoverRoleVCDelegate {
    
    @IBOutlet weak var txfOrganizationName: UITextField!
    @IBOutlet weak var lblLatitude: UITextField!
    @IBOutlet weak var lblLongtude: UITextField!
    @IBOutlet weak var txvDescription: UITextView!
    @IBOutlet weak var btnEnableGPS: UIButton!
    @IBOutlet weak var btnSelectOrganization: UIButton!
    @IBOutlet weak var txfOrganizationType: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var arrOrganizationTypes: [[String: AnyObject]]?
    var selectedOrganizationType : [String: AnyObject]?
    
    var longitude           = Double()
    var latitude            = Double()
    
    let locationManager = CLLocationManager()
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        getOrganizationTypes_APICall()
    }

    // MARK: - Custom Methods
    
    func setupUI() {
        btnEnableGPS.backgroundColor             = UIColor.clear
        btnEnableGPS.layer.cornerRadius          = 8
        btnEnableGPS.layer.borderWidth           = 0.2
        btnEnableGPS.layer.borderColor           = UIColor.black.cgColor
        btnEnableGPS.clipsToBounds               = true
        
        txvDescription.backgroundColor             = UIColor.clear
        txvDescription.layer.cornerRadius          = 8
        txvDescription.layer.borderWidth           = 0.2
        txvDescription.layer.borderColor           = UIColor.black.cgColor
        txvDescription.clipsToBounds               = true
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            findMyLocation()
        }
        
        setupTitleBtnEnableGPS()
    }
    
    func findMyLocation() {
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func showLocationAcessDeniedAlert() {
        let alertController     = UIAlertController(title: "ACCESS DENIED!",
                                                message: "The location permission was not authorized. Please enable it in Settings to continue.",
                                                preferredStyle: .alert)
        
        let settingsAction      = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
        
        let cancelAction        = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func setupTitleBtnEnableGPS() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            btnEnableGPS.setTitle("ENABLE GPS", for: UIControlState())
            
        case .authorizedWhenInUse:
            btnEnableGPS.setTitle("FIND ORGANIZATION", for: UIControlState())
            
        case .denied:
            btnEnableGPS.setTitle("ACCESS DENIED", for: UIControlState())
            
        default:
            break
        }
    }
    
    func checkIfFieldsAreFilled() -> Bool {
        if let strName = txfOrganizationName.text {
            if strName.utf16.count == 0 {
                return false
            }
        }
        
        if let strDesc = txvDescription.text {
            if strDesc.utf16.count == 0 {
                return false
            }
        }
        
        if let strType = txfOrganizationType.text {
            if strType.utf16.count == 0 {
                return false
            }
        }
        
        return true
    }
    
    // MARK: - API Methods
    
    func getOrganizationTypes_APICall() {
        
        btnSelectOrganization.isHidden = true
        spinner.startAnimating()
        
        appDelegate.manager.request("\(K_API_MAIN_URL)\(k_API_OrganizationTypes)", method: .get)
            .responseJSON { (response) -> Void in
                
                let apiManager              = APIManager()
                apiManager.handleResponse(response.response, json: response.result.value as AnyObject?)
                
                if let error = apiManager.error {
                    if error.strErrorCode == "401" {
                        //=>    Session expired -> force user to login again
                        self.btnLogout_Action(error)
                    }
                    else {
                        if let message = error.strMessage {
                            self.spinner.stopAnimating()
                            self.btnSelectOrganization.isHidden = false
                            
                            let alert = Utils.okAlert("Error", message: message)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                else
                    if let data = apiManager.data {
                        if let items = data["items"] as? [[String: AnyObject]] {
                            self.arrOrganizationTypes = items
                            
                            self.spinner.stopAnimating()
                            self.btnSelectOrganization.isHidden = false
                        }
                    }
                
                self.spinner.stopAnimating()
                self.btnSelectOrganization.isHidden = false
        }
    }
    
    func getOrganizationForCurrentLocation() {
        if let _ = appDelegate.curUser {
            
            var dictParams = [String : AnyObject]()
            
            // FOR TEST !!!
            //self.longitude                       = -114.0912223288317
            //self.latitude                        = 51.05230309236315
            
            dictParams["longitude"]         = self.longitude as AnyObject?
            dictParams["latitude"]          = self.latitude as AnyObject?
            
            KVNProgress.show(withStatus: "Please wait...")
            
            appDelegate.manager.request("\(K_API_MAIN_URL)\(k_API_GetOrganizationByLocation)", method: .post, parameters: dictParams)
                .responseJSON { (response) -> Void in
                    
                    let apiManager              = APIManager()
                    apiManager.handleResponse(response.response, json: response.result.value as AnyObject?)
                    
                    if let error = apiManager.error {
                        KVNProgress.dismiss()
                        
                        if error.strErrorCode == "401" {
                            //=>    Session expired -> force user to login again
                            self.btnLogout_Action(error)
                        }
                        else {
                            if let message = error.strMessage {
                                
                                let alert = UIAlertController(title: "Error", message: "\(message). \n\nDo you want to add new organization? \n\n (If YES, please complete all above fields!)", preferredStyle: .alert)
                                
                                let okAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                                let addAction = UIAlertAction(title: "Add", style: .default, handler: { (action) in
                                    self.txfOrganizationName.isEnabled = true
                                    self.txfOrganizationName.becomeFirstResponder()
                                    
                                    self.txvDescription.isEditable = true
                                    
                                    self.btnEnableGPS.setTitle("ADD NEW ORGANIZATION", for: UIControlState())
                                })
                                
                                alert.addAction(okAction)
                                alert.addAction(addAction)
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                    else
                        if let data = apiManager.data {
                            if let strOrganizationId = data["id"] as? String {
                                appDelegate.defaults.set(strOrganizationId, forKey: k_UserDef_OrganizationID)
                                appDelegate.defaults.synchronize()
                                
                                self.btnEnableGPS.setTitle("START QUESTIONS", for: UIControlState())
                            }
                            
                            if let name = data["name"] as? String {
                                self.txfOrganizationName.text               = name
                            }
                            
                            if let location = data["location"] as? [String : NSNumber] {
                                if let latitude = location["latitude"] {
                                    self.lblLatitude.text        = "Latitude: \(latitude)"
                                }
                                
                                if let longitude = location["longitude"] {
                                    self.lblLongtude.text        = "Longitude: \(longitude)"
                                }
                            }
                            
                            if let description = data["description"] as? String {
                                self.txvDescription.text        = description
                            }
                            
                            if let type = data["type"] as? String {
                                self.txfOrganizationType.text        = type
                            }
                            
                            KVNProgress.dismiss()
                        }
                        else {
                            KVNProgress.dismiss()
                            KVNProgress.showError(withStatus: "Something wrong happened. Please contact developers quicly! \n\n\n \(response.response?.description)")
                        }
            }
        }
    }
    
    func addOrganization() {
        if let _ = appDelegate.curUser {
           
            //=>    Create disctParams
            var dictParams = [String : AnyObject]()
            
            dictParams["name"]         = txfOrganizationName.text! as AnyObject?
            dictParams["description"]  = txvDescription.text! as AnyObject?
            dictParams["type"]         = txfOrganizationType.text! as AnyObject?
            
            var dictLocation = [String : AnyObject]()
            dictLocation["longitude"]         = longitude as AnyObject?
            dictLocation["latitude"]          = latitude as AnyObject?
            
            dictParams["location"]         = dictLocation as AnyObject?
            
            debugPrint("PARAMS = \(dictParams)")
            
            KVNProgress.show(withStatus: "Please wait...")
            
            appDelegate.manager.request("\(K_API_MAIN_URL)\(k_API_AddOrganization)", method: .post, parameters: dictParams, headers: nil)            
                .responseJSON { (response) -> Void in
                    
                    let apiManager              = APIManager()
                    apiManager.handleResponse(response.response, json: response.result.value as AnyObject?)
                    
                    if let error = apiManager.error {
                        KVNProgress.dismiss()
                        
                        if error.strErrorCode == "401" {
                            //=>    Session expired -> force user to login again
                            self.btnLogout_Action(error)
                        }
                        else {
                            if let message = error.strMessage {
                                let alert = Utils.okAlert("Oops", message: message)
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                    else
                        if let data = apiManager.data {
                            if let strOrganizationId = data["id"] as? String {
                                appDelegate.defaults.set(strOrganizationId, forKey: k_UserDef_OrganizationID)
                                appDelegate.defaults.synchronize()
                                
                                self.btnEnableGPS.setTitle("START QUESTIONS", for: UIControlState())
                            }
                            
                            KVNProgress.dismiss()
                        }
                        else {
                            KVNProgress.dismiss()
                            KVNProgress.showError(withStatus: "Something wrong happened. Please contact developers quicly! \n\n\n \(response.response)")
                        }
            }
        }
    }
    
    // MARK: - Action Methods
    
    @IBAction func enableGPS_Action() {
        if btnEnableGPS.currentTitle == "START QUESTIONS" {
            let questionVC = self.storyboard?.instantiateViewController(withIdentifier: "QuestionVC") as! QuestionVC
            self.navigationController?.pushViewController(questionVC, animated: true)
        }
        else
            if btnEnableGPS.currentTitle == "ADD NEW ORGANIZATION" {
                if checkIfFieldsAreFilled() {
                    //=>    Call API
                    addOrganization()
                }
                else {
                    let alert = Utils.okAlert("Oops", message: "Please complete all fields!")
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else {
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined:
                    findMyLocation()
                    
                case .authorizedWhenInUse:
                    getOrganizationForCurrentLocation()
                    
                case .denied:
                    showLocationAcessDeniedAlert()
                    
                default:
                    break
                }
                
                setupTitleBtnEnableGPS()
        }
    }
    
    @IBAction func btnLogout_Action(_ sender: AnyObject) {
        appDelegate.curUser = nil
        
        // Remove from NSUserDefaults
        appDelegate.defaults.removeObject(forKey: k_UserDef_LoggedInUserID)
        appDelegate.defaults.removeObject(forKey: k_UserDef_OrganizationID)
        appDelegate.defaults.synchronize()
        
        // Present LoginVC
        let loginNC = storyboard?.instantiateViewController(withIdentifier: "LoginVC_NC") as! UINavigationController
        navigationController?.popToRootViewController(animated: true)
        navigationController?.present(loginNC, animated: true, completion: { () -> Void in
            
        })
    }
    
    @IBAction func btnSelectOrganizationType_Action(_ sender: AnyObject) {
        
        let dsPopoverVC                             = self.storyboard?.instantiateViewController(withIdentifier: "PopoverRoleVC") as! PopoverRoleVC
        dsPopoverVC.delegate                        = self
        
        var arrNames = [String]()
        
        if let arrTypes = arrOrganizationTypes {
            for role in arrTypes {
                if let name = role["name"] {
                    arrNames.append(name as! String)
                }
            }
        }
        
        dsPopoverVC.arrData = arrNames
        
        dsPopoverVC.modalPresentationStyle   = UIModalPresentationStyle.popover
        dsPopoverVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.right
        dsPopoverVC.popoverPresentationController?.sourceView = btnSelectOrganization
        dsPopoverVC.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: btnSelectOrganization.frame.size.width, height: btnSelectOrganization.frame.size.height)
        dsPopoverVC.preferredContentSize = CGSize(width: 250,height: CGFloat(44 * arrNames.count))
        
        present(dsPopoverVC, animated: true, completion: nil)
    }
    
    @IBAction func btnBackground_Action(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locations = manager.location {
            let coordinate = locations.coordinate
            latitude = coordinate.latitude
            longitude = coordinate.longitude
            
            self.lblLatitude.text        = "Latitude: \(latitude)"
            self.lblLongtude.text        = "Longitude: \(longitude)"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        setupTitleBtnEnableGPS()
    }
    
    // MARK: - PopOverRoleVCDelegate Methods
    func didSelectDataInPopover(_ obj: String) {
        txfOrganizationType.text = obj
        
        if let arrTypes = arrOrganizationTypes {
            for type in arrTypes {
                if let name = type["name"] as? String {
                    if name == obj {
                        selectedOrganizationType = type
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
