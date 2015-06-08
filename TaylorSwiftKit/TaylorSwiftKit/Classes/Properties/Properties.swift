//
//  Properties.swift
//  InvescoTraining
//
//  Created by David Casserly on 25/11/2014.
//  Copyright (c) 2014 DevedUp Ltd. All rights reserved.
//

import Foundation
import UIKit

enum Property: String {
    
    case FlurryKey       = "FlurryKey"
    case FlurryKeyDev       = "FlurryKeyDev"
    
    var value: String? {
        return Properties.sharedInstance!.propertyForKey(self)
    }
}

class Properties {

    static let sharedInstance = Properties()
    
    var properties: NSDictionary?
    
    
    // Default to mainBundle() or you can pass in a different one
    private init?() {
        let bundle: NSBundle = NSBundle.mainBundle()
        let path = bundle.pathForResource("properties", ofType: "plist")
        if let path = path {
            if(NSFileManager.defaultManager().fileExistsAtPath(path)) {
                properties = NSDictionary(contentsOfFile: path)
            }
        }
    }
    
    func propertyForKey(key: Property) -> String? {
        if let properties = properties {            
            return properties[key.rawValue] as? String
        } else {
            return nil
        }
    }
    
}