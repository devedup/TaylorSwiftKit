//
//  API.swift
//  InvescoTraining
//
//  Created by David Casserly on 17/11/2014.
//  Copyright (c) 2014 DevedUp Ltd. All rights reserved.
//

import Foundation
import SystemConfiguration

public enum HTTPMethod {
    case GET
    case POST
}

struct NetworkRequest {
    let url: NSURL
    let method: HTTPMethod
    
    init(url: NSURL) {
        self.url = url
        self.method = HTTPMethod.GET
    }
    
    init?(url: String) {
        if let url = NSURL(string: url) {
            self.init(url: url)
        } else {
            return nil
        }
    }
}

struct NetworkResponse {
    let data: NSData
    let status: Int
    
    init(data: NSData, response: NSURLResponse) {
        self.data = data
        if let httpResponse = response as? NSHTTPURLResponse {
            status = httpResponse.statusCode
        } else {
            status = 500
        }
    }
}

protocol Network {
    
    /**
        This takes a network request and returns either a parsed data model object
        or an error in the Result object
    */
    func performRequest<A: JSONDecodable>(request: NetworkRequest, callback: (Result<A>) -> ())
    
}

