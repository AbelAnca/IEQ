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
    class var sharedInstance: RLMManager {
        struct Static {
            static var instance: RLMManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = RLMManager()
        }
        
        return Static.instance!
    }
    
    /*
    **     Method to save user locally
    */
    func saveUser(dictData: [String: AnyObject]) -> User? {
        if let _ = dictData["id"] as? String {
            //=>     Save user locally
            let user = User.addEditUserWithDictionary(dictData, realm: appDelegate.realm)
            
            //=>     Set this user as current logged in user
            appDelegate.curUser     = user
            
            //=>     Save user's ID locally, to know which user is logged in
            appDelegate.defaults.setObject(user.id, forKey: k_UserDef_LoggedInUserID)
            appDelegate.defaults.synchronize()
            
            return user
            
        }
        
        return nil
    }
    
    /*
    **     Method to save question locally
    */
    func saveQuestion(dictData: [String: AnyObject]) -> Question? {
        if let _ = dictData["id"] as? String {
            
            //=>     Save question locally
            let question = Question.addEditQuestionWithDictionary(dictData, realm: appDelegate.realm)
            
            return question
        }
        
        return nil
    }

//    /*
//    **     Method to save song locally
//    */
//    func saveSong(dictData: [String: AnyObject]) -> Song? {
//        if let _ = dictData["mnetId"] as? Int {
//            //>     Save song locally
//            let song = Song.addEditSongWithDictionary(dictData, realm: appDelegate.realm)
//            return song
//        }
//        
//        return nil
//    }
//    
//    /*
//    **     Method to save moment locally
//    */
//    func saveMoment(dictData: [String: AnyObject]) -> Moment? {
//        if let _ = dictData["_id"] as? String {
//            //>     Save moment locally
//            let moment = Moment.addEditMomentWithDictionary(dictData, realm: appDelegate.realm)
//            return moment
//        }
//        
//        return nil
//    }
//    
//    /*
//    **     Method to delete moment locally
//    */
//    func deleteMoment(dictData: [String: AnyObject]){
//        if let _ = dictData["_id"] as? String {
//            //=>     Delete moment locally
//            Moment.deleteMomentWithDictionary(dictData, realm: appDelegate.realm)
//        }
//    }
//    
//    /*
//    **     Method to save follower locally
//    */
//    func saveFollower(dictData: [String: AnyObject]) -> Follower? {
//        if let _ = dictData["_id"] as? String {
//            //>     Save follower locally
//            let follower = Follower.addEditFollowerWithDictionary(dictData, realm: appDelegate.realm)
//            return follower
//        }
//        
//        return nil
//    }
//    
//    /*
//    **     Method to save following locally
//    */
//    func saveFollowing(dictData: [String: AnyObject]) -> Following? {
//        if let _ = dictData["_id"] as? String {
//            //>     Save following locally
//            let following = Following.addEditFollowingWithDictionary(dictData, realm: appDelegate.realm)
//            return following
//        }
//        
//        return nil
//    }
}