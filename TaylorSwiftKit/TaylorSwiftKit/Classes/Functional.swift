//
//  Functional.swift
//  InvescoTraining
//
//  Created by David Casserly on 19/11/2014.
//  Copyright (c) 2014 DevedUp Ltd. All rights reserved.
//

import Foundation

infix operator >>> { associativity left precedence 150 } // bind >>=
infix operator <^> { associativity left } // Functor's fmap (usually <$>)
infix operator <*> { associativity left } // Applicative's apply


/*

Using these functions we’ll still need a bunch of if-let syntax. The functional programming concepts Monads, Applicative Functors, and Currying will help to condense this parsing. First, let’s look at the Maybe Monad which is similar to Swift optionals. Monads have a bind operator which, when used with optionals, allows us to bind an optional with a function that takes a non-optional and returns an optional. If the first optional is .None then it returns .None, otherwise it unwraps the first optional and applies the function to it.
*/


/**
If the first param is not nil, then execute the second param, the function,
with the first param as the argument

:see: FunctionalTests.swift

:param: a an optional of any type A
:param: f a function that takes A as the sole param and returns an optional of type B
:return: an optional type of B
*/
func >>><A, B>(a: A?, f: A -> B?) -> B? {
    if let x = a {
        return f(x)
    } else {
        return .None
    }
}

/**
If the first param Result<A> is Success, then call the second param, a function,
with Result<A> and return Result<B>

:see: FunctionalTests.swift

:param: a a Result object of type A
:param: f a function that takes A as the sole param and returns a Result<B> type
:return: a Result<B> type
*/
func >>><A, B>(a: Result<A>, f: A -> Result<B>) -> Result<B> {
    switch a {
    case let .Success(x):
        return f(x.value)
    case let .Error(error):
        return .Error(error)
    }
}

/*

Functors have an fmap operator for applying functions to values wrapped in some context. Applicative Functors also have an apply operator for applying wrapped functions to values wrapped in some context. The context here is an Optional which wraps our value. This means that we can combine multiple optional values with a function that takes multiple non-optional values. If all values are present, .Some, then we get a result wrapped in an optional. If any of the values are .None, we get .None. We can define these operators in Swift like this:

*/


/*
This is similar to the monad >>>, but the params are the other way around
*/
func <^><A, B>(f: A -> B, a: A?) -> B? {
    if let x = a {
        return f(x)
    } else {
        return .None
    }
}

/**
This checks if the second param is an optional, if it's an optional nil then it return nil.
Else, if the first param function is not nil, then it applies the first function to the second param
*/
func <*><A, B>(f: (A -> B)?, a: A?) -> B? {
    if let x = a {
        if let fx = f {
            return fx(x)
        }
    }
    return .None
}