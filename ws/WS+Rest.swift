//
//  WS+Rest.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 06/04/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation
import Arrow
import then

extension WS {

    //MARK: - GET
    
    public func get<T:ArrowParsable & RestResource>(_ restResource:T, params:[String:Any] = [String:Any]()) -> Promise<T> {
        return get(restURL(restResource), params: params)
    }

    /// <Void> version
    public func get<T:ArrowParsable & RestResource>(_ restResource:T, params:[String:Any] = [String:Any]()) -> Promise<Void> {
        return get(restURL(restResource), params: params)
    }
    
    //MARK: - POST
    
    public func post<T:ArrowParsable & RestResource>(_ restResource:T, params:[String:Any] = [String:Any]()) -> Promise<T> {
        return post(restURL(restResource), params: params)
    }
    
    /// <Void> version
    public func post<T:ArrowParsable & RestResource>(_ restResource:T, params:[String:Any] = [String:Any]()) -> Promise<Void> {
        return post(restURL(restResource), params: params)
    }
    
    //MARK: - PUT
    
    public func put<T:ArrowParsable & RestResource>(_ restResource:T, params:[String:Any] = [String:Any]()) -> Promise<T> {
        return put(restURL(restResource), params: params)
    }

    public func put<T:ArrowParsable & RestResource>(_ restResource:T, params:[String:Any] = [String:Any]()) -> Promise<Void> {
        return put(restURL(restResource), params: params)
    }
    
    //MARK: - DELETE
    
    public func delete<T:ArrowParsable & RestResource>(_ restResource:T) -> Promise<T> {
        return delete(restURL(restResource))
    }
    
    /// <Void> version
    public func delete<T:ArrowParsable & RestResource>(_ restResource:T) -> Promise<Void> {
        return delete(restURL(restResource))
    }

}
