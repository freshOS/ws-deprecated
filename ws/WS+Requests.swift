//
//  WS+Requests.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 06/04/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation

extension WS {
    
    public func getRequest(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> WSCall {
        return call(url, verb: .GET, params: params)
    }
    
    public func putRequest(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> WSCall {
        return call(url, verb: .PUT, params: params)
    }
    
    public func postRequest(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> WSCall {
        return call(url, verb: .POST, params: params)
    }
    
    public func deleteRequest(url:String) -> WSCall {
        return call(url, verb: .DELETE)
    }
    
}