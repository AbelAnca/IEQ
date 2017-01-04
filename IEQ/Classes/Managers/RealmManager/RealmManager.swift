//
//  RealmManager.swift
//  IEQ
//
//  Created by Andy Boariu on 09/12/15.
//  Copyright (c) 2015 IEQ. All rights reserved.
//

import Foundation
import RealmSwift

class RLMManager {
    /*
    private static var __once: () = {
            Static.instance = RLMManager()
        }()
    
    class var sharedInstance: RLMManager {
        struct Static {
            static var instance: RLMManager?
            static var token: Int = 0
        }
        
        _ = RLMManager.__once
        
        return Static.instance!
    }
    */
    private init() {}
    
    static let sharedInstance = RLMManager()
    
    /*
    **     Method to save user locally
    */
    func saveUser(_ dictData: [String: AnyObject]) -> User? {
        if let _ = dictData["id"] as? String {
            //=>     Save user locally
            let user = User.addEditUserWithDictionary(dictData, realm: appDelegate.realm)
            
            //=>     Set this user as current logged in user
            appDelegate.curUser     = user
            
            //=>     Save user's ID locally, to know which user is logged in
            appDelegate.defaults.set(user.id, forKey: k_UserDef_LoggedInUserID)
            appDelegate.defaults.synchronize()
            
            return user
            
        }
        
        return nil
    }
    
    /*
    **     Method to save question locally
    */
    func saveQuestion(_ dictData: [String: AnyObject]) -> Question? {
        if let _ = dictData["id"] as? String {
            
            //=>     Save question locally
            let question = Question.addEditQuestionWithDictionary(dictData, realm: appDelegate.realm)
            
            return question
        }
        
        return nil
    }
    
    /*
     **     Method to save answer locally
     */
    func saveAnswer(_ dictData: [String: AnyObject]) {
            
        //|     Save answer locally
        Answer.addEditAnswerWithDictionary(dictData, realm: appDelegate.realm)
    }
}
