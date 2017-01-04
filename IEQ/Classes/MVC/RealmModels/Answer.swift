//
//  Answer.swift
//  IEQ
//
//  Created by Seby Paul on 12/2/16.
//  Copyright © 2016 IEQ. All rights reserved.
//

import Foundation
import RealmSwift

open class Answer: Object {
    open dynamic var id                     = ""
    open dynamic var username               = ""
    open dynamic var userId                 = ""
    open dynamic var questionId             = ""
    open dynamic var organizationId         = ""
    open dynamic var categoryId             = ""
    open dynamic var questionBody           = ""
    open dynamic var text                   = ""
    open dynamic var data                   = ""
    open dynamic var filename               = ""
    
    var choises                             = List<StringObject>()
    
    open override static func primaryKey() -> String? {
        return "id"
    }
}

extension Answer {
    class func createNewAnswerWithID() -> Answer {
        let answer                        = Answer()
        
        //|     Generate id for new answer
        answer.id                         = UUID().uuidString
        
        return answer
    }
    
    class func getAnswerWithQuestionID(_ strQuestionID: String, realm: Realm!) -> Answer? {
        let predicate                       = NSPredicate(format: "questionId = %@", strQuestionID)
        let arrAnswer                       = realm.objects(Answer.self).filter(predicate)
        
        if arrAnswer.count > 0 {
            if let answer = arrAnswer.first {
                return answer
            }
        }
        
        return nil
    }
    
    class func getNewOrExistingAnswer(_ strQuestionID: String, realm: Realm!) -> Answer {
        if let answer = getAnswerWithQuestionID(strQuestionID, realm: realm) {
            return answer
        }
        else {
            //     No answer found, create new one
            let answer                    = createNewAnswerWithID()
            
            return answer
        }
    }
    
    class func addEditAnswerWithDictionary(_ dictInfo: [String: AnyObject], realm: Realm!) {
        var answer                                      = Answer()
        
        if let questionId = dictInfo["questionId"] as? String {
            
            answer                                      = self.getNewOrExistingAnswer(questionId, realm: realm)
            
            try! realm.write({ () -> Void in
                if let username = dictInfo["username"] as? String {
                    answer.username                     = username
                }
                
                if let userId = dictInfo["userId"] as? String {
                    answer.userId                       = userId
                }
                
                answer.questionId                       = questionId
                
                if let organizationId = dictInfo["organizationId"] as? String {
                    answer.organizationId               = organizationId
                }
                
                if let dictAnswerBy = dictInfo["answeredFor"] as? [String: AnyObject] {
                    if let categoryId = dictAnswerBy["categoryId"] as? String {
                        answer.categoryId               = categoryId
                    }
                    
                    if let questionBody = dictAnswerBy["question"] as? String {
                        answer.questionBody             = questionBody
                    }
                }
                
                if let choices = dictInfo["choices"] as? [String] {
                    for choice in choices {
                        let newChoices                  = StringObject()
                        newChoices.string               = choice
                        
                        if !answer.choises.contains(newChoices) {
                            answer.choises.append(newChoices)
                        }
                    }
                }
                
                if let text = dictInfo["text"] as? String {
                    answer.text                         = text
                }
                
                if let dictAnswerBy = dictInfo["fileToPost"] as? [String: AnyObject] {
                    if let filename = dictAnswerBy["filename"] as? String {
                        answer.filename                 = filename
                    }
                    
                    if let data = dictAnswerBy["data"] as? String {
                        answer.data                     = data
                    }
                }
                
                realm.add(answer, update: true)
            })
        }
    }
}
