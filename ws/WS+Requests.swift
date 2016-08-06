//
//  WS+Requests.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 06/04/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation

extension WS {
    
    public func getRequest(_ url:String, params:[String:AnyObject] = [String:AnyObject]()) -> WSRequest {
        return call(url, verb: .GET, params: params)
    }
    
    public func putRequest(_ url:String, params:[String:AnyObject] = [String:AnyObject]()) -> WSRequest {
        return call(url, verb: .PUT, params: params)
    }
    
    public func postRequest(_ url:String, params:[String:AnyObject] = [String:AnyObject]()) -> WSRequest {
        return call(url, verb: .POST, params: params)
    }
    
    public func deleteRequest(_ url:String, params:[String:AnyObject] = [String:AnyObject]()) -> WSRequest {
        return call(url, verb: .DELETE, params: params)
    }
    
    public func postMultipartRequest(_ url:String, params:[String:AnyObject] = [String:AnyObject](), name:String, data:Data, fileName:String, mimeType:String) -> WSRequest {
        let c = call(url, verb: .POST, params: params)
        c.isMultipart = true
        c.multipartData = data
        c.multipartName = name
        c.multipartFileName = fileName
        c.multipartMimeType = mimeType
        return c
    }
    
    public func putMultipartRequest(_ url:String, params:[String:AnyObject] = [String:AnyObject](), name:String, data:Data, fileName:String, mimeType:String) -> WSRequest {
        let c = call(url, verb: .PUT, params: params)
        c.isMultipart = true
        c.multipartData = data
        c.multipartName = name
        c.multipartFileName = fileName
        c.multipartMimeType = mimeType
        return c
    }
    
}
