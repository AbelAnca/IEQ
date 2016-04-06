//
//  Question.swift
//  IEQ
//
//  Created by Abel Anca on 12/10/15.
//  Copyright © 2015 IEQ. All rights reserved.
//

import Foundation
import RealmSwift

public class Question: Object {
    public dynamic var id = ""
    public dynamic var title = ""
    public dynamic var categoryId = ""
    public dynamic var body = ""
    public dynamic var sorted = 0
    public dynamic var acceptChoices = false
    public dynamic var acceptFile = false
    public dynamic var acceptText = false
    var choises = List<Choice>()
    
    public override static func primaryKey() -> String? {
        return "id"
    }
}

public class Choice: Object {
    dynamic var name = ""
}


extension Question {
    class func createNewQuestionWithID(strID: String) -> Question {
        let question                        = Question()
        question.id                         = strID
        
        return question
    }
    
    
    class func getQuestionWithID(strID: String, realm: Realm!) -> Question? {
        let predicate               = NSPredicate(format: "id = %@", strID)
        let arrQuestions                    = realm.objects(Question).filter(predicate)
        
        if arrQuestions.count > 0 {
            if let question = arrQuestions.first {
                return question
            }
        }
        
        return nil
    }
    
    class func getNewOrExistingQuestion(strID: String, realm: Realm!) -> Question {
        if let follower = getQuestionWithID(strID, realm: realm) {
            return follower
        }
        else {
            //     No question found, create new one
            let question                    = createNewQuestionWithID(strID)
            
            return question
        }
    }
    
    class func addEditQuestionWithDictionary(dictInfo: [String: AnyObject], realm: Realm!) -> Question {
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
                    for c in choices {
                        
                        let choice = Choice()
                        choice.name = c
                        question.choises.append(choice)

                    }
                }
                
                if let title = dictInfo["title"] as? String {
                    question.title              = title
                    
                    // Set Sort Key
                    let myRange = Range(title.startIndex.advancedBy(1) ..< title.startIndex.advancedBy(title.utf16.count))
                    
                    //let myRange = Range<String.Index>(start: title.startIndex.advancedBy(1), end: title.startIndex.advancedBy(title.utf16.count))
                    if let sort = Int(title.substringWithRange(myRange)) {
                        question.sorted         = sort
                    }
                }
                
                if let categoryId = dictInfo["categoryId"] as? String {
                    question.categoryId         = categoryId
                }
                
                realm.add(question, update: true)
            })
        }
        
        return question
    }
}