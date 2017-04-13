//
//  WS+Requests.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 06/04/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation

public typealias Params = [String :Any]

extension WS {
    
    public func getRequest(_ url: String, params: Params = Params()) -> WSRequest {
        return call(url, verb: .get, params: params)
    }
    
    public func putRequest(_ url: String, params: Params = Params()) -> WSRequest {
        return call(url, verb: .put, params: params)
    }
    
    public func postRequest(_ url: String, params: Params = Params()) -> WSRequest {
        return call(url, verb: .post, params: params)
    }
    
    public func deleteRequest(_ url: String, params: Params = Params()) -> WSRequest {
        return call(url, verb: .delete, params: params)
    }
    
    public func postMultipartRequest(_ url: String,
                                     params: Params = Params(),
                                     name: String,
                                     data: Data,
                                     fileName: String,
                                     mimeType: String) -> WSRequest {
        let c = call(url, verb: .post, params: params)
        c.isMultipart = true
        c.multipartData = data
        c.multipartName = name
        c.multipartFileName = fileName
        c.multipartMimeType = mimeType
        return c
    }
    
    public func putMultipartRequest(_ url: String,
                                    params: Params = Params(),
                                    name: String,
                                    data: Data,
                                    fileName: String,
                                    mimeType: String) -> WSRequest {
        let c = call(url, verb: .put, params: params)
        c.isMultipart = true
        c.multipartData = data
        c.multipartName = name
        c.multipartFileName = fileName
        c.multipartMimeType = mimeType
        return c
    }
}
