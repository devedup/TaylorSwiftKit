//
//  Result.swift
//  InvescoTraining
//
//  Created by David Casserly on 19/11/2014.
//  Copyright (c) 2014 DevedUp Ltd. All rights reserved.
//

import Foundation

/** 
    A Result object to hole either the Success or NSError from a callback
*/
enum Result<A> {
    
    case Success(Box<A>)
    case Error(ErrorType)
    
    init(_ error: ErrorType?, _ value: A) {
        if let err = error {
            self = .Error(err)
        } else {
            self = .Success(Box(value))
        }
    }
}

/**
    Util function to get a Result object from passing in an optional data object
    and an NSError.

    If the optional is nil, it will return a Result.Error, else it will return Result.Success

*/
func resultFromOptional<A>(optional: A?, error: ErrorType?) -> Result<A> {
    if let a = optional {
        return .Success(Box(a))
    } else {
        if let error = error {
            return .Error(error)
        } else {
            return .Error(GenericError.UnexpectedUnkownError)
        }
    }
}

/**
    Boxing of a value to be used in an generic enum
*/
final class Box<T> {
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
}



