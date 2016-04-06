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
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblQuestion: UILabel!
    @IBOutlet var lblNoOfQuestion: UILabel!
    
    @IBOutlet var segmentControl: UISegmentedControl!
    
    @IBOutlet var viewText: UIView!
    @IBOutlet var viewSegment: UIView!
    @IBOutlet var viewQuestion: UIView!
    @IBOutlet var viewImage: UIView!
    
    @IBOutlet var imgView: UIImageView!
    
    @IBOutlet var txfAnswer: UITextField!
    
    @IBOutlet var btnNextQuestion: UIButton!
    @IBOutlet var btnImage: UIButton!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var btnForward: UIButton!
    
    @IBOutlet var topSpaceViewText: NSLayoutConstraint!
    @IBOutlet var topSpaceViewSegment: NSLayoutConstraint!
    
    var index                           = 0
    var noOfAnswer                      = 0
    var arrQuestion: Results<(Question)>?
    
    var currentStrOfSegmControl         = ""
    var schoolID                        = ""
    
    var isChoice                        = false
    var isPicture                       = false
    var isText                          = false

    let imagePicker = UIImagePickerController()
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = appDelegate.defaults.objectForKey(k_UserDef_Index) as? Int {
            self.arrQuestion     = appDelegate.realm.objects(Question).sorted("sorted", ascending: true)
            loadCurrentQuestion()
        }
        else {
            loadQuestion_APICall()
        }
        
        if let schoolId = appDelegate.defaults.objectForKey(k_UserDef_SchoolID) as? String {
            schoolID = schoolId
        }
        
        setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
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
        if let indexOfId = appDelegate.defaults.objectForKey(k_UserDef_Index) as? Int {
            index                = indexOfId
            
            if let noQuestion = appDelegate.defaults.objectForKey(k_UserDef_NoOfAnswer) as? Int {
                noOfAnswer = noQuestion
            }
        
            drawnQuestion()
        }
    }
    
    func saveIndexInUserDef() {
        appDelegate.defaults.setObject(index, forKey: k_UserDef_Index)
        appDelegate.defaults.synchronize()
    }
    
    func saveNoOfAnswerInUserDef() {
        appDelegate.defaults.setObject(noOfAnswer, forKey: k_UserDef_NoOfAnswer)
        appDelegate.defaults.synchronize()
    }

    func setupUI() {
        btnNextQuestion.backgroundColor             = UIColor.clearColor()
        btnNextQuestion.layer.cornerRadius          = 8
        btnNextQuestion.layer.borderWidth           = 0.2
        btnNextQuestion.layer.borderColor           = UIColor.blackColor().CGColor
        btnNextQuestion.clipsToBounds               = true
        
        imagePicker.delegate                        = self
        txfAnswer.text                              = ""
    }
    
    func setLblNoOfQuestion() {
        if let questions = arrQuestion {
            lblNoOfQuestion.text = "\(index + 1) of \(questions.count)"
            
            // Set Back and Forward button
            if index == 0 {
                btnBack.hidden = true
            }
            else {
                btnBack.hidden = false
            }
            
            if index == questions.count - 1 {
                btnForward.hidden = true
            }
            else {
                btnForward.hidden = false
            }
        }
    }
    
    func hideViewsAnswer() {
        viewSegment.hidden    = true
        viewText.hidden       = true
        viewImage.hidden      = true
    }
    
    func presentAttentionAlert() {
        let alert = Utils.okAlert("Attention", message: "Please complete all the fields")
        presentViewController(alert, animated: false, completion: nil)
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
                    
                    topSpaceViewSegment.constant  = 20
                    viewSegment.hidden            = false
                    isChoice                      = true
                    
                    var arrChoices                = Array<String>()
                    
                    for choise in question.choises {
                        arrChoices.append(choise.name)
                    }
                    
                    segmentControl.replaceSegments(arrChoices)
                    segmentControl.addTarget(self, action: #selector(QuestionVC.segmentedControlValueChanged(_:)), forControlEvents:.ValueChanged)
                }
                else {
                    topSpaceViewSegment.constant   = -30
                }
                
                
                // Upload a picture
                if question.acceptFile == true {
                    viewImage.hidden              = false
                    isPicture                     = true
                }
                
                // Write an answer
                if question.acceptText == true {
                    topSpaceViewText.constant     = 20
                    viewText.hidden               = false
                    isText                        = true
                }
                else {
                    topSpaceViewText.constant     = -30
                }
            }
            else
                if index == questions.count {
                    if let noAnswer = appDelegate.defaults.objectForKey(k_UserDef_NoOfAnswer) as? Int {
                        if noAnswer >= questions.count {
                            let finalVC = storyboard?.instantiateViewControllerWithIdentifier("FinalVC") as! FinalVC
                            navigationController?.pushViewController(finalVC, animated: true)
                        }
                        else {
                            let alert = Utils.okAlert("Attention", message: "You must complete all questions!")
                            presentViewController(alert, animated: true, completion: nil)
                            
                            // Set last question
                            index -= 1
                            drawnQuestion()
                        }
                    }
            }
        }
    }

    
    func setupImagePicker() {
        
        let alert = UIAlertController(title: "Upload a picture", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alert.addAction(UIAlertAction(title: "Take a Photo", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            if (UIImagePickerController.isSourceTypeAvailable(.Camera))  {
                self.imagePicker.allowsEditing               = false
                self.imagePicker.sourceType                  = .Camera
                
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
            else {
                let alert = Utils.okAlert("Attention", message: "The Camera is not available")
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .Default, handler: { (action) -> Void in
            if (UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)) {
                self.imagePicker.allowsEditing               = false
                self.imagePicker.sourceType                  = .PhotoLibrary
                
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
        }))
        
        alert.popoverPresentationController?.sourceView = self.btnImage
        alert.popoverPresentationController?.sourceRect = CGRectMake(0, 0, self.btnImage.frame.size.width, self.btnImage.frame.size.height)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func goToNextQuestionWithoutAPICall() {
        self.prepareForNewQuestion()
        self.drawnQuestion()
    }
    
    // MARK: - API Methods
    
    func loadQuestion_APICall() {
        KVNProgress.showWithStatus("Please wait...")
        
        appDelegate.manager.request(.GET, "\(K_API_MAIN_URL)\(k_API_Question)", parameters: nil, encoding: .JSON)
            .responseJSON { (response) -> Void in
                let apiManager              = APIManager()
                apiManager.handleResponse(response.response, json: response.result.value)
                
                if let error = apiManager.error {
                    if let message = error.strMessage {
                        KVNProgress.dismiss()
                        
                        let alert = Utils.okAlert("Error", message: message)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
                else
                    if let data = apiManager.data {
                        if let items = data["items"] as? [[String: AnyObject]] {
                            // save questions in Realm
                            for item in items {
                                RLMManager.sharedInstance.saveQuestion(item)
                            }
                            
                            self.arrQuestion     = appDelegate.realm.objects(Question).sorted("sorted", ascending: true)
                            
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
            var dictParams = [String : AnyObject]()
            
            // Set current user for question
            dictParams["username"] = user.username
            dictParams["userId"] = user.id
            
            // Set ID for question
            if let questions = arrQuestion {
                if index < questions.count {
                    let question = questions[index]
                    dictParams["questionId"] = question.id
                    
                    dictParams["schoolId"] = schoolID
                    dictParams["answeredFor"] = ["categoryId": question.categoryId, "question": question.id]
                    dictParams["answeredBy"] = ["id": user.id, "username": user.username]
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
                        let base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
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

            //print("DICT PARAMS = \(dictParams)")
            
            appDelegate.manager.request(.POST, "\(K_API_MAIN_URL)\(k_API_Answer)", parameters: dictParams, encoding: .JSON)
            .responseJSON(completionHandler: { (response) -> Void in
                print(response)
                
                let apiManager              = APIManager()
                apiManager.handleResponse(response.response, json: response.result.value)
                
                if KVNProgress.isVisible() {
                    KVNProgress.dismiss()
                }
                
                if let error = apiManager.error {
                    if let message = error.strMessage {
                        let alert = Utils.okAlert("Error", message: message)
                        self.presentViewController(alert, animated: true, completion: nil)
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
    @IBAction func btnNextQuestionAction(sender: AnyObject) {
        postQuestion_APICall()
    }
    
    @IBAction func btnImage_Action(sender: AnyObject) {
        if txfAnswer.isFirstResponder() {
            txfAnswer.resignFirstResponder()
        }
        
        setupImagePicker()
    }
    
    @IBAction func btnBack_Action(sender: AnyObject) {
        backAction()
    }
    
    @IBAction func btnForward_Action(sender: AnyObject) {
        forwardAction()
    }
    
    
    // MARK: - SegmentControl Action Methods
    
    func segmentedControlValueChanged(segment: UISegmentedControl) {
        if txfAnswer.isFirstResponder() {
            txfAnswer.resignFirstResponder()
        }
        
        if let strOfSegment = segment.titleForSegmentAtIndex(segment.selectedSegmentIndex) {
            currentStrOfSegmControl = strOfSegment
        }
    }
    
    // MARK: - UITextFieldDelegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == txfAnswer {
            txfAnswer.resignFirstResponder()
        }
        
        return false
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imgView.image = Utils.scaleImageDown(pickedImage)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
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
    func replaceSegments(segments: Array<String>) {
        self.removeAllSegments()
        for segment in segments {
            self.insertSegmentWithTitle(segment, atIndex: self.numberOfSegments, animated: false)
        }
    }
}
