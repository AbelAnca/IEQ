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

class EnableGPSVC: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var lblName: UITextField!
    @IBOutlet weak var lblLatitude: UITextField!
    @IBOutlet weak var lblLongtude: UITextField!
    @IBOutlet weak var txvDescription: UITextView!
    @IBOutlet weak var btnEnableGPS: UIButton!
    
    var longitude           = Double()
    var latitude            = Double()
    
    let locationManager = CLLocationManager()
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
    
    // MARK: - API Methods
    
    func getSchoolByLocation(longitude: String?, latitude: String?) {
        if let _ = appDelegate.curUser {
            
            // Create disctParams with question
            var dictParams = [String : AnyObject]()
            
            // Set current user for question
            //dictParams["username"] = user.username
            //dictParams["userId"] = user.id
            
            // FOR TEST !!!
            //longitude                       = 21.300543183135066
            //latitude                        = 46.18252519561494
            
            if let longitude = longitude,
                let latitude = latitude {
                dictParams["longitude"]         = longitude
                dictParams["latitude"]          = latitude
            }
            else {
                dictParams["longitude"]         = self.longitude
                dictParams["latitude"]          = self.latitude
            }
            
            KVNProgress.showWithStatus("Please wait...")
            
            appDelegate.manager.request(.POST, "\(K_API_MAIN_URL)\(k_API_School)", parameters: dictParams, encoding: .JSON)
                .responseJSON { (response) -> Void in
                    
                    let apiManager              = APIManager()
                    apiManager.handleResponse(response.response, json: response.result.value)
                    
                    if let error = apiManager.error {
                        if let message = error.strMessage {
                            KVNProgress.dismiss()
                            
                            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
                            
                            let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                            
                            let skipAction = UIAlertAction(title: "Skip", style: .Default, handler: { (action) in
                                let skipAlert = UIAlertController(title: "Attention!", message: "To find organisation please enter longitude and latitude:", preferredStyle: .Alert)
                                
                                skipAlert.addTextFieldWithConfigurationHandler({ (textField) in
                                    textField.placeholder = "Longitude"
                                })
                                
                                skipAlert.addTextFieldWithConfigurationHandler({ (textField) in
                                    textField.placeholder = "Latitude"
                                })
                                
                                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                                
                                let findAction = UIAlertAction(title: "Find", style: .Default, handler: { (action) in
                                    if let textFields = skipAlert.textFields {
                                        if let textFieldLongitude = textFields.first,
                                            let textFieldLatitude = textFields.last {
                                            
                                            if let longitude = textFieldLongitude.text,
                                                let latitude = textFieldLatitude.text {
                                                self.getSchoolByLocation(longitude, latitude: latitude)
                                            }
                                        }
                                    }
                                })
                                
                                skipAlert.addAction(cancelAction)
                                skipAlert.addAction(findAction)
                                
                                self.presentViewController(skipAlert, animated: true, completion: nil)
                            })
                            
                            alert.addAction(okAction)
                            alert.addAction(skipAction)
                            
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                    else
                        if let data = apiManager.data {
                            
                            if let schoolId = data["Id"] as? String {
                                appDelegate.defaults.setObject(schoolId, forKey: k_UserDef_SchoolID)
                                appDelegate.defaults.synchronize()
                                
                                self.btnEnableGPS.setTitle("START QUESTIONS", forState: .Normal)
                            }
                            
                            if let name = data["Name"] as? String {
                                self.lblName.text               = name
                            }
                            
                            if let location = data["Location"] as? [String : NSNumber] {
                                if let latitude = location["Latitude"] {
                                    self.lblLatitude.text        = "Latitude: \(latitude)"
                                }
                                
                                if let longitude = location["Longitude"] {
                                    self.lblLongtude.text        = "Longitude: \(longitude)"
                                }
                            }
                            
                            if let description = data["Description"] as? String {
                                self.txvDescription.text        = description
                            }
                            
                            KVNProgress.dismiss()
                        }
                        else {
                            KVNProgress.dismiss()
                    }
                    
                    KVNProgress.dismiss()
            }
        }
    }
    
    // MARK: - Action Methods
    
    @IBAction func enableGPS_Action() {
        if btnEnableGPS.currentTitle == "START QUESTIONS" {
            let questionVC = self.storyboard?.instantiateViewControllerWithIdentifier("QuestionVC") as! QuestionVC
            self.navigationController?.pushViewController(questionVC, animated: true)
        }
        else {
            switch CLLocationManager.authorizationStatus() {
            case .NotDetermined:
                findMyLocation()
                
            case .AuthorizedWhenInUse:
                getSchoolByLocation(nil, latitude: nil)
                
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
        appDelegate.defaults.removeObjectForKey(k_UserDef_SchoolID)
        appDelegate.defaults.synchronize()
        
        // Present LoginVC
        let loginNC = storyboard?.instantiateViewControllerWithIdentifier("LoginVC_NC") as! UINavigationController
        navigationController?.popToRootViewControllerAnimated(true)
        navigationController?.presentViewController(loginNC, animated: true, completion: { () -> Void in
            
        })
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locations = manager.location {
            let coordinate = locations.coordinate
            latitude = coordinate.latitude
            longitude = coordinate.longitude
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        setupTitleBtnEnableGPS()
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
