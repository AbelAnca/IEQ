//
//  User.swift
//  IEQ
//
//  Created by Abel Anca on 12/9/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import Foundation
import RealmSwift

public class User: Object {
    public dynamic var u_id = ""
    public dynamic var u_token = ""
    public dynamic var u_username = ""
    
    public override static func primaryKey() -> String? {
            return "u_id"
    }
}