//
//  GetRequest.swift
//  TrainSpot
//
//  Created by Joost van den Brandt on 08/04/15.
//  Copyright (c) 2015 Joost van den Brandt. All rights reserved.
//

import Foundation
struct GetRequest {
    static func HTTPGet(url: String, callback: (String, String?) -> Void) {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        HTTPsendRequest(request, callback)
    }
    
    static func HTTPGetJSON(url: String, callback: (data: [[String:AnyObject]], error: String?) -> Void) {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        HTTPsendRequest(request) {
            (data: String, error: String?) -> Void in
            if (error != nil) {
                callback(data: [["":""]], error: error)
            } else {
                var jsonObj = JSONParser.JSONParseDictionary(data)
                callback(data: jsonObj, error: nil)
            }
        }
    }
}


