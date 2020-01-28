//
//  WS+TypedCalls.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 06/04/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Arrow
import Foundation
import Combine

extension WS {
    
    public func get<T: ArrowParsable>(_ url: String,
                                      params: Params = Params(),
                                      keypath: String? = nil) -> Promise<[T]> {
        let keypath = keypath ?? defaultCollectionParsingKeyPath
        return getRequest(url, params: params)
            .fetch()
            .map { json -> [T] in
                return WSModelJSONParser<T>().toModels(json, keypath: keypath)
            }.eraseToAnyPublisher()
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
        return c.fetch().map { (json: JSON) -> T in
            return WSModelJSONParser<T>().toModel(json, keypath: keypath)
        }.eraseToAnyPublisher().resolveOnMainThread()
    }
}

extension WS {
    
    public func get<T: ArrowInitializable>(_ url: String,
                                           params: Params = Params(),
                                           keypath: String? = nil) -> Promise<[T]> {
        let req: Promise<JSON> = getRequest(url, params: params).fetch()
        let keypath = keypath ?? defaultCollectionParsingKeyPath
        return req.tryMap { (json:JSON) -> [T] in
            if let t: [T] = WSModelJSONParser<T>().toModels(json, keypath: keypath) {
                return t
            } else {
                throw WSError.unableToParseResponse
            }
        }.eraseToAnyPublisher().resolveOnMainThread()
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
        return c.fetch().tryMap { (json:JSON) -> T in
            if let t: T = WSModelJSONParser<T>().toModel(json, keypath: keypath) {
                return t
            } else {
                throw WSError.unableToParseResponse
            }
        }.eraseToAnyPublisher().resolveOnMainThread()
    }
    
}
