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
    
    public func get<T:protocol<ArrowParsable,RestResource>>(restResource:T, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<T> {
        return get(restURL(restResource), params: params)
    }

    /// <Void> version
    public func get<T:protocol<ArrowParsable,RestResource>>(restResource:T, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<Void> {
        return get(restURL(restResource), params: params)
    }
    
    //MARK: - POST
    
    public func post<T:protocol<ArrowParsable,RestResource>>(restResource:T, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<T> {
        return post(restURL(restResource), params: params)
    }
    
    /// <Void> version
    public func post<T:protocol<ArrowParsable,RestResource>>(restResource:T, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<Void> {
        return post(restURL(restResource), params: params)
    }
    
    //MARK: - PUT
    
    public func put<T:protocol<ArrowParsable,RestResource>>(restResource:T, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<T> {
        return put(restURL(restResource), params: params)
    }

    public func put<T:protocol<ArrowParsable,RestResource>>(restResource:T, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<Void> {
        return put(restURL(restResource), params: params)
    }
    
    //MARK: - DELETE
    
    public func delete<T:protocol<ArrowParsable,RestResource>>(restResource:T) -> Promise<T> {
        return delete(restURL(restResource))
    }
    
    /// <Void> version
    public func delete<T:protocol<ArrowParsable,RestResource>>(restResource:T) -> Promise<Void> {
        return delete(restURL(restResource))
    }

}