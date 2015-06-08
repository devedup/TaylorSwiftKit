//
//  NetworkFileDownload.swift
//  InvescoTraining
//
//  Created by David Casserly on 03/12/2014.
//  Copyright (c) 2014 DevedUp Ltd. All rights reserved.
//

import Foundation

typealias DownloadCompletion = (fileDownload: NetworkFileDownload, location: String)
typealias DownloadCompletionResult = (Result<DownloadCompletion>) -> Void
typealias ResumeResult = (didResume: Bool) -> Void

typealias ProgressUpdated = (percentComplete: Float) -> Void

class URLSessions {
    
    private var urlSessions = Dictionary<String, NSURLSession>()
    
    class var sharedInstance: URLSessions {
        struct Static {
            static let instance = URLSessions()
        }
        return Static.instance
    }
    
    private init() {
    }
    
    func sessionForID(sessionID: String, delegate: NSURLSessionDownloadDelegate) -> NSURLSession {
        var session = urlSessions[sessionID]
        if session == nil {
            let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(sessionID)
            session = NSURLSession(configuration: config, delegate: delegate, delegateQueue: NSOperationQueue.mainQueue())
            urlSessions[sessionID] = session
            return session!
        } else {
            return session!
        }
    }
    
    func removeStoredSession(sessionID: String) {
        urlSessions.removeValueForKey(sessionID)
    }
}

class NetworkFileDownload: NSObject, NSURLSessionDownloadDelegate {
    
    private let sessionID: String
    private let request: NetworkRequest
    private var session: NSURLSession?
    private var task: NSURLSessionDownloadTask?
    
    var onDownloadCompletion: DownloadCompletionResult?
    var onProgressUpdate: ProgressUpdated?
    var onResume: ResumeResult?
    var backroundCompletionHandler: (() -> ())?
    
    private var httpRequest: NSURLRequest {
        let url: NSURL = self.request.url
        let request: NSURLRequest = NSURLRequest(URL: url)
        return request
    }
    
    init(sessionID: String, request: NetworkRequest) {
        self.sessionID = sessionID
        self.request = request
    }
    
    private func createSession() -> NSURLSession {
        // You must create exactly one session per identifier (specified when you create the configuration object).
        // The behavior of multiple sessions sharing the same identifier is undefined.
        // Keep this for iOS 7 for now
        
        /*
            Note for future.... dont create multiple sessions. Create one and use multiple tasks in the session!!!
        */
        return URLSessions.sharedInstance.sessionForID(sessionID, delegate: self)
    }
    
    func check() {
        let session = createSession()
        session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) -> Void in
            
            if downloadTasks.count == 1 {
                let task = downloadTasks[0] as! NSURLSessionDownloadTask
                self.task = task
                self.onResume!(didResume: true)
            } else {
                self.onResume!(didResume: false)
            }
      
        }
    }
    
    func startDownload() {
        task = createSession().downloadTaskWithRequest(httpRequest)
        task?.resume()
    }
    
    func cancelDownload() {
        task?.cancel()
    }
    
    func pauseDownload() {
        task?.cancelByProducingResumeData({ (data: NSData!) -> Void in
            
        })
    }
    
    /*
    func resumeDownload() {
        //  Load the resume data from the session ID
        let data = NSData()
        task = createSession().downloadTaskWithResumeData(data)
        task?.resume()
    }
    */
    
    // MARK: Download Delegate Methods
    
    // Download Complete
    // Important: Before this method returns, it must either open the file for reading or move it to a permanent location. When this method returns, the temporary file is deleted if it still exists at its original location.
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        println("Session \(session) download task \(downloadTask) finished downloading to URL \(location)\n")
        
        let fileManager = NSFileManager.defaultManager()
        let homeDir = fileManager.URLForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true, error: nil)!
        
        var destination = homeDir.URLByAppendingPathComponent(location.lastPathComponent!, isDirectory: false)
        destination = destination.URLByAppendingPathExtension(".mp4")
        
        var file = destination.lastPathComponent!
        
        var error: NSError?
        if(fileManager.moveItemAtURL(location, toURL: destination, error: &error)) {
            if let downloadComplete = onDownloadCompletion {
                let result = Result<DownloadCompletion>.Success(Box<DownloadCompletion>((fileDownload: self, location: file)))
                downloadComplete(result)
            }
        } else {
            if let downloadComplete = onDownloadCompletion {
                let result = Result<DownloadCompletion>.Error(GenericError.DownloadFailed)
                downloadComplete(result)
            }
        }        
    }
    
    // Resuming
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        println("Session \(session) download task \(downloadTask) resumed at offset \(fileOffset) bytes out of an expected \(expectedTotalBytes) bytes.\n")
    }
    
    // Download Progress
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let percentageComplete: Float = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        if let progress = onProgressUpdate {
            progress(percentComplete: percentageComplete)
        }
        
//        println("Session \(session) download task \(downloadTask) wrote an additional \(bytesWritten) bytes (total \(totalBytesWritten) bytes) out of an expected \(totalBytesExpectedToWrite) bytes.\n")
    }
    
    // Error Occurred
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        // if resumable... userinfo contains NSURLSessionDownloadTaskResumeData
        if let error = error {
            if let downloadComplete = onDownloadCompletion {
                let errorMine = NetworkError.fromNSError(error, urlResponse: nil)
                let result = Result<DownloadCompletion>.Error(errorMine)
                downloadComplete(result)
            }
        }
    }
    
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        let sessionID = session.configuration.identifier
        URLSessions.sharedInstance.removeStoredSession(sessionID)
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        if let completion = backroundCompletionHandler {
            completion()
        }
    }
}
