//
//  JSONDecodable.swift
//  InvescoTraining
//
//  Created by David Casserly on 19/11/2014.
//  Copyright (c) 2014 DevedUp Ltd. All rights reserved.
//

import Foundation

/**
    A protocol for model objects that decode JSON
*/
protocol JSONDecodable {
    static func decode(json: JSON) -> Self?
}


/**
    Decode JSON object into it's type into a Result object
*/
func decodeObject<U: JSONDecodable>(json: JSON) -> Result<U> {
    return resultFromOptional(U.decode(json), GenericError.UnexpectedUnkownError)
}

func decodeObjectArray<T: JSONDecodable>(jsonArray: JSONArray?) -> [T]? {
    if let jsonArray = jsonArray {
        var resultArray = [T]()
        for json: JSON in jsonArray {
            let decodedObject: T? = T.decode(json)
            if let decodedObject = decodedObject {
                resultArray.append(decodedObject)
            } else {
                return nil
            }
        }
        return resultArray
    } else {
        return nil
    }
}

func decodeObjectDictionary<T: JSONDecodable, U>(jsonDictionary: JSONDictionary?) -> [T: U]? {
    if let jsonDictionary = jsonDictionary {
        var resultDictionary = [T: U]()
        for key in jsonDictionary.keys {
            let value: U? = jsonDictionary[key] as? U
            if let value = value {
                let decodedObject: T? = T.decode(key)
                if let decodedObject = decodedObject {
                    resultDictionary[decodedObject] = value
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
        return resultDictionary
    } else {
        return nil
    }
}