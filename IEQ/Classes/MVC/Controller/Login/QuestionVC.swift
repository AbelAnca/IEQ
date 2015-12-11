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
    
    @IBOutlet var segmentControl: UISegmentedControl!
    
    @IBOutlet var viewText: UIView!
    @IBOutlet var viewSegment: UIView!
    @IBOutlet var viewQuestion: UIView!
    @IBOutlet var viewImage: UIView!
    
    @IBOutlet var imgView: UIImageView!
    
    @IBOutlet var txfAnswer: UITextField!
    
    @IBOutlet var btnNextQuestion: UIButton!
    @IBOutlet var btnImage: UIButton!
    
    var index                           = 0
    //var arrIdOfQuestions                = [String]()
    var arrQuestion: Results<(Question)>?
    
    var currentStrOfSegmControl         = ""
    
    var isChoice                      = false
    var isPicture                     = false
    var isText                        = false

    let imagePicker = UIImagePickerController()
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if let _ = appDelegate.defaults.objectForKey(k_UserDef_Index) as? Int {
            self.arrQuestion     = appDelegate.realm.objects(Question).sorted("title", ascending: true)
            loadCurrentQuestion()
        }
        else {
            loadQuestion_APICall()
        }
        
        setupUI()
    }
    
    // MARK: - Custom Methods
    
    func prepareForNewQuestion() {
        currentStrOfSegmControl      = ""
        txfAnswer.text               = ""
        imgView.image                = nil
        index++
    }
    
    func loadCurrentQuestion() {
        if let indexOfId = appDelegate.defaults.objectForKey(k_UserDef_Index) as? Int {
            index                = indexOfId
            drawnQuestion()
        }
    }
    
    func saveIndexInUserDef() {
        appDelegate.defaults.setObject(index, forKey: k_UserDef_Index)
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
    
    func hideAllViews() {
        hideViewsAnswer()
        btnNextQuestion.hidden = true
        lblTitle.hidden = true
        lblQuestion.hidden = true
    }
    
    func hideViewsAnswer() {
        viewSegment.hidden = true
        viewText.hidden = true
        viewImage.hidden = true
    }
    
    func presentAttentionAlert() {
        let alert = Utils.okAlert("Attention", message: "Please complete all the fields")
        presentViewController(alert, animated: false, completion: nil)
    }
    
    func drawnQuestion() {
        
        // Save index of arr in NSUserDef
        saveIndexInUserDef()
        
        if let questions = arrQuestion {
        if index < questions.count {
             let question = questions[index]
                
                // Set title and question
                lblQuestion.text                  = question.body
                lblTitle.text                     = question.title
                
                // Prepare UI for question
                hideViewsAnswer()
                
                isChoice                      = false
                isPicture                     = false
                isText                        = false
                
                // Multiple choise

                    if question.acceptChoices == true {
                        
                        viewSegment.hidden            = false
                        isChoice                      = true
                        
                        var arrChoices                = Array<String>()
                        
                        for choise in question.choises {
                            arrChoices.append(choise.name)
                        }
                        
                        segmentControl.replaceSegments(arrChoices)
                        segmentControl.addTarget(self, action: "segmentedControlValueChanged:", forControlEvents:.ValueChanged)
                    }
                
                
                // Upload a picture
                if question.acceptFile == true {
                    viewImage.hidden              = false
                    isPicture                     = true
                }
                
                // Write an answer
                if question.acceptText == true {
                    viewText.hidden               = false
                    isText                        = true
                }
        }
        else
            if index == questions.count {
                let finalVC = storyboard?.instantiateViewControllerWithIdentifier("FinalVC") as! FinalVC
                navigationController?.pushViewController(finalVC, animated: true)
            }
        }
    }
    
    func nextQuestion() {
        
        if isChoice == true {
            if currentStrOfSegmControl == "" {
                presentAttentionAlert()
                
                return
            }
        }
        
        if isPicture == true {
            if imgView.image == nil {
                presentAttentionAlert()
                
                return
            }
        }
        
        if isText == true {
            if txfAnswer.text == "" {
                presentAttentionAlert()
                
                return
            }
        }
        
        print(txfAnswer.text)
        print(currentStrOfSegmControl)
        
        if imgView.image != nil {
            print("Yes")
        }
        
        prepareForNewQuestion()
        drawnQuestion()
        
        
    }
    
    func setupImagePicker() {
        if (UIImagePickerController.isSourceTypeAvailable(.Camera))  {
            imagePicker.allowsEditing               = false
            imagePicker.sourceType                  = .Camera
            
            presentViewController(imagePicker, animated: true, completion: nil)
        }
        else {
            imagePicker.allowsEditing               = false
            imagePicker.sourceType                  = .PhotoLibrary
            
            presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: - API Methods
    
    func loadQuestion_APICall() {
        
        if let user = appDelegate.curUser {
            
            KVNProgress.showWithStatus("Please wait...")
            
            var dictDefaultHeaders      = [String : String]()
            
            dictDefaultHeaders["X-IQE-Auth"] = "\(user.token)"
            dictDefaultHeaders["content-type"] = "application/json; charset=utf-8"
            
            
            Alamofire.request(.GET, "\(K_API_MAIN_URL)\(k_API_Question)", parameters: nil, encoding: .JSON, headers: dictDefaultHeaders)
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
                                
                                self.arrQuestion     = appDelegate.realm.objects(Question).sorted("title", ascending: true)
                                
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
    }
    
    // MARK: - Action Methods
    @IBAction func btnNextQuestionAction(sender: AnyObject) {
        nextQuestion()
    }
    
    @IBAction func btnImage_Action(sender: AnyObject) {
        setupImagePicker()
    }
    
    // MARK: - SegmentControl Action Methods
    
    func segmentedControlValueChanged(segment: UISegmentedControl) {
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
            imgView.image = pickedImage
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
