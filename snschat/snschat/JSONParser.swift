//
//  JSONParser.swift
//  TrainSpot
//
//  Created by Joost van den Brandt on 08/04/15.
//  Copyright (c) 2015 Joost van den Brandt. All rights reserved.
//

import Foundation
struct JSONParser{
    
    static func JSONParseDictionary(jsonString: String) -> [[String: AnyObject]] {
        var error:NSError? = nil
        if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding){
            if let jsonObject: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: nil, error:&error) {
                if let dict = jsonObject as? [[String:AnyObject]] {
                    return dict;
                } else {
                    println("Not convertable to dictionary")
                }
            } else {
                println("Could not parse JSON: \(error!)")
            }
        }else{
            println("JSON String is not convertable to NSData")
        }
        return [[String:AnyObject]]()
    }
    
    static func JSONStringify(value: AnyObject, prettyPrinted: Bool = false) -> String {
        var e:NSError?
        var options = prettyPrinted ? NSJSONWritingOptions.PrettyPrinted : nil
        if NSJSONSerialization.isValidJSONObject(value) {
            if let data = NSJSONSerialization.dataWithJSONObject(value, options: options, error: &e) {
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    return string as String
                }else{
                    println("Iets anders ging fout met het converteren van JSON naar String. Is de string UTF8?")
                }
            }else{
                println(e)
            }
        }else{
            println("No valid JSON")
        }
        return ""
    }
    
    static func JSONParseArray(jsonString: String) -> [AnyObject] {
        if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
            if let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)  as? [AnyObject] {
                return array
            }
        }
        return [AnyObject]()
    }
    
    
    static func JSONParseObject(jsonString: String) -> AnyObject {
        var err:NSError?
        if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
            if let array:AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &err){
                return array
            }else{
                println("Problem parsing jsonObject \(err) \n Data: \(jsonString)");
            }
        }
        return [AnyObject]()
    }
}