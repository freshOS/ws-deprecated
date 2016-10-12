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

    public func get<T:ArrowParsable>(_ url:String, params:[String:Any] = [String:Any]()) -> Promise<T> {
        return resourceCall(.get, url: url, params: params)
    }
    
    public func post<T:ArrowParsable>(_ url:String, params:[String:Any] = [String:Any]()) -> Promise<T> {
        return resourceCall(.post, url: url, params: params)
    }
    
    public func put<T:ArrowParsable>(_ url:String, params:[String:Any] = [String:Any]()) -> Promise<T> {
        return resourceCall(.put, url: url, params: params)
    }
    
    public func delete<T:ArrowParsable>(_ url:String, params:[String:Any] = [String:Any]()) -> Promise<T> {
        return resourceCall(.delete, url: url, params: params)
    }
    
    fileprivate func resourceCall<T:ArrowParsable>(_ verb:WSHTTPVerb = .get, url:String, params:[String:Any] = [String:Any]()) -> Promise<T> {
        let c = defaultCall()
        c.httpVerb = verb
        c.URL = url
        c.params = params
        
        // Apply corresponding JSON mapper
        return c.fetch().registerThen { (json: JSON) -> T in
            let mapper = WSModelJSONParser<T>()
            let model = mapper.toModel(json)
            return model
        }.resolveOnMainThread()
    }
}
