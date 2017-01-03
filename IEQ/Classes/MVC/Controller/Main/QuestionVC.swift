//
//  QuestionVC.swift
//  IEQ
//
//  Created by Abel Anca on 12/8/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import KVNProgress

class QuestionVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var lblNoOfQuestion: UILabel!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var viewText: UIView!
    @IBOutlet weak var viewSegment: UIView!
    @IBOutlet weak var viewQuestion: UIView!
    @IBOutlet weak var viewImage: UIView!
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var txfAnswer: UITextField!
    
    @IBOutlet weak var btnNextQuestion: UIButton!
    @IBOutlet weak var btnImage: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnForward: UIButton!
    
    @IBOutlet weak var topSpaceViewText: NSLayoutConstraint!
    @IBOutlet weak var topSpaceViewSegment: NSLayoutConstraint!
    
    var index                           = 0
    var noOfAnswer                      = 0
    var arrQuestion: Results<(Question)>?
    
    var currentStrOfSegmControl         = ""
    var strOrganizationID               = ""
    
    var isChoice                        = false
    var isPicture                       = false
    var isText                          = false

    let imagePicker = UIImagePickerController()
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = appDelegate.defaults.object(forKey: k_UserDef_Index) as? Int {
            self.arrQuestion     = appDelegate.realm.objects(Question.self).sorted(byProperty: "sorted", ascending: true)
            loadCurrentQuestion()
        }
        else {
            loadQuestion_APICall()
        }
        
        if let tempOrganizationID = appDelegate.defaults.object(forKey: k_UserDef_OrganizationID) as? String {
            strOrganizationID = tempOrganizationID
        }
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Custom Methods
    
    func prepareForNewQuestion() {
        currentStrOfSegmControl      = ""
        txfAnswer.text               = ""
        imgView.image                = nil
        index += 1
    }
    
    func forwardAction() {
        prepareForNewQuestion()
        drawnQuestion()
    }
    
    func backAction() {
        prepareForNewQuestion()
        
        // Set index
        index -= 1
        index -= 1
        
        drawnQuestion()
    }
    
    func loadCurrentQuestion() {
        if let indexOfId = appDelegate.defaults.object(forKey: k_UserDef_Index) as? Int {
            index                = indexOfId
            
            if let noQuestion = appDelegate.defaults.object(forKey: k_UserDef_NoOfAnswer) as? Int {
                noOfAnswer = noQuestion
            }
        
            drawnQuestion()
        }
    }
    
    func saveIndexInUserDef() {
        appDelegate.defaults.set(index, forKey: k_UserDef_Index)
        appDelegate.defaults.synchronize()
    }
    
    func saveNoOfAnswerInUserDef() {
        appDelegate.defaults.set(noOfAnswer, forKey: k_UserDef_NoOfAnswer)
        appDelegate.defaults.synchronize()
    }

    func setupUI() {
        btnNextQuestion.backgroundColor             = UIColor.clear
        btnNextQuestion.layer.cornerRadius          = 8
        btnNextQuestion.layer.borderWidth           = 0.2
        btnNextQuestion.layer.borderColor           = UIColor.black.cgColor
        btnNextQuestion.clipsToBounds               = true
        
        imagePicker.delegate                        = self
        txfAnswer.text                              = ""
    }
    
    func setLblNoOfQuestion() {
        if let questions = arrQuestion {
            lblNoOfQuestion.text = "\(index + 1) of \(questions.count)"
            
            // Set Back and Forward button
            if index == 0 {
                btnBack.isHidden = true
            }
            else {
                btnBack.isHidden = false
            }
            
            if index == questions.count - 1 {
                btnForward.isHidden = true
            }
            else {
                btnForward.isHidden = false
            }
        }
    }
    
    func hideViewsAnswer() {
        viewSegment.isHidden    = true
        viewText.isHidden       = true
        viewImage.isHidden      = true
    }
    
    func presentAttentionAlert() {
        let alert = Utils.okAlert("Attention", message: "Please complete all the fields")
        present(alert, animated: false, completion: nil)
    }
    
    func drawnQuestion() {
        
        // Save index of arr in NSUserDef
        saveIndexInUserDef()
        
        // Save number of answer in NSUserDef
        saveNoOfAnswerInUserDef()

        // Set number of question
        setLblNoOfQuestion()
        
        if let questions = arrQuestion {
            if index < questions.count {
                let question = questions[index]
                
                // Set title and question
                lblQuestion.text                  = question.body
                //lblTitle.text                     = question.title
                
                // Prepare UI for question
                hideViewsAnswer()
                
                isChoice                      = false
                isPicture                     = false
                isText                        = false
                
                // Multiple choise
                
                if question.acceptChoices == true {
                    
                    topSpaceViewSegment.constant    = 20
                    viewSegment.isHidden            = false
                    isChoice                        = true
                    
                    var arrChoices                  = Array<String>()
                    
                    for choise in question.choises {
                        arrChoices.append(choise.name)
                    }
                    
                    segmentControl.replaceSegments(arrChoices)
                    segmentControl.addTarget(self, action: #selector(QuestionVC.segmentedControlValueChanged(_:)), for:.valueChanged)
                }
                else {
                    topSpaceViewSegment.constant    = -30
                }
                
                
                // Upload a picture
                if question.acceptFile == true {
                    viewImage.isHidden              = false
                    isPicture                       = true
                }
                
                // Write an answer
                if question.acceptText == true {
                    topSpaceViewText.constant       = 20
                    viewText.isHidden               = false
                    isText                          = true
                }
                else {
                    topSpaceViewText.constant       = -30
                }
            }
            else
                if index == questions.count {
                    if let noAnswer = appDelegate.defaults.object(forKey: k_UserDef_NoOfAnswer) as? Int {
                        if noAnswer >= questions.count {
                            let finalVC = storyboard?.instantiateViewController(withIdentifier: "FinalVC") as! FinalVC
                            navigationController?.pushViewController(finalVC, animated: true)
                        }
                        else {
                            let alert = Utils.okAlert("Attention", message: "You must complete all questions!")
                            present(alert, animated: true, completion: nil)
                            
                            // Set last question
                            index -= 1
                            drawnQuestion()
                        }
                    }
            }
        }
    }

    
    func setupImagePicker() {
        
        let alert = UIAlertController(title: "Upload a picture", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alert.addAction(UIAlertAction(title: "Take a Photo", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            if (UIImagePickerController.isSourceTypeAvailable(.camera))  {
                self.imagePicker.allowsEditing               = false
                self.imagePicker.sourceType                  = .camera
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else {
                let alert = Utils.okAlert("Attention", message: "The Camera is not available")
                self.present(alert, animated: true, completion: nil)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { (action) -> Void in
            if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
                self.imagePicker.allowsEditing               = false
                self.imagePicker.sourceType                  = .photoLibrary
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }))
        
        alert.popoverPresentationController?.sourceView = self.btnImage
        alert.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: self.btnImage.frame.size.width, height: self.btnImage.frame.size.height)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func goToNextQuestionWithoutAPICall() {
        self.prepareForNewQuestion()
        self.drawnQuestion()
    }
    
    func presentLoginScreen() {
        appDelegate.curUser = nil
        
        // Remove from NSUserDefaults
        appDelegate.defaults.removeObject(forKey: k_UserDef_LoggedInUserID)
        appDelegate.defaults.synchronize()
        
        // Present LoginVC
        let loginNC = storyboard?.instantiateViewController(withIdentifier: "LoginVC_NC") as! UINavigationController
        _ = navigationController?.popToRootViewController(animated: true)
        navigationController?.present(loginNC, animated: true, completion: { () -> Void in
            
        })
    }
    
    // MARK: - API Methods
    
    func loadQuestion_APICall() {
        KVNProgress.show(withStatus: "Please wait...")
        
        appDelegate.manager.request("\(K_API_MAIN_URL)\(k_API_Question)", method: .get, encoding: JSONEncoding.default, headers: appDelegate.headers)
            .responseJSON { (response) -> Void in
                let apiManager              = APIManager()
                apiManager.handleResponse(response.response, json: response.result.value as AnyObject?)
                
                if let error = apiManager.error {
                    KVNProgress.dismiss()
                    
                    if error.strErrorCode == "401" {
                        //=>    Session expired -> force user to login again
                        self.presentLoginScreen()
                    }
                    else {
                        if let message = error.strMessage {
                            let alert = Utils.okAlert("Error", message: message)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                else
                    if let data = apiManager.data {
                        if let items = data["items"] as? [[String: AnyObject]] {
                            // save questions in Realm
                            for item in items {
                                _ = RLMManager.sharedInstance.saveQuestion(item)
                            }
                            
                            self.arrQuestion     = appDelegate.realm.objects(Question.self).sorted(byProperty: "sorted", ascending: true)
                            
                            KVNProgress.dismiss()
                            self.drawnQuestion()
                        }
                    }
                    else {
                        KVNProgress.dismiss()
                    }
                
                KVNProgress.dismiss()
        }
    }
    
    func postQuestion_APICall() {
        if let user = appDelegate.curUser {
            
            // Create disctParams with question
            var dictParams              = Parameters()
            
            // Set current user for question
            dictParams["username"]      = user.username
            dictParams["userId"]        = user.id
            
            // Set ID for question
            if let questions = arrQuestion {
                if index < questions.count {
                    let question                    = questions[index]
                    dictParams["questionId"]        = question.id
                    
                    dictParams["organizationId"]    = strOrganizationID
                    dictParams["answeredFor"]       = ["categoryId": question.categoryId, "question": question.body]
                    dictParams["answeredBy"]        = ["id": user.id, "username": user.username]
                }
            }
            
            // Verify and set
            if isChoice == true {
                if currentStrOfSegmControl == "" {
                    presentAttentionAlert()
                    
                    return
                }
                
                dictParams["choices"] = [currentStrOfSegmControl]
            }
            
            if isText == true {
                /*
                if txfAnswer.text == "" {
                    presentAttentionAlert()
                    
                    return
                }
                */
                if let text = txfAnswer.text {
                    dictParams["text"] = text
                }
            }
            
            if isPicture == true {
                /*
                if imgView.image == nil {
                    presentAttentionAlert()
                    
                    return
                }
                */
                
                KVNProgress.show()
                
                if let image = imgView.image {
                    if let imageData = UIImagePNGRepresentation(image) {
                        let base64String = imageData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
                        dictParams["fileToPost"] = ["data": base64String, "filename": "image.png"]
                    }
                    
                }
            }
            
            // if do not exist check box(mandatory)
            if isChoice == false {
                
                // if exist textField without imageView
                if isText == true && isPicture == false {
                    // if textField is empty
                    if txfAnswer.text == "" {
                        goToNextQuestionWithoutAPICall()
                        
                        return
                    }
                }
                
                // if exist imageView without textField
                if isText == false && isPicture == true {
                    // if do not exist image in imageView
                    if let _ = imgView.image {
                        
                    }
                    else {
                        goToNextQuestionWithoutAPICall()
                        
                        return
                    }
                }
                
                // if exist textField and imageView
                if isText == true && isPicture == true {
                    // if textField is empty
                    if txfAnswer.text == "" {
                        // if do not exist image in imageView
                        if let _ = imgView.image {
                            
                        }
                        else {
                            goToNextQuestionWithoutAPICall()
                            
                            return
                        }
                    }
                }
            }

            print("DICT PARAMS = \(dictParams)")
            
            print(appDelegate.bIsInternetReachable)
            
            appDelegate.manager.request("\(K_API_MAIN_URL)\(k_API_Answer)", method: .post, parameters: dictParams, encoding: JSONEncoding.default, headers: appDelegate.headers)
                .responseJSON(completionHandler: { (response) -> Void in
                print(response)
                
                let apiManager              = APIManager()
                apiManager.handleResponse(response.response, json: response.result.value as AnyObject?)
                
                if KVNProgress.isVisible() {
                    KVNProgress.dismiss()
                }
                
                if let error = apiManager.error {
                    if error.strErrorCode == "401" {
                        //=>    Session expired -> force user to login again
                        self.presentLoginScreen()
                    }
                    else {
                        if let message = error.strMessage {
                            let alert = Utils.okAlert("Error", message: message)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                else
                    if let _ = apiManager.data {
                        self.noOfAnswer += 1
                        
                        // If is success go to the next question
                        self.prepareForNewQuestion()
                        self.drawnQuestion()
                }
            })
                
                
        }
    }
    
    // MARK: - Action Methods
    @IBAction func btnNextQuestionAction(_ sender: AnyObject) {
        postQuestion_APICall()
    }
    
    @IBAction func btnImage_Action(_ sender: AnyObject) {
        if txfAnswer.isFirstResponder {
            txfAnswer.resignFirstResponder()
        }
        
        setupImagePicker()
    }
    
    @IBAction func btnBack_Action(_ sender: AnyObject) {
        backAction()
    }
    
    @IBAction func btnForward_Action(_ sender: AnyObject) {
        forwardAction()
    }
    
    @IBAction func btnBackground_Action(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func btnLogot_Action(_ sender: AnyObject) {
        
        appDelegate.curUser = nil
        
        // Remove from NSUserDefaults
        appDelegate.defaults.removeObject(forKey: k_UserDef_LoggedInUserID)
        appDelegate.defaults.removeObject(forKey: k_UserDef_Index)
        appDelegate.defaults.removeObject(forKey: k_UserDef_NoOfAnswer)
        appDelegate.defaults.removeObject(forKey: k_UserDef_OrganizationID)
        appDelegate.defaults.synchronize()
        
        // Clean realm
        try! appDelegate.realm.write({ () -> Void in
            appDelegate.realm.deleteAll()
        })
        
        // Present LoginVC
        let loginNC = storyboard?.instantiateViewController(withIdentifier: "LoginVC_NC") as! UINavigationController
        _ = navigationController?.popToRootViewController(animated: true)
        navigationController?.present(loginNC, animated: true, completion: { () -> Void in
            
        })
    }
    
    // MARK: - SegmentControl Action Methods
    
    func segmentedControlValueChanged(_ segment: UISegmentedControl) {
        if txfAnswer.isFirstResponder {
            txfAnswer.resignFirstResponder()
        }
        
        if let strOfSegment = segment.titleForSegment(at: segment.selectedSegmentIndex) {
            currentStrOfSegmControl = strOfSegment
        }
    }
    
    // MARK: - UITextFieldDelegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == txfAnswer {
            txfAnswer.resignFirstResponder()
        }
        
        return false
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imgView.image = Utils.scaleImageDown(pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
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

extension UISegmentedControl {
    func replaceSegments(_ segments: Array<String>) {
        self.removeAllSegments()
        for segment in segments {
            self.insertSegment(withTitle: segment, at: self.numberOfSegments, animated: false)
        }
    }
}
