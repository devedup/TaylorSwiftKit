//
//  JSON.swift
//  InvescoTraining
//
//  Created by David Casserly on 19/11/2014.
//  Copyright (c) 2014 DevedUp Ltd. All rights reserved.
//

import Foundation

/// JSON Types
typealias JSON = AnyObject
typealias JSONDictionary = Dictionary<String, AnyObject>
typealias JSONArray = Array<AnyObject>

/*
    Methods to return an object as a particular type
*/

func _JSONString(object: JSON) -> String? {
    return object as? String
}

func _JSONInt(object: JSON) -> Int? {
    return object as? Int
}

func _JSONDictionary(object: JSON) -> JSONDictionary? {
    return object as? JSONDictionary
}

func _JSONArray(object: JSON) -> JSONArray? {
    return object as? JSONArray
}

/**
    Decode some NSData into JSON - which will be an NSDictionary or NSArray
*/
func decodeJSON(data: NSData) -> Result<JSON> {
    var error: NSError?
    let jsonOptional: JSON! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error)
    
    var errorString = ""
    if let error = error {
        errorString = error.localizedDescription
    }
    let jsonError = GenericError.JSONError(errorString)
    return resultFromOptional(jsonOptional, jsonError) // use the error from NSJSONSerialization or a custom error message
}
