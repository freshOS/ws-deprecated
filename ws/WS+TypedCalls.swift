//
//  WS+TypedCalls.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 06/04/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation
import Arrow
import then


extension WS {

    public func get<T:ArrowParsable>(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<T> {
        return resourceCall(.GET, url: url, params: params)
    }
    
    public func post<T:ArrowParsable>(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<T> {
        return resourceCall(.POST, url: url, params: params)
    }
    
    public func put<T:ArrowParsable>(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<T> {
        return resourceCall(.PUT, url: url, params: params)
    }
    
    public func delete<T:ArrowParsable>(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<T> {
        return resourceCall(.DELETE, url: url, params: params)
    }
    
    private func resourceCall<T:ArrowParsable>(verb:WSHTTPVerb = .GET, url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<T> {
        let c = defaultCall()
        c.httpVerb = verb
        c.URL = url
        c.params = params
        c.returnsJSON = verb != .DELETE
        
        // Apply corresponding JSON mapper
        return c.fetch().registerThen { json -> T in
            let mapper = WSModelJSONParser<T>()
            let model = mapper.toModel(json)
            return model
        }
    }
}
