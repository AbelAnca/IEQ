//
//  APIManager.swift
//  IEQ
//
//  Created by Abel Anca on 12/8/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import Foundation

class APIError {
    var strMessage : String?
    var strErrorCode: String?
    
    func initWithDictionary(_ dictResult : NSDictionary) {
        if let strMessage = dictResult["messages"] as? [String] {
            self.strMessage = strMessage[0]
        }
        
        if let strErrorCode = dictResult["errorcode"] as? String {
            self.strErrorCode = strErrorCode
        }
    }
}

class APIManager {
    
    var error : APIError?
    var strMessage : String?
    var data : [String: AnyObject]?
    
    init() {
        
    }
    
    func handleResponse(_ response: HTTPURLResponse?, json: AnyObject?) {
        if let dictJSON = json as? [String:AnyObject] {
            if let dictResult = dictJSON["result"] as? [String:AnyObject] {
                if let bStatus = dictResult["rstatus"] as? Bool {
                    if bStatus == true {
                        self.data = dictJSON["data"] as? [String:AnyObject]
                    }
                    else {
                        let apiError = APIError()
                        apiError.initWithDictionary(dictResult as NSDictionary)
                        
                        self.error = apiError
                    }
                }
            }
        }
        else {
            let error = APIError()
            if let strStatusCode = response?.statusCode {
                error.strErrorCode = String(strStatusCode)
            }
            
            self.error = error
        }
    }
}
