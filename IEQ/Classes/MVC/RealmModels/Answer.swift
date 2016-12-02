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
    open dynamic var id = ""
    open dynamic var loggedInUsername = ""
    open dynamic var loggedInUserId = ""
    open dynamic var questionId = ""
    open dynamic var organizationId = ""
    open dynamic var categoryId = ""
    open dynamic var questionBody = ""
    open dynamic var answerSelectedChoice = ""
    open dynamic var answerText = ""
    open dynamic var answerImgUrl = ""
    
    open override static func primaryKey() -> String? {
        return "id"
    }
}

extension Answer {
    class func createNewAnswerWithID(_ strID: String) -> Answer {
        let answer                        = Answer()
        answer.id                         = strID
        
        return answer
    }
    
    class func getAnswerWithID(_ strID: String, realm: Realm!) -> Answer? {
        let predicate               = NSPredicate(format: "id = %@", strID)
        let arrAnswer                    = realm.objects(Answer.self).filter(predicate)
        
        if arrAnswer.count > 0 {
            if let answer = arrAnswer.first {
                return answer
            }
        }
        
        return nil
    }
    
    class func getNewOrExistingAnswer(_ strID: String, realm: Realm!) -> Answer {
        if let follower = getAnswerWithID(strID, realm: realm) {
            return follower
        }
        else {
            //     No answer found, create new one
            let answer                    = createNewAnswerWithID(strID)
            
            return answer
        }
    }
    
    class func addEditAnswerWithDictionary(_ dictInfo: [String: AnyObject], realm: Realm!) -> Answer {
        var answer         = Answer()
        
        if let obj = dictInfo["id"] as? String {
            answer                            = self.getNewOrExistingAnswer(obj, realm: realm)
            
            
            try! realm.write({ () -> Void in
                if let id = dictInfo["id"] as? String {
                    answer.id      = id
                }
                
                if let loggedInUsername = dictInfo["loggedInUsername"] as? String {
                    answer.loggedInUsername         = loggedInUsername
                }
                
                if let loggedInUserId = dictInfo["loggedInUserId"] as? String {
                    answer.loggedInUserId         = loggedInUserId
                }
                
                if let questionId = dictInfo["questionId"] as? String {
                    answer.questionId               = questionId
                }
                
                if let organizationId = dictInfo["organizationId"] as? String {
                    answer.organizationId               = organizationId
                }
                
                if let categoryId = dictInfo["categoryId"] as? String {
                    answer.categoryId               = categoryId
                }
                
                if let answerSelectedChoice = dictInfo["answerSelectedChoice"] as? String {
                    answer.answerSelectedChoice               = answerSelectedChoice
                }
                
                if let answerText = dictInfo["answerText"] as? String {
                    answer.answerText               = answerText
                }
                
                if let answerImgUrl = dictInfo["answerImgUrl"] as? String {
                    answer.answerImgUrl               = answerImgUrl
                }
                
                realm.add(answer, update: true)
            })
        }
        
        return answer
    }
}
