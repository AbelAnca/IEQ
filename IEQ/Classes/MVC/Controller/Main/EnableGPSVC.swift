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
    
    @IBOutlet weak var txfOrganisationName: UITextField!
    @IBOutlet weak var lblLatitude: UITextField!
    @IBOutlet weak var lblLongtude: UITextField!
    @IBOutlet weak var txvDescription: UITextView!
    @IBOutlet weak var btnEnableGPS: UIButton!
    @IBOutlet weak var btnSelectOrganisation: UIButton!
    @IBOutlet weak var txfOrganisationType: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var arrOrganisationTypes: [[String: AnyObject]]?
    var selectedOrganisationType : [String: AnyObject]?
    
    var longitude           = Double()
    var latitude            = Double()
    
    let locationManager = CLLocationManager()
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        getOrganisationTypes_APICall()
    }

    // MARK: - Custom Methods
    
    func setupUI() {
        btnEnableGPS.backgroundColor             = UIColor.clearColor()
        btnEnableGPS.layer.cornerRadius          = 8
        btnEnableGPS.layer.borderWidth           = 0.2
        btnEnableGPS.layer.borderColor           = UIColor.blackColor().CGColor
        btnEnableGPS.clipsToBounds               = true
        
        txvDescription.backgroundColor             = UIColor.clearColor()
        txvDescription.layer.cornerRadius          = 8
        txvDescription.layer.borderWidth           = 0.2
        txvDescription.layer.borderColor           = UIColor.blackColor().CGColor
        txvDescription.clipsToBounds               = true
        
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
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
                                                preferredStyle: .Alert)
        
        let settingsAction      = UIAlertAction(title: "Settings", style: .Default) { (alertAction) in
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        
        let cancelAction        = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func setupTitleBtnEnableGPS() {
        switch CLLocationManager.authorizationStatus() {
        case .NotDetermined:
            btnEnableGPS.setTitle("ENABLE GPS", forState: .Normal)
            
        case .AuthorizedWhenInUse:
            btnEnableGPS.setTitle("FIND ORGANISATION", forState: .Normal)
            
        case .Denied:
            btnEnableGPS.setTitle("ACCESS DENIED", forState: .Normal)
            
        default:
            break
        }
    }
    
    func checkIfFieldsAreFilled() -> Bool {
        if let strName = txfOrganisationName.text {
            if strName.utf16.count == 0 {
                return false
            }
        }
        
        if let strDesc = txvDescription.text {
            if strDesc.utf16.count == 0 {
                return false
            }
        }
        
        if let strType = txfOrganisationType.text {
            if strType.utf16.count == 0 {
                return false
            }
        }
        
        return true
    }
    
    // MARK: - API Methods
    
    func getOrganisationTypes_APICall() {
        
        btnSelectOrganisation.hidden = true
        spinner.startAnimating()
        
        appDelegate.manager.request(.GET, "\(K_API_MAIN_URL)\(k_API_OrganisationTypes)")
            .responseJSON { (response) -> Void in
                
                let apiManager              = APIManager()
                apiManager.handleResponse(response.response, json: response.result.value)
                
                if let error = apiManager.error {
                    if error.strErrorCode == "401" {
                        //=>    Session expired -> force user to login again
                        self.btnLogout_Action(error)
                    }
                    else {
                        if let message = error.strMessage {
                            self.spinner.stopAnimating()
                            self.btnSelectOrganisation.hidden = false
                            
                            let alert = Utils.okAlert("Error", message: message)
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                }
                else
                    if let data = apiManager.data {
                        if let items = data["items"] as? [[String: AnyObject]] {
                            self.arrOrganisationTypes = items
                            
                            self.spinner.stopAnimating()
                            self.btnSelectOrganisation.hidden = false
                        }
                    }
                
                self.spinner.stopAnimating()
                self.btnSelectOrganisation.hidden = false
        }
    }
    
    func getOrganisationForCurrentLocation() {
        if let _ = appDelegate.curUser {
            
            var dictParams = [String : AnyObject]()
            
            // FOR TEST !!!
            //self.longitude                       = 21.300543183135066
            //self.latitude                        = 46.18252519561494
            
            dictParams["longitude"]         = self.longitude
            dictParams["latitude"]          = self.latitude
            
            KVNProgress.showWithStatus("Please wait...")
            
            appDelegate.manager.request(.POST, "\(K_API_MAIN_URL)\(k_API_GetOrganizationByLocation)", parameters: dictParams, encoding: .JSON)
                .responseJSON { (response) -> Void in
                    
                    let apiManager              = APIManager()
                    apiManager.handleResponse(response.response, json: response.result.value)
                    
                    if let error = apiManager.error {
                        KVNProgress.dismiss()
                        
                        if error.strErrorCode == "401" {
                            //=>    Session expired -> force user to login again
                            self.btnLogout_Action(error)
                        }
                        else {
                            if let message = error.strMessage {
                                
                                let alert = UIAlertController(title: "Error", message: "\(message). \n\nDo you want to add new organisation? \n\n (If YES, please complete all above fields!)", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                                let addAction = UIAlertAction(title: "Add", style: .Default, handler: { (action) in
                                    self.txfOrganisationName.enabled = true
                                    self.txfOrganisationName.becomeFirstResponder()
                                    
                                    self.txvDescription.editable = true
                                    
                                    self.btnEnableGPS.setTitle("ADD NEW ORGANISATION", forState: .Normal)
                                })
                                
                                alert.addAction(okAction)
                                alert.addAction(addAction)
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                        }
                    }
                    else
                        if let data = apiManager.data {
                            
                            if let strOrganizationId = data["id"] as? String {
                                appDelegate.defaults.setObject(strOrganizationId, forKey: k_UserDef_OrganizationID)
                                appDelegate.defaults.synchronize()
                                
                                self.btnEnableGPS.setTitle("START QUESTIONS", forState: .Normal)
                            }
                            
                            if let name = data["name"] as? String {
                                self.txfOrganisationName.text               = name
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
                                self.txfOrganisationType.text        = type
                            }
                            
                            KVNProgress.dismiss()
                        }
                        else {
                            KVNProgress.dismiss()
                            KVNProgress.showErrorWithStatus("Something wrong happened. Please contact developers quicly! \n\n\n \(response.response)")
                        }
            }
        }
    }
    
    func addOrganisation() {
        if let _ = appDelegate.curUser {
           
            //=>    Create disctParams
            var dictParams = [String : AnyObject]()
            
            dictParams["name"]         = txfOrganisationName.text!
            dictParams["description"]  = txvDescription.text!
            dictParams["type"]         = txfOrganisationType.text!
            
            var dictLocation = [String : AnyObject]()
            dictLocation["longitude"]         = longitude
            dictLocation["latitude"]          = latitude
            
            dictParams["location"]         = dictLocation
            
            debugPrint("PARAMS = \(dictParams)")
            
            KVNProgress.showWithStatus("Please wait...")
            
            appDelegate.manager.request(.POST, "\(K_API_MAIN_URL)\(k_API_AddOrganization)", parameters: dictParams, encoding: .JSON)
                .responseJSON { (response) -> Void in
                    
                    let apiManager              = APIManager()
                    apiManager.handleResponse(response.response, json: response.result.value)
                    
                    if let error = apiManager.error {
                        KVNProgress.dismiss()
                        
                        if error.strErrorCode == "401" {
                            //=>    Session expired -> force user to login again
                            self.btnLogout_Action(error)
                        }
                        else {
                            if let message = error.strMessage {
                                let alert = Utils.okAlert("Oops", message: message)
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                        }
                    }
                    else
                        if let data = apiManager.data {
                            if let strOrganizationId = data["id"] as? String {
                                appDelegate.defaults.setObject(strOrganizationId, forKey: k_UserDef_OrganizationID)
                                appDelegate.defaults.synchronize()
                                
                                self.btnEnableGPS.setTitle("START QUESTIONS", forState: .Normal)
                            }
                            
                            KVNProgress.dismiss()
                        }
                        else {
                            KVNProgress.dismiss()
                            KVNProgress.showErrorWithStatus("Something wrong happened. Please contact developers quicly! \n\n\n \(response.response)")
                        }
            }
        }
    }
    
    // MARK: - Action Methods
    
    @IBAction func enableGPS_Action() {
        if btnEnableGPS.currentTitle == "START QUESTIONS" {
            let questionVC = self.storyboard?.instantiateViewControllerWithIdentifier("QuestionVC") as! QuestionVC
            self.navigationController?.pushViewController(questionVC, animated: true)
        }
        else
            if btnEnableGPS.currentTitle == "ADD NEW ORGANISATION" {
                if checkIfFieldsAreFilled() {
                    //=>    Call API
                    addOrganisation()
                }
                else {
                    let alert = Utils.okAlert("Oops", message: "Please complete all fields!")
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            else {
                switch CLLocationManager.authorizationStatus() {
                case .NotDetermined:
                    findMyLocation()
                    
                case .AuthorizedWhenInUse:
                    getOrganisationForCurrentLocation()
                    
                case .Denied:
                    showLocationAcessDeniedAlert()
                    
                default:
                    break
                }
                
                setupTitleBtnEnableGPS()
        }
    }
    
    @IBAction func btnLogout_Action(sender: AnyObject) {
        appDelegate.curUser = nil
        
        // Remove from NSUserDefaults
        appDelegate.defaults.removeObjectForKey(k_UserDef_LoggedInUserID)
        appDelegate.defaults.removeObjectForKey(k_UserDef_OrganizationID)
        appDelegate.defaults.synchronize()
        
        // Present LoginVC
        let loginNC = storyboard?.instantiateViewControllerWithIdentifier("LoginVC_NC") as! UINavigationController
        navigationController?.popToRootViewControllerAnimated(true)
        navigationController?.presentViewController(loginNC, animated: true, completion: { () -> Void in
            
        })
    }
    
    @IBAction func btnSelectOrganisationType_Action(sender: AnyObject) {
        
        let dsPopoverVC                             = self.storyboard?.instantiateViewControllerWithIdentifier("PopoverRoleVC") as! PopoverRoleVC
        dsPopoverVC.delegate                        = self
        
        var arrNames = [String]()
        
        if let arrTypes = arrOrganisationTypes {
            for role in arrTypes {
                if let name = role["name"] {
                    arrNames.append(name as! String)
                }
            }
        }
        
        dsPopoverVC.arrData = arrNames
        
        dsPopoverVC.modalPresentationStyle   = UIModalPresentationStyle.Popover
        dsPopoverVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.Right
        dsPopoverVC.popoverPresentationController?.sourceView = btnSelectOrganisation
        dsPopoverVC.popoverPresentationController?.sourceRect = CGRectMake(0, 0, btnSelectOrganisation.frame.size.width, btnSelectOrganisation.frame.size.height)
        dsPopoverVC.preferredContentSize = CGSizeMake(250,CGFloat(44 * arrNames.count))
        
        presentViewController(dsPopoverVC, animated: true, completion: nil)
    }
    
    @IBAction func btnBackground_Action(sender: AnyObject) {
        view.endEditing(true)
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locations = manager.location {
            let coordinate = locations.coordinate
            latitude = coordinate.latitude
            longitude = coordinate.longitude
            
            self.lblLatitude.text        = "Latitude: \(latitude)"
            self.lblLongtude.text        = "Longitude: \(longitude)"
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        setupTitleBtnEnableGPS()
    }
    
    // MARK: - PopOverRoleVCDelegate Methods
    func didSelectDataInPopover(obj: String) {
        txfOrganisationType.text = obj
        
        if let arrTypes = arrOrganisationTypes {
            for type in arrTypes {
                if let name = type["name"] as? String {
                    if name == obj {
                        selectedOrganisationType = type
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
