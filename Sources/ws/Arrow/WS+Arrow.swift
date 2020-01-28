//
//  WS+Arrow.swift
//  
//
//  Created by Sacha DSO on 28/01/2020.
//

import Foundation
import Arrow


open class WSModelJSONParser<T> {
    
    public init() {}
    
    fileprivate func resourceData(from json: JSON, keypath: String?) -> JSON {
        if let k = keypath, !k.isEmpty, let j = json[k] {
            return j
        }
        return json
    }
}

extension WSModelJSONParser where T: ArrowInitializable {
    
    open func toModel(_ wsJSON: WSJSON, keypath: String? = nil) -> T? {
        let arrowJSON = JSON(wsJSON)!
        return T.init(resourceData(from: arrowJSON, keypath: keypath))
    }
 
    open func toModels(_ wsJSON: WSJSON, keypath: String? = nil) -> [T]? {
        let arrowJSON = JSON(wsJSON)!
        return [T].init(resourceData(from: arrowJSON, keypath: keypath))
    }
}

extension WSModelJSONParser where T: ArrowParsable {

    open func toModel(_ wsJSON: WSJSON, keypath: String? = nil) -> T {
        let arrowJSON = JSON(wsJSON)!
        let data = resourceData(from: arrowJSON, keypath: keypath)
        return resource(from: data)
    }
    
    open func toModels(_ wsJSON: WSJSON, keypath: String? = nil) -> [T] {
        let arrowJSON = JSON(wsJSON)!
        guard let array = resourceData(from: arrowJSON, keypath: keypath).collection else {
            return [T]()
        }
        return array.map { resource(from: $0) }
    }
    
    private func resource(from json: JSON) -> T {
        var t = T()
        t.deserialize(json)
        return t
    }
}


extension WS {
    
    public func get<T: ArrowParsable>(_ url: String,
                                      params: Params = Params(),
                                      keypath: String? = nil) -> WSCall<[T]> {
        let keypath = keypath ?? defaultCollectionParsingKeyPath
        return getRequest(url, params: params)
            .fetch()
            .map { json -> [T] in
                return WSModelJSONParser<T>().toModels(json, keypath: keypath)
            }.eraseToAnyPublisher()
    }
    
    public func get<T: ArrowParsable>(_ url: String,
                                      params: Params = Params(),
                                      keypath: String? = nil) -> WSCall<T> {
        return resourceCall(.get, url: url, params: params, keypath: keypath)
    }
    
    public func post<T: ArrowParsable>(_ url: String,
                                       params: Params = Params(),
                                       keypath: String? = nil) -> WSCall<T> {
        return resourceCall(.post, url: url, params: params, keypath: keypath)
    }
    
    public func put<T: ArrowParsable>(_ url: String,
                                      params: Params = Params(),
                                      keypath: String? = nil) -> WSCall<T> {
        return resourceCall(.put, url: url, params: params, keypath: keypath)
    }
    
    public func delete<T: ArrowParsable>(_ url: String,
                                         params: Params = Params(),
                                         keypath: String? = nil) -> WSCall<T> {
        return resourceCall(.delete, url: url, params: params, keypath: keypath)
    }
    
    private func resourceCall<T: ArrowParsable>(_ verb: WSHTTPVerb,
                                                url: String,
                                                params: Params = Params(),
                                                keypath: String? = nil) -> WSCall<T> {
        let c = defaultCall()
        c.httpVerb = verb
        c.URL = url
        c.params = params
        return c.fetch().map { (json: WSJSON) -> T in
            return WSModelJSONParser<T>().toModel(json, keypath: keypath)
        }.eraseToAnyPublisher().receiveOnMainThread()
    }
}

// get, post, put, delete <T:ArrowInitializable> (_ url: String, params: Params = Params(), keypath: String? = nil) -> WSCall<T>


extension WS {
    
    public func get<T: ArrowInitializable>(_ url: String,
                                           params: Params = Params(),
                                           keypath: String? = nil) -> WSCall<[T]> {
        let req: WSCall<WSJSON> = getRequest(url, params: params).fetch()
        let keypath = keypath ?? defaultCollectionParsingKeyPath
        return req.tryMap { (json:WSJSON) -> [T] in
            if let t: [T] = WSModelJSONParser<T>().toModels(json, keypath: keypath) {
                return t
            } else {
                throw WSError.unableToParseResponse
            }
        }.eraseToAnyPublisher().receiveOnMainThread()
    }
    
    public func get<T: ArrowInitializable>(_ url: String,
                                           params: Params = Params(),
                                           keypath: String? = nil) -> WSCall<T> {
        return typeCall(.get, url: url, params: params, keypath: keypath)
    }
    
    public func post<T: ArrowInitializable>(_ url: String,
                                            params: Params = Params(),
                                            keypath: String? = nil) -> WSCall<T> {
        return typeCall(.post, url: url, params: params, keypath: keypath)
    }
    
    public func put<T: ArrowInitializable>(_ url: String,
                                           params: Params = Params(),
                                           keypath: String? = nil) -> WSCall<T> {
        return typeCall(.put, url: url, params: params, keypath: keypath)
    }
    
    public func delete<T: ArrowInitializable>(_ url: String,
                                              params: Params = Params(),
                                              keypath: String? = nil) -> WSCall<T> {
        return typeCall(.delete, url: url, params: params, keypath: keypath)
    }
    
    private func typeCall<T: ArrowInitializable>(_ verb: WSHTTPVerb,
                                                 url: String, params: Params = Params(),
                                                 keypath: String? = nil) -> WSCall<T> {
        let c = defaultCall()
        c.httpVerb = verb
        c.URL = url
        c.params = params
        
        // Apply corresponding JSON mapper
        return c.fetch().tryMap { (json:WSJSON) -> T in
            if let t: T = WSModelJSONParser<T>().toModel(json, keypath: keypath) {
                return t
            } else {
                throw WSError.unableToParseResponse
            }
        }.eraseToAnyPublisher().receiveOnMainThread()
    }
    
}


