//
//  Utils.swift
//  IEQ
//
//  Created by Abel Anca on 12/8/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import Foundation
import UIKit

class Utils: NSObject {
    
    // MARK: - Custom Methods
    class func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluateWithObject(testStr)
        return result
    }
    
    class func isValidPhoneNumber(value: String) -> Bool {
        if value.utf16.count < 10 && value.utf16.count > 0 {
            return false
        }
        
        let charcter  = NSCharacterSet(charactersInString: "+0123456789").invertedSet
        var filtered:NSString!
        let inputString:NSArray = value.componentsSeparatedByCharactersInSet(charcter)
        filtered = inputString.componentsJoinedByString("")
        return  value == filtered
    }
    
    class func isValidUsername(testStr:String) -> Bool {
        if testStr.utf16.count == 0 {
            return false
        }
        
        return true
    }
    
    class func isValidPassword(testStr:String) -> Bool {
        if testStr.utf16.count == 0 {
            return false
        }
        
        return true
    }
    
    class func isValidFirstName(testStr:String) -> Bool {
        if testStr.utf16.count == 0 {
            return false
        }
        
        return true
    }
    
    class func isValidLastName(testStr:String) -> Bool {
        if testStr.utf16.count == 0 {
            return false
        }
        
        return true
    }
    
    class func isValidRole(testStr:String) -> Bool {
        if testStr.utf16.count == 0 {
            return false
        }
        
        return true
    }
    
    class func isPasswordValid(strPasswordText : NSString) -> Bool {
        // too long or too short
        if strPasswordText.length < 1 || strPasswordText.length > 32 {
            return false
        }
        
        /*
        // no  Uppercase letter
        var range = strPasswordText.rangeOfCharacterFromSet(NSCharacterSet.uppercaseLetterCharacterSet())
        if range.length == 0 {
            return false
        }
        
        // no lowercase letter
        range = strPasswordText.rangeOfCharacterFromSet(NSCharacterSet.lowercaseLetterCharacterSet())
        if range.length == 0 {
            return false
        }
        
        // no letter
        range = strPasswordText.rangeOfCharacterFromSet(NSCharacterSet.letterCharacterSet())
        if range.length == 0 {
            return false
        }
        
        // no number;
        range = strPasswordText.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet())
        if range.length == 0 {
            return false
        }
        */
        
        return true
    }
    
    class func okAlert(title: String?, message: String?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle:.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        return alert
    }
    
    class func scaleImageDown(image: UIImage) -> UIImage {
        let fWidth      = image.size.width
        let fHeight     = image.size.height
        var bounds      = CGRectZero
        
        if fWidth <= k_ResizeTo30PercentResolution && fHeight <= k_ResizeTo30PercentResolution {
            return image
        }
        else {
            let ratio: CGFloat          = fWidth/fHeight
            
            if ratio > 1 {
                bounds.size.width       = k_ResizeTo30PercentResolution
                bounds.size.height      = k_ResizeTo30PercentResolution / ratio
            }
            else {
                bounds.size.height      = k_ResizeTo30PercentResolution
                bounds.size.width       = k_ResizeTo30PercentResolution * ratio
            }
        }
        
        let size = CGSizeMake(bounds.size.width, bounds.size.height)
        let hasAlpha = false
        let scale: CGFloat = 2.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return scaledImage
    }
    
}