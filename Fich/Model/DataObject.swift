//
//  DataObject.swift
//  Fich
//
//  Created by Tran Tien Tin on 7/15/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit

class DataObject: NSObject {
    var createdAt: Date?
    var modifiedAt: Date?
    
    override init() {
        createdAt = Date()
        modifiedAt = Date()
    }
    
    init(dictionary: NSDictionary) {
        let createdAtData = dictionary["created_at"] as? Double
        if let createdAtData = createdAtData {
            createdAt = Date(timeIntervalSince1970: createdAtData/1000)
        }
        
        let modifiedAtData = dictionary["modified_at"] as? Double
        if let modifiedAtData = modifiedAtData {
            modifiedAt = Date(timeIntervalSince1970: modifiedAtData/1000)
        }
    }
}
