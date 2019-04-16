//
//  WS+Requests.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 06/04/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation

public typealias Params = [String: Any]

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
        let multiPart = WSMultiPartData(
            multipartData: data, 
            multipartName: name, 
            multipartFileName: fileName, 
            multipartMimeType: mimeType
        )
        return postMultipartRequest(url, params: params, multiPart: [multiPart])
    }
    
    public func postMultipartRequest(_ url: String,
                                     params: Params = Params(),
                                     multiPart: [WSMultiPartData]) -> WSRequest {
        let c = call(url, verb: .post, params: params)
        c.isMultipart = true
        c.multiPartData = multiPart
        return c
    }

    public func putMultipartRequest(_ url: String,
                                    params: Params = Params(),
                                    name: String,
                                    data: Data,
                                    fileName: String,
                                    mimeType: String) -> WSRequest {
        let multiPart = WSMultiPartData(
            multipartData: data, 
            multipartName: name, 
            multipartFileName: fileName, 
            multipartMimeType: mimeType
        )
        return putMultipartRequest(url, params: params, multiPart: [multiPart])
    }

    public func putMultipartRequest(_ url: String,
                                    params: Params = Params(),
                                    multiPart: [WSMultiPartData]) -> WSRequest {
        let c = call(url, verb: .put, params: params)
        c.isMultipart = true
        c.multiPartData = multiPart
        return c
    }
}
