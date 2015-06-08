//
//  NetworkService.swift
//  InvescoTraining
//
//  Created by David Casserly on 18/11/2014.
//  Copyright (c) 2014 DevedUp Ltd. All rights reserved.
//

import Foundation

class JSONNetworkService: Network {
    
    private var urlToCache: NSURL?
    
    init() {
    }
    
    /**
        Make the network call
    */
    func performRequest<A: JSONDecodable>(request: NetworkRequest, callback: (Result<A>) -> ()) {
        // Build the NSURLRequest from the NetworkRequest
        let url: NSURL = request.url
        urlToCache = url
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        let cache = OfflineData()
        var cacheData = cache.readFromFile(url)
        if let cacheData = cacheData {
            let response = NSHTTPURLResponse(URL: url, statusCode: 200, HTTPVersion: nil, headerFields: nil)
            callback(self.parseResult(cacheData, response))
        } else {
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, urlResponse, error in                    
                
                let networkError = NetworkError.fromNSError(error, urlResponse: urlResponse)
                
                switch (data, urlResponse, error) {
                    // We have data, urlresponse and no error SUCCESS
                case let (.Some(data), .Some(urlResponse), .None(noError)):
                    callback(self.parseResult(data, urlResponse))
                case let (.Some(data), .None(noURLResponse), .Some(error)):
                    callback(Result.Error(networkError))
                case let (.None(noData), .None(noURLResponse), .Some(error)):
                    callback(Result.Error(networkError))
                default:
                    callback(Result.Error(networkError))
                }
                
            }
            task.resume()
        }
    }
        
    private func parseResult<A: JSONDecodable>(data: NSData!, _ urlResponse: NSURLResponse!) -> Result<A> {
        let responseResult: Result<NetworkResponse> = Result(nil, NetworkResponse(data: data, response: urlResponse))
        
        let response: Result<A> = responseResult >>> parseNetworkResponse
            >>> decodeJSON
            >>> decodeObject
        
        // We only cache it if it parsed correctly
        switch response {
        case .Success(let value):
            let cache = OfflineData()
            if let urlToCache = urlToCache {
                cache.writeToFile(data, url: urlToCache)
            }            
        case .Error(let error):
            Analytics.logError(error, withDetails: "Didn't parse JSON")
        }
        return response
    }
    
    /**
        Parse the network response and ensure that its a succesful response
    */
    private func parseNetworkResponse(response: NetworkResponse) -> Result<NSData> {
        let successRange = 200..<300
        if !contains(successRange, response.status) {
            var description = NSHTTPURLResponse.localizedStringForStatusCode(response.status)
            let networkError = NetworkError(statusCode: response.status, message: description)
            return .Error(networkError)
        }
        return Result(nil, response.data)
    }
    
    
}