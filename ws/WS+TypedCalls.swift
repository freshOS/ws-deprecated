//
//  WS+TypedCalls.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 06/04/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Arrow
import Foundation
import then

extension WS {
    
    public func get<T: ArrowParsable>(_ url: String,
                                      params: Params = Params(),
                                      keypath: String? = nil) -> Promise<[T]> {
        let keypath = keypath ?? defaultCollectionParsingKeyPath
        return getRequest(url, params: params).fetch()
            .registerThen { (json: JSON) -> [T] in
                WSModelJSONParser<T>().toModels(json, keypath: keypath)
            }.resolveOnMainThread()
    }
    
    public func get<T: ArrowParsable>(_ url: String,
                                      params: Params = Params(),
                                      keypath: String? = nil) -> Promise<T> {
        return resourceCall(.get, url: url, params: params, keypath: keypath)
    }
    
    public func post<T: ArrowParsable>(_ url: String,
                                       params: Params = Params(),
                                       keypath: String? = nil) -> Promise<T> {
        return resourceCall(.post, url: url, params: params, keypath: keypath)
    }
    
    public func put<T: ArrowParsable>(_ url: String,
                                      params: Params = Params(),
                                      keypath: String? = nil) -> Promise<T> {
        return resourceCall(.put, url: url, params: params, keypath: keypath)
    }
    
    public func delete<T: ArrowParsable>(_ url: String,
                                         params: Params = Params(),
                                         keypath: String? = nil) -> Promise<T> {
        return resourceCall(.delete, url: url, params: params, keypath: keypath)
    }
    
    private func resourceCall<T: ArrowParsable>(_ verb: WSHTTPVerb,
                                                url: String,
                                                params: Params = Params(),
                                                keypath: String? = nil) -> Promise<T> {
        let c = defaultCall()
        c.httpVerb = verb
        c.URL = url
        c.params = params
        
        // Apply corresponding JSON mapper
        return c.fetch().registerThen { (json: JSON) -> T in
            return WSModelJSONParser<T>().toModel(json, keypath: keypath)
        }.resolveOnMainThread()
    }
    
}

extension WS {
    
    public func get<T: ArrowInitializable>(_ url: String,
                                           params: Params = Params(),
                                           keypath: String? = nil) -> Promise<[T]> {
        let keypath = keypath ?? defaultCollectionParsingKeyPath
        return getRequest(url, params: params)
            .fetch()
            .registerThen { (json: JSON) in
                Promise<[T]> { (resolve, reject) in
                    if let t: [T] = WSModelJSONParser<T>().toModels(json, keypath: keypath) {
                        resolve(t)
                    } else {
                        reject(WSError.unableToParseResponse)
                    }
                }
            }
            .resolveOnMainThread()
    }
    
    public func get<T: ArrowInitializable>(_ url: String,
                                           params: Params = Params(),
                                           keypath: String? = nil) -> Promise<T> {
        return typeCall(.get, url: url, params: params, keypath: keypath)
    }
    
    public func post<T: ArrowInitializable>(_ url: String,
                                            params: Params = Params(),
                                            keypath: String? = nil) -> Promise<T> {
        return typeCall(.post, url: url, params: params, keypath: keypath)
    }
    
    public func put<T: ArrowInitializable>(_ url: String,
                                           params: Params = Params(),
                                           keypath: String? = nil) -> Promise<T> {
        return typeCall(.put, url: url, params: params, keypath: keypath)
    }
    
    public func delete<T: ArrowInitializable>(_ url: String,
                                              params: Params = Params(),
                                              keypath: String? = nil) -> Promise<T> {
        return typeCall(.delete, url: url, params: params, keypath: keypath)
    }
    
    private func typeCall<T: ArrowInitializable>(_ verb: WSHTTPVerb,
                                                 url: String, params: Params = Params(),
                                                 keypath: String? = nil) -> Promise<T> {
        let c = defaultCall()
        c.httpVerb = verb
        c.URL = url
        c.params = params
        
        // Apply corresponding JSON mapper
        return c.fetch()
            .registerThen { (json: JSON) in
                Promise<T> { (resolve, reject) in
                    if let t: T = WSModelJSONParser<T>().toModel(json, keypath: keypath) {
                        resolve(t)
                    } else {
                        reject(WSError.unableToParseResponse)
                    }
                }
            }
            .resolveOnMainThread()
    }
    
}
