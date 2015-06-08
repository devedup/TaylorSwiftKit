//
//  Errors.swift
//  InvescoTraining
//
//  Created by David Casserly on 04/12/2014.
//  Copyright (c) 2014 DevedUp Ltd. All rights reserved.
//

import Foundation

/// All the error enums you create, eg. RentalsError, AuthError will extend Error protcol. You can then pass any Error into the present Error function.
protocol ErrorType {
    func titleLocalized() -> String
    func messageLocalized() -> String
    func shouldDisplayToUser() -> Bool
}

enum GenericError {
    case UnexpectedUnkownError
    case DownloadFailed
    case JSONError(String)
    case NoInternetConnectionCantContinue
    case CustomBuiltError(String)
    case SubmissionError
}

/// Errors we don't display to user
enum InternalErrors: ErrorType {
    case DuplicateDownload
    case NetworkStringParseError
    case CouldntBuildJSON
    
    func titleLocalized() -> String {
        switch self {
        case .DuplicateDownload:
            return "Duplicate Download"
        case .NetworkStringParseError:
            return "Parsing result error"
        case .CouldntBuildJSON:
            return "Couldnt build json"
        }
    }
    
    func messageLocalized() -> String {
        switch self {
        case .DuplicateDownload:
            return "Trying to download whilst one in progress"
        case .NetworkStringParseError:
            return "Parsing the result from network failed"
        case .CouldntBuildJSON:
            return "Couldnt build json to sumbit user details, must have a nil value"
        }
    }
    
    func shouldDisplayToUser() -> Bool {
        return false
    }
}

extension GenericError: ErrorType {
    
    func titleLocalized() -> String {
        switch self {
        case .UnexpectedUnkownError:
            return localizedString("error_unknown_title")
        case .DownloadFailed:
            return localizedString("error_download_failed_title")
        case .JSONError(let message):
            return localizedString("error_json_parsing_title")
        case .NoInternetConnectionCantContinue:
            return localizedString("error_nointernet_cantcontinue_title")
        case .CustomBuiltError(let customErrorString):
            return customErrorString
        case .SubmissionError:
            return localizedString("error_submittingresults_title")
        }
    }
    
    func messageLocalized() -> String {
        switch self {
        case .UnexpectedUnkownError:
            return localizedString("error_unknown_description")
        case .DownloadFailed:
            return localizedString("error_download_failed_description")
        case .JSONError(let message):
            return localizedString("error_json_parsing_description", message)
        case .NoInternetConnectionCantContinue:
            return localizedString("error_nointernet_cantcontinue_description")
        case .CustomBuiltError(let customErrorString):
            return customErrorString
        case .SubmissionError:
            return localizedString("error_submittingresults_description")
        }
    }
    
    func shouldDisplayToUser() -> Bool {
        return true
    }
    
}

struct NetworkError: ErrorType {
    
    let statusCode: Int
    let message: String
    
    func titleLocalized() -> String {
        return "Network Error \(statusCode)"
    }
    
    func messageLocalized() -> String {
        return message
    }
    
    static func fromNSError(error: NSError?, urlResponse: NSURLResponse?) -> NetworkError {
        var httpStatusCode: Int?
        if let httpResponse = urlResponse as? NSHTTPURLResponse {
            httpStatusCode = httpResponse.statusCode
        }
        
        if let error = error {
            var code = error.code
            if let httpStatusCode = httpStatusCode {
                code = httpStatusCode
            }
            let descritpion = error.localizedDescription
            return NetworkError(statusCode: code, message: descritpion)
        } else {
            var code = 500
            if let httpStatusCode = httpStatusCode {
                code = httpStatusCode
            }
            return NetworkError(statusCode: code, message: "Unknown Error")
        }        
    }
    
    func shouldDisplayToUser() -> Bool {
        if wasCancelledByUser {
            return false
        } else {
            return true
        }
    }
    
    var wasCancelledByUser: Bool {
        return (statusCode == -999 && message == "cancelled") ? true : false
    }
}

