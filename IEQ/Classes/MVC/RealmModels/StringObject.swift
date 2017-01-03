//
//  StringObject.swift
//  IEQ
//
//  Created by Abel Anca on 1/3/17.
//  Copyright © 2017 IEQ. All rights reserved.
//

import RealmSwift

class StringObject: Object {
    dynamic var string      = ""
    
    override func isEqual(_ object: Any?) -> Bool {
        if let stringObject = object as? StringObject {
            if self.string == stringObject.string {
                return true
            }
        }
        
        return false
    }
}

