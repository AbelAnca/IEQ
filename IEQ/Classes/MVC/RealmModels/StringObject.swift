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

extension Array where Element: Equatable {
    mutating func removeObject(_ object: Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
    
    mutating func removeObjectsInArray(_ array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }
    
    func containsObject<T>(_ obj: T) -> Bool where T : Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
    
    mutating func removeObject<T>(obj: T) where T : Equatable {
        self = self.filter({$0 as? T != obj})
    }
}

extension Results {
    func toArray<T>(_ ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
        
        return array
    }
}

