//
//  User.swift
//  IEQ
//
//  Created by Abel Anca on 12/9/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import Foundation
import RealmSwift

open class User: Object {
    open dynamic var id         = ""
    open dynamic var token      = ""
    open dynamic var username   = ""
    
    open override static func primaryKey() -> String? {
            return "id"
    }
}

extension User {
    class func createNewUserWithID(_ strID: String) -> User {
        let user                    = User()
        user.id                     = strID
        
        return user
    }
    
    
    class func getUserWithID(_ strID: String, realm: Realm!) -> User? {
        let predicate               = NSPredicate(format: "id = %@", strID)
        let arrUsers                = realm.objects(User.self).filter(predicate)
        
        if arrUsers.count > 0 {
            if let user = arrUsers.first {
                return user
            }
        }
        
        return nil
    }
    
    class func getNewOrExistingUser(_ strID: String, realm: Realm!) -> User {
        if let follower = getUserWithID(strID, realm: realm) {
            return follower
        }
        else {
            //>     No user found, create new one
            let user                 = createNewUserWithID(strID)
            
            return user
        }
    }
    
    class func addEditUserWithDictionary(_ dictInfo: [String: AnyObject], realm: Realm!) -> User {
        var user         = User()
        
        if let obj = dictInfo["id"] as? String {
            user                            = self.getNewOrExistingUser(obj, realm: realm)
            
            
            try! realm.write({ () -> Void in
                
                print(dictInfo)
                
                if let strUsername = dictInfo["username"] as? String {
                    user.username           = strUsername
                }
                
                if let strToken = dictInfo["authorization"] as? String {
                    user.token              = strToken
                }
                
                realm.add(user, update: true)
            })
        }
        
        return user
    }
}