/**
A top level function that can be used in error switch enums within your code to present the error enum as a simple display

:param: error the error to display
:param: vc the view controller that you are presenting it from
*/
func presentError(error: ErrorType, fromViewController vc: UIViewController, #onConfirm: (() -> ())?) {
    let title: String? = error.titleLocalized() == error.messageLocalized() ? nil : error.titleLocalized()
    if error.shouldDisplayToUser() {
        let ok = localizedString("ok")
        if objc_getClass("UIAlertController") != nil {
            var errorView = UIAlertController(title: title, message: error.messageLocalized(), preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: ok, style: .Default) { (action) in
                // ... do nothing
                if let onCofirmAction = onConfirm {
                    onCofirmAction()
                }
            }
            errorView.addAction(OKAction)
            vc.presentViewController(errorView, animated: true) {
                // ... do nothing
            }
        }
//        else {
//            // iOS 7 Support
//            var errorAlert = UIAlertView(title: title, message: error.messageLocalized(), delegate: nil, cancelButtonTitle: ok)
//            errorAlert.show()
//        }
        
    } else {
        println("This is a none user error to display")
    }
}

func presentError(error: ErrorType, fromViewController vc: UIViewController) {
    presentError(error, fromViewController: vc, onConfirm: nil)
}

func presentConfirmation(question: String, fromViewController vc: UIViewController, onConfirm: () -> () ) {
    let ok = localizedString("yes")
    let cancel = localizedString("no")
    
    if objc_getClass("UIAlertController") != nil {
        var confirmView = UIAlertController(title: nil, message: question, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: ok, style: .Default) { (action) in
            onConfirm()
        }
        let cancelAction = UIAlertAction(title: cancel, style: .Default, handler: { (action) in
            // ... do nothing
        })
        confirmView.addAction(cancelAction)
        confirmView.addAction(okAction)
        vc.presentViewController(confirmView, animated: true) {
            // ... do nothing
        }
    }
//    else {
//        // iOS 7 Support
//        var confirmView = UIAlertView(title: "", message: question, delegate: nil, cancelButtonTitle: cancel, otherButtonTitles: ok)
//        confirmView.showWithBlock({ (buttonIndex) -> Void in
//            if buttonIndex > 0 {
//                onConfirm()
//            }            
//        }, cancelBlock: { () -> Void in
//            // ... do nothing
//        })
//    }
}

typealias OptionAction = (String, () -> ())
func presentOptions(options: [OptionAction], fromViewController vc: UIViewController) {
    if objc_getClass("UIAlertController") != nil {
        var confirmView = UIAlertController(title: "Share", message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: { (action) in
            // ... do nothing
        })
        confirmView.addAction(cancelAction)
        
        for option in options {
            let action = UIAlertAction(title: option.0, style: .Default) { (action) in
                option.1()
            }
            confirmView.addAction(action)
        }
        vc.presentViewController(confirmView, animated: true) {
            // ... do nothing
        }
    }
//    else {
//        // iOS 7 Support
//        let actionSheet = UIActionSheet(title: "Share", delegate: nil, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
//        for option in options {
//            actionSheet.addButtonWithTitle(option.0)
//        }
//        
//        actionSheet.showFromView(vc.view, withBlock: { (buttonIndex) -> Void in
//            // ... do nothing
//        }, cancelBlock: { () -> Void in
//            // ... do nothing
//        })
//        
//    }
}

//func presentShare(items: [AnyObject], fromViewController vc: UIViewController, popUpFromView: UIView?) {
//    let activityView = UIActivityViewController(activityItems: items, applicationActivities: nil)
//    activityView.excludedActivityTypes = [UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToVimeo, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll]
//    
//    ifPad({ () -> () in
//        let popOver = UIPopoverController(contentViewController: activityView)
//        if let popUpFromView = popUpFromView {
//            popOver.presentPopoverFromRect(popUpFromView.bounds, inView: popUpFromView, permittedArrowDirections: UIPopoverArrowDirection.Down, animated: true)
//        }
//    }, elseIfPhone: { () -> () in
//        vc.presentViewController(activityView, animated: true) { () -> Void in
//            
//        }
//    })    
//}



