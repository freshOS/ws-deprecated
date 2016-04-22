//
//  WS.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 13/11/15.
//  Copyright © 2015 s4cha. All rights reserved.
//


import Foundation
import Alamofire
import Arrow
import then

var kWSJsonParsingSingleResourceKey:String? = nil
var kWSJsonParsingColletionKey:String? = nil

public class WS {
    
    /**
        Prints network calls to the console. 
        Values Available are .None, Calls and CallsAndResponses.
        Default is None
    */
    public var logLevels = WSLogLevel.None
    
    /**
        Displays network activity indicator at the top left hand corner of the iPhone's screen in the status bar.
        Is shown by dafeult, set it to false to hide it.
     */
    public var showsNetworkActivityIndicator = true
    
    public var jsonParsingSingleResourceKey:String? = nil {
        didSet { kWSJsonParsingSingleResourceKey = jsonParsingSingleResourceKey }
    }
    
    public var jsonParsingColletionKey:String? = nil {
        didSet { kWSJsonParsingColletionKey = jsonParsingColletionKey }
    }
    
    public var baseURL = ""
    public var OAuthToken: String?
    
    /**
     Create a webservice instance.
     @param Pass the base url of your webservice, E.g : "http://jsonplaceholder.typicode.com"
     
     */
    public init(_ aBaseURL:String) {
        baseURL = aBaseURL
    }
    
    internal func call(url:String, verb:WSHTTPVerb = .GET, params:[String:AnyObject] = [String:AnyObject]()) -> WSRequest {
        let c = defaultCall()
        c.httpVerb = verb
        c.URL = url
        c.params = params
        c.returnsJSON = verb != .DELETE
        return c
    }
    
    public func defaultCall() -> WSRequest {
        let r = WSRequest()
        r.baseURL = baseURL
        r.logLevels = logLevels
        r.showsNetworkActivityIndicator = showsNetworkActivityIndicator
        if let token = OAuthToken {
            r.OAuthToken = token
        }
        return r
    }
    
    //MARK: - Calls
    
    public func get<T:ArrowParsable>(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<[T]> {
        return getRequest(url, params: params).fetch().registerThen { json -> [T] in
            let mapper = WSModelJSONParser<T>()
            let models = mapper.toModels(json)
            return models
        }
    }
    
    //MARK JSON versions
    
    public func get(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<JSON> {
        return getRequest(url, params: params).fetch()
    }
    
    public func post(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<JSON> {
        return postRequest(url, params: params).fetch()
    }
    
    public func put(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<JSON> {
        return putRequest(url, params: params).fetch()
    }
    
    public func delete(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<JSON> {
        return deleteRequest(url, params: params).fetch()
    }
    
    //MARK Void versions
    
    public func get(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<Void> {
        let r = getRequest(url, params: params)
        r.returnsJSON = false
        return r.fetch().registerThen { json -> Void in }
    }
    
    public func post(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<Void> {
        let r = postRequest(url, params: params)
        r.returnsJSON = false
        return r.fetch().registerThen { json -> Void in }
    }
    
    public func put(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<Void> {
        let r = putRequest(url, params: params)
        r.returnsJSON = false
        return r.fetch().registerThen { _ -> Void in }
    }
    
    public func delete(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<Void> {
        let r = deleteRequest(url, params: params)
        r.returnsJSON = false
        return r.fetch().registerThen { _ -> Void in }
    }
    
    //MARK: - Multipart
    
    public func postMultipart(url:String, params:[String:AnyObject] = [String:AnyObject](), name:String, data:NSData, fileName:String, mimeType:String) -> Promise<JSON> {
        let r = postMultipartRequest(url, params:params, name:name, data: data, fileName: fileName, mimeType: mimeType)
        return r.fetch()
    }
    
    public func putMultipart(url:String, params:[String:AnyObject] = [String:AnyObject](), name:String, data:NSData, fileName:String, mimeType:String) -> Promise<JSON> {
        let r = putMultipartRequest(url, params:params, name:name, data: data, fileName: fileName, mimeType: mimeType)
        return r.fetch()
    }
    
    // Keep here for now for backwards compatibility
    @available(*, deprecated=1.2.1, message="Use 'get' instead") public func list<T:ArrowParsable>(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<[T]> {
        let c = defaultCall()
        c.httpVerb = .GET
        c.URL = url
        c.params = params
        // Apply corresponding JSON mapper
        return c.fetch().registerThen { json -> [T] in
            let mapper = WSModelJSONParser<T>()
            let models = mapper.toModels(json)
            return models
        }
    }
}