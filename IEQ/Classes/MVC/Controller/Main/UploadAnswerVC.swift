//
//  UploadAnswerVC.swift
//  IEQ
//
//  Created by Abel Anca on 1/3/17.
//  Copyright © 2017 IEQ. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import KVNProgress
import ReachabilitySwift

class UploadAnswerVC: UIViewController {
    @IBOutlet weak var lblError: UILabel!
    
    var arrAnswer: [Answer]?
    let reachability = Reachability()!
    
    var index               = 0

    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrAnswer = appDelegate.realm.objects(Answer.self).toArray(Answer.self)
        
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
    
    func setupUI() {
        if let arrAnswer = arrAnswer {
            if arrAnswer.count == 1 {
                lblError.text = "You have one answer that was not uploaded to the server"
            }
            else {
                lblError.text = "You have \(arrAnswer.count) answers that were not uploaded to the server"
            }
        }
    }

    func presentLoginScreen() {
        UserDefManager.logout()
    }

    func parametersFromAnswer(_ answer: Answer) -> Parameters {
        var parameters = Parameters()
        
        //|     Set username and userId
        parameters["username"]              = answer.username
        parameters["userId"]                = answer.userId
        
        //|     Set questionId and organizationId
        parameters["questionId"]            = answer.questionId
        parameters["organizationId"]        = answer.organizationId
        
        //|     Set answeredFor
        parameters["answeredFor"]           = ["categoryId": answer.categoryId, "question": answer.questionBody]
        
        //|     Set answeredBy
        parameters["answeredBy"]            = ["id": answer.userId, "username": answer.username]
        
        //|     Set Choice
        if answer.choises.count > 0 {
            var arrChoises = [String]()
            for choise in answer.choises {
                arrChoises.append(choise.string)
            }
            
            parameters["choices"]           = arrChoises
        }
        
        //|     Set Text
        if answer.text.length > 0 {
            parameters["text"]              = answer.text
        }
        
        //|     Set Image
        if answer.filename.length > 0 {
            parameters["fileToPost"]        = ["data": answer.data, "filename": answer.filename]
        }
        
        return parameters
    }
    
    func uploadArrAnswer() {
        if let arrAnswer = arrAnswer {
            if arrAnswer.count > 0 {
                
                //|     Show progress spinner
                KVNProgress.show()
                
                //|     Start uploading with first answer
                postAnswer(parametersFromAnswer(arrAnswer[index]))
            }
        }
    }
    
    func uploadNextAnswer() {
        index += 1
        
        if let arrAnswer = self.arrAnswer {
            if index < arrAnswer.count - 1 {
                
                //|     Upload next answer
                postAnswer(parametersFromAnswer(arrAnswer[index]))
            }
            else {
                //|     Remove all answers from database
                
                
                //|     All answers were uploaded -> hide spinner and show FinalVC
                if KVNProgress.isVisible() {
                    KVNProgress.dismiss()
                }
                
                let finalVC = storyboard?.instantiateViewController(withIdentifier: "FinalVC") as! FinalVC
                navigationController?.pushViewController(finalVC, animated: true)
            }
        }
    }
    
    // MARK: - API Methods
    
    func postAnswer(_ dictParams: Parameters) {
        appDelegate.manager.request("\(K_API_MAIN_URL)\(k_API_Answer)", method: .post, parameters: dictParams, encoding: JSONEncoding.default, headers: appDelegate.headers)
            .responseJSON(completionHandler: { (response) -> Void in
                print(response)
                
                let apiManager              = APIManager()
                apiManager.handleResponse(response.response, json: response.result.value as AnyObject?)

                if let error = apiManager.error {
                    if KVNProgress.isVisible() {
                        KVNProgress.dismiss()
                    }
                    
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
                        self.uploadNextAnswer()
                }
            })
    }
    
    // MARK: - Action Methods
    @IBAction func btnUpload(_ sender: Any) {
        uploadArrAnswer()
    }

    // MARK: - MemoryManagement Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
