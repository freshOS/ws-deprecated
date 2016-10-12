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

open class WS {
    
    /**
        Prints network calls to the console. 
        Values Available are .None, Calls and CallsAndResponses.
        Default is None
    */
    open var logLevels = WSLogLevel.none
    open var postParameterEncoding: ParameterEncoding = URLEncoding()
    
    /**
        Displays network activity indicator at the top left hand corner of the iPhone's screen in the status bar.
        Is shown by dafeult, set it to false to hide it.
     */
    open var showsNetworkActivityIndicator = true
    
    open var jsonParsingSingleResourceKey:String? = nil {
        didSet { kWSJsonParsingSingleResourceKey = jsonParsingSingleResourceKey }
    }
    
    open var jsonParsingColletionKey:String? = nil {
        didSet { kWSJsonParsingColletionKey = jsonParsingColletionKey }
    }
    
    open var baseURL = ""
    open var OAuthToken: String?
    open var headers = [String: String]()
    
    /**
     Create a webservice instance.
     @param Pass the base url of your webservice, E.g : "http://jsonplaceholder.typicode.com"
     
     */
    public init(_ aBaseURL:String) {
        baseURL = aBaseURL
    }
    
    internal func call(_ url:String, verb:WSHTTPVerb = .get, params:[String:Any] = [String:Any]()) -> WSRequest {
        let c = defaultCall()
        c.httpVerb = verb
        c.URL = url
        c.params = params
        return c
    }
    
    open func defaultCall() -> WSRequest {
        let r = WSRequest()
        r.baseURL = baseURL
        r.logLevels = logLevels
        r.postParameterEncoding = postParameterEncoding
        r.showsNetworkActivityIndicator = showsNetworkActivityIndicator
        if let token = OAuthToken {
            r.OAuthToken = token
        }
        r.headers = headers
        return r
    }
    
    //MARK: - Calls
    
    open func get<T:ArrowParsable>(_ url:String, params:[String:Any] = [String:Any]()) -> Promise<[T]> {
        return getRequest(url, params: params).fetch().registerThen { (json: JSON) -> [T] in
            let mapper = WSModelJSONParser<T>()
            let models = mapper.toModels(json)
            return models
        }.resolveOnMainThread()
    }
    
    
    //MARK JSON versions
    
    open func get(_ url:String, params:[String:Any] = [String:Any]()) -> Promise<JSON> {
        return getRequest(url, params: params).fetch().resolveOnMainThread()
    }
    
    open func post(_ url:String, params:[String:Any] = [String:Any]()) -> Promise<JSON> {
        return postRequest(url, params: params).fetch().resolveOnMainThread()
    }
    
    open func put(_ url:String, params:[String:Any] = [String:Any]()) -> Promise<JSON> {
        return putRequest(url, params: params).fetch().resolveOnMainThread()
    }
    
    open func delete(_ url:String, params:[String:Any] = [String:Any]()) -> Promise<JSON> {
        return deleteRequest(url, params: params).fetch().resolveOnMainThread()
    }
    
    //MARK Void versions
    
    open func get(_ url:String, params:[String:Any] = [String:Any]()) -> Promise<Void> {
        let r = getRequest(url, params: params)
        r.returnsJSON = false
        return r.fetch().registerThen { (json: JSON) -> Void in }.resolveOnMainThread()
    }
    
    open func post(_ url:String, params:[String:Any] = [String:Any]()) -> Promise<Void> {
        let r = postRequest(url, params: params)
        r.returnsJSON = false
        return r.fetch().registerThen { (json:JSON) -> Void in }.resolveOnMainThread()
    }
    
    open func put(_ url:String, params:[String:Any] = [String:Any]()) -> Promise<Void> {
        let r = putRequest(url, params: params)
        r.returnsJSON = false
        return r.fetch().registerThen { (_:JSON) -> Void in }.resolveOnMainThread()
    }
    
    open func delete(_ url:String, params:[String:Any] = [String:Any]()) -> Promise<Void> {
        let r = deleteRequest(url, params: params)
        r.returnsJSON = false
        return r.fetch().registerThen { (_: JSON) -> Void in }.resolveOnMainThread()
    }
    
    //MARK: - Multipart
    
    open func postMultipart(_ url:String, params:[String:Any] = [String:Any](), name:String, data:Data, fileName:String, mimeType:String) -> Promise<JSON> {
        let r = postMultipartRequest(url, params:params, name:name, data: data, fileName: fileName, mimeType: mimeType)
        return r.fetch().resolveOnMainThread()
    }
    
    open func putMultipart(_ url:String, params:[String:Any] = [String:Any](), name:String, data:Data, fileName:String, mimeType:String) -> Promise<JSON> {
        let r = putMultipartRequest(url, params:params, name:name, data: data, fileName: fileName, mimeType: mimeType)
        return r.fetch().resolveOnMainThread()
    }
    
    // Keep here for now for backwards compatibility
    @available(*, deprecated: 1.2.1, message: "Use 'get' instead") open func list<T:ArrowParsable>(_ url:String, params:[String:Any] = [String:Any]()) -> Promise<[T]> {
        let c = defaultCall()
        c.httpVerb = .get
        c.URL = url
        c.params = params
        // Apply corresponding JSON mapper
        return c.fetch().registerThen { (json: JSON) -> [T] in
            let mapper = WSModelJSONParser<T>()
            let models = mapper.toModels(json)
            return models
        }.resolveOnMainThread()
    }
}




public extension Promise {
    
    public func resolveOnMainThread() -> Promise<T> {
        return Promise<T> { resolve, reject, progress in
            self.progress{ p in
                progress(p)
            }
            self.registerThen { t in
                DispatchQueue.main.async {
                    resolve(t)
                }
            }
            self.onError { e in
                DispatchQueue.main.async {
                    reject(e)
                }
            }
        }
    }
}
