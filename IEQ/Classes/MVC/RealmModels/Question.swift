//
//  Question.swift
//  IEQ
//
//  Created by Abel Anca on 12/10/15.
//  Copyright © 2015 IEQ. All rights reserved.
//

import Foundation
import RealmSwift

open class Question: Object {
    open dynamic var id                 = ""
    open dynamic var title              = ""
    open dynamic var categoryId         = ""
    open dynamic var body               = ""
    open dynamic var sorted             = 0
    open dynamic var acceptChoices      = false
    open dynamic var acceptFile         = false
    open dynamic var acceptText         = false
    open dynamic var bAnswered          = false
    var choises                         = List<StringObject>()
    
    open override static func primaryKey() -> String? {
        return "id"
    }
}

extension Question {
    class func createNewQuestionWithID(_ strID: String) -> Question {
        let question                        = Question()
        question.id                         = strID
        
        return question
    }
    
    class func getQuestionWithID(_ strID: String, realm: Realm!) -> Question? {
        let predicate                       = NSPredicate(format: "id = %@", strID)
        let arrQuestions                    = realm.objects(Question.self).filter(predicate)
        
        if arrQuestions.count > 0 {
            if let question = arrQuestions.first {
                return question
            }
        }
        
        return nil
    }
    
    class func getNewOrExistingQuestion(_ strID: String, realm: Realm!) -> Question {
        if let follower = getQuestionWithID(strID, realm: realm) {
            return follower
        }
        else {
            //     No question found, create new one
            let question                    = createNewQuestionWithID(strID)
            
            return question
        }
    }
    
    class func addEditQuestionWithDictionary(_ dictInfo: [String: AnyObject], realm: Realm!) -> Question {
        var question         = Question()
        
        if let obj = dictInfo["id"] as? String {
            question                            = self.getNewOrExistingQuestion(obj, realm: realm)
            
            
            try! realm.write({ () -> Void in                
                if let acceptChoices = dictInfo["acceptChoices"] as? Bool {
                    question.acceptChoices      = acceptChoices
                }
                
                if let acceptFile = dictInfo["acceptFile"] as? Bool {
                    question.acceptFile         = acceptFile
                }
                
                if let acceptText = dictInfo["acceptText"] as? Bool {
                    question.acceptText         = acceptText
                }
                
                if let body = dictInfo["body"] as? String {
                    question.body               = body
                }
                
                if let choices = dictInfo["choices"] as? [String] {
                    for choice in choices {
                        let obj = StringObject()
                        obj.string = choice
                        
                        if !question.choises.contains(obj) {
                            question.choises.append(obj)
                        }
                    }
                }
                
                if let title = dictInfo["title"] as? String {
                    question.title              = title
                    
                    /*
                    let myRange = title.index(title.startIndex, offsetBy: 1) ..< title.index(title.startIndex, offsetBy: title.utf16.count)
                    
                    if let sort = Int(title.substring(with: myRange)) {
                        question.sorted = sort
                    }
                    */
                }
                
                if let categoryId = dictInfo["categoryId"] as? String {
                    question.categoryId         = categoryId
                }
                
                realm.add(question, update: true)
            })
        }
        
        return question
    }
    
    class func answeredToQuestion(_ id: String) -> Void {
        let realm = appDelegate.realm
        
        do {
            try realm?.write {
                if let question = getQuestionWithID(id, realm: realm) {
                   question.bAnswered = true
                    
                    realm?.add(question, update: true)
                }
            }
        }
        catch {
            debugPrint("unable to delete question")
        }
    }
}
