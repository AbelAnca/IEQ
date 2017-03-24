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
import ReachabilitySwift

class QuestionVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    var noOfAnsweredQuestions           = 0
    var arrQuestion: [Question]?
    
    var currentStrOfSegmControl         = ""
    var strOrganizationID               = ""
    
    var isChoice                        = false
    var isPicture                       = false
    var isText                          = false

    let imagePicker = UIImagePickerController()
    let reachability = Reachability()!
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = appDelegate.defaults.object(forKey: k_UserDef_NoOfAnswer) as? Int {
            let predicate                       = NSPredicate(format: "bAnswered = false")
            self.arrQuestion     = (appDelegate.realm.objects(Question.self).filter(predicate)).toArray(Question.self)
            
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

        //|     Setup reachability
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    // MARK: - Notification Methods
    
    func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            appDelegate.bIsInternetReachable = true
        } else {
            appDelegate.bIsInternetReachable = false
        }
    }
    
    // MARK: - Custom Methods
    
    func prepareForNewQuestion() {
        currentStrOfSegmControl      = ""
        txfAnswer.text               = ""
        imgView.image                = nil
    }
    
    func forwardAction() {
        index += 1
        
        prepareForNewQuestion()
        drawnQuestion()
    }
    
    func backAction() {
        index -= 1
        
        prepareForNewQuestion()
        drawnQuestion()
    }
    
    func loadCurrentQuestion() {
        if let noQuestion = appDelegate.defaults.object(forKey: k_UserDef_NoOfAnswer) as? Int {
            noOfAnsweredQuestions = noQuestion
            
            drawnQuestion()
        }
    }
    
    func saveNoOfAnsweredQuestionsInUserDef() {
        appDelegate.defaults.set(noOfAnsweredQuestions, forKey: k_UserDef_NoOfAnswer)
        appDelegate.defaults.synchronize()
    }

    func setupUI() {
        btnNextQuestion.backgroundColor             = UIColor(cgColor: k_UIColor_Blue.cgColor)
        btnNextQuestion.layer.cornerRadius          = 8
        btnNextQuestion.layer.borderWidth           = 0
        btnNextQuestion.layer.borderColor           = UIColor.black.cgColor
        btnNextQuestion.clipsToBounds               = true
        
        imagePicker.delegate                        = self
        txfAnswer.text                              = ""
    }
    
    func setLblNoOfQuestion() {
        if let arrQuestion = arrQuestion {
            let questions = appDelegate.realm.objects(Question.self)
            
            /*
            //|     Old version
            lblNoOfQuestion.text = "\(noOfAnsweredQuestions) of \(questions.count)"
            */
            
            if noOfAnsweredQuestions != 1 {
                lblNoOfQuestion.text = "\(noOfAnsweredQuestions) uploaded questions of \(questions.count)"
            }
            else {
                lblNoOfQuestion.text = "\(noOfAnsweredQuestions) uploaded question of \(questions.count)"
            }
 
            // Set Back and Forward button
            if index == 0 {
                btnBack.isHidden = true
            }
            else {
                btnBack.isHidden = false
            }
            
            if index == arrQuestion.count - 1 {
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
        let alert = Utils.okAlert("Attention", message: "Make sure you added full answer (selection, text or picture) !")
        present(alert, animated: false, completion: nil)
    }
    
    func drawnQuestion() {
        
        // Set number of question
        setLblNoOfQuestion()
        
        if let questions = arrQuestion {
            if index < questions.count {
                let question = questions[index]
                
                // Set title and question
                lblQuestion.text                  = question.body
                
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
                        arrChoices.append(choise.string)
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
                            
                            //|     Check if exist answers in database
                            let answers = appDelegate.realm.objects(Answer.self)
                                
                            if answers.count > 0 {
                                //|     Show UploadAnswerVC because NOT every answer was upload
                                let uploadAnswerVC          = storyboard?.instantiateViewController(withIdentifier: "UploadAnswerVC") as! UploadAnswerVC
                                navigationController?.pushViewController(uploadAnswerVC, animated: true)
                            }
                            else {
                                //|     Show FinalVC because every answer was upload
                                let finalVC = storyboard?.instantiateViewController(withIdentifier: "FinalVC") as! FinalVC
                                navigationController?.pushViewController(finalVC, animated: true)
                            }
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
                self.imagePicker.allowsEditing               = true
                self.imagePicker.sourceType                  = .camera
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else {
                let alert = Utils.okAlert("Oops", message: "The Camera is not available")
                self.present(alert, animated: true, completion: nil)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { (action) -> Void in
            if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
                self.imagePicker.allowsEditing               = true
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
        UserDefManager.logout()
    }
    
    func setupNewQuestion() {
        noOfAnsweredQuestions += 1
        
        // Save number of answer in NSUserDef
        saveNoOfAnsweredQuestionsInUserDef()
        
        //|     Setup question
        if let arrQuestion = arrQuestion {
            Question.answeredToQuestion(arrQuestion[index].id)
        }
        
        //|     Remove this question from arrQuestion
        arrQuestion?.remove(at: index)
        
        //|     Go to the next question
        self.prepareForNewQuestion()
        self.drawnQuestion()
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
                        if let questions = data["items"] as? [[String: AnyObject]] {
                            // save questions in Realm
                            for q in questions {
                                _ = RLMManager.sharedInstance.saveQuestion(q)
                            }
                            
                            self.arrQuestion     = (appDelegate.realm.objects(Question.self)).toArray(Question.self)
                            
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
                /*
                if currentStrOfSegmControl == "" {
                    presentAttentionAlert()
                    return
                }
                */
                
                dictParams["choices"] = [currentStrOfSegmControl]
            }
            
            if isText == true {
                if txfAnswer.text == "" {
                    presentAttentionAlert()
                    return
                }
                
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
                
                if appDelegate.bIsInternetReachable {
                    KVNProgress.show()
                }
                
                if let image = imgView.image {
                    if let imageData = UIImagePNGRepresentation(image) {
                        let base64String = imageData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
                        dictParams["fileToPost"] = ["data": base64String, "filename": "image.png"]
                    }
                }
            }
            
            //      if do not exist check box(mandatory)
            if isChoice == false {
                
                //      if exist textField without imageView
                if isText == true && isPicture == false {
                    // if textField is empty
                    if txfAnswer.text == "" {
                        goToNextQuestionWithoutAPICall()
                        
                        return
                    }
                }
                
                //      if exist imageView without textField
                if isText == false && isPicture == true {
                    // if do not exist image in imageView
                    if let _ = imgView.image {
                        
                    }
                    else {
                        goToNextQuestionWithoutAPICall()
                        
                        return
                    }
                }
                
                //      if exist textField and imageView
                if isText == true && isPicture == true {
                    // if textField is empty
                    if txfAnswer.text == "" {
                        // if do not exist image in imageView
                        if let _ = imgView.image {
                            
                        }
                        else {
                            KVNProgress.dismiss()
                            
                            goToNextQuestionWithoutAPICall()
                            
                            return
                        }
                    }
                }
            }

            print("DICT PARAMS = \(dictParams)")
            
            if !appDelegate.bIsInternetReachable {
                
                //|     Save answer
                _ = RLMManager.sharedInstance.saveAnswer(dictParams as [String : AnyObject])
                
                //|     Setup New Question
                setupNewQuestion()
            }
            else {
                appDelegate.manager
                    .request("\(K_API_MAIN_URL)\(k_API_Answer)",
                        method: .post, parameters: dictParams,
                        encoding: JSONEncoding.default,
                        headers: appDelegate.headers)
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
                            else
                                if error.strErrorCode == "410" {
                                    //=>    Question no longer exists - its a BAD CASE if we get this code here
                                    
                                    let alert = Utils.okAlert("Error", message: "Unfortunately question no longer exists. Next question displayed")
                                    self.present(alert, animated: true, completion: nil)
                                    
                                    self.setupNewQuestion()
                                }
                                else {
                                    if let message = error.strMessage {
                                        let alert = Utils.okAlert("Error", message: message)
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                    else {
                                        let alert = Utils.okAlert("Error", message: "Something strange happened. Please try again!")
                                        self.present(alert, animated: true, completion: nil)
                                    }
                            }
                        }
                        else
                            if let _ = apiManager.data {
                                self.setupNewQuestion()
                            }
                    })
            }
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
        UserDefManager.logout()
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
    }
}

extension UISegmentedControl {
    func replaceSegments(_ segments: Array<String>) {
        self.removeAllSegments()
        for segment in segments {
            self.insertSegment(withTitle: segment, at: self.numberOfSegments, animated: false)
        }
    }
}
