//
//  Localization.swift
//  InvescoTraining
//
//  Created by David Casserly on 04/12/2014.
//  Copyright (c) 2014 DevedUp Ltd. All rights reserved.
//

import Foundation

/**
The implementation of this is open to discusion, but from the client code point of view, all you want to do is call a function with a key that returns the localized version. Sometimes you might want to do substitution of variables within the string, which is why you can pass variadic params.

:param: key the key to lookup in the localized strings file
:param: replacements variable number (0 - many) of strings that can replace placeholders in your localized string
:return: the localized string ready to display
*/
public func localizedString(key: String, replacements: String...) -> String {
    return NSLocalizedString(key, comment: "")
}