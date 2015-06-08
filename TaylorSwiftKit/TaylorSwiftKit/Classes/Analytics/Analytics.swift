//
//  Analytics.swift
//  InvescoTraining
//
//  Created by David Casserly on 04/12/2014.
//  Copyright (c) 2014 DevedUp Ltd. All rights reserved.
//

import Foundation

enum AnalyticsEvent: String {
    case SubmittingUserDetails = "SubmittingUserDetails"
    case ResubmittingUserDetails = "ResubmittingUserDetails"
    case SubmittedUserDetailsSuccess = "SubmittedUserDetailsSuccess"
    case CleaningUpFailedDownload = "CleaningUpFailedDownload"
}

enum Page: String {
    case LoadingScreen = "LoadingScreen"
    case ComplianceScreen = "ComplianceScreen"
    case VideoScreen = "VideoScreen"
    case QuestionScreen = "QuestionScreen"
    case MovieScreen = "MovieScreen"
    case FormScreen = "FormScreen"
    case ErrorScreen = "ErrorScreen"
    case ResubmitScreen = "ResubmitScreen"
    case InfoScreen = "InfoScreen"
}

class Analytics {
    
    class var sharedInstance: Analytics {
        struct Static {
            static let instance = Analytics()
        }
        return Static.instance
    }
    
    private init() {        
    }

    class func start() {
        var key: String?
        #if DEBUG
        key = Property.FlurryKeyDev.value
        #else
        key = Property.FlurryKey.value
        #endif
        println("Starting Analytics with key [\(key)]")
//        Flurry.startSession(key)
    }
    
    class func logError(error: ErrorType) {
        logError(error, withDetails: "")
    }
    
    class func logError(error: ErrorType, withDetails details: String) {
        var dict = ["Description": error.messageLocalized(), "Details": details]
//        Flurry.logEvent(error.titleLocalized(), withParameters: dict)
    }
    
    class func logEvent(event: AnalyticsEvent) {
//        Flurry.logEvent(event.rawValue)
    }
    
    class func logEvent(event: AnalyticsEvent, withParameters params: [String: String]) {
//        Flurry.logEvent(event.rawValue, withParameters: params)
    }
    
    
    class func logStartPageView(page: Page) {
//        Flurry.logEvent(page.rawValue, withParameters: nil, timed: true)
    }
    
    class func logStartPageView(page: Page, withParameters params: [String: String]) {
        #if DEBUG
        println("Start page \(page.rawValue)")
        #endif
//        Flurry.logEvent(page.rawValue, withParameters: params, timed: true)
    }
    
    class func logEndPageView(page: Page) {
//        Flurry.endTimedEvent(page.rawValue, withParameters: nil)
    }
}    