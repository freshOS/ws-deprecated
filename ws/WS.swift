//
//  WS.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 13/11/15.
//  Copyright © 2015 s4cha. All rights reserved.
//

import Alamofire
import Arrow
import Foundation
import then

open class WS {
    
    /**
        Instead of using the same keypath for every call eg: "collection",
        this enables to use a default keypath for parsing collections.
        This is overidden by the per-request keypath if present.
     
     */
    open var defaultCollectionParsingKeyPath: String?
    
    @available(*, unavailable, renamed:"defaultCollectionParsingKeyPath")
    open var jsonParsingColletionKey: String?
    
    /**
        Prints network calls to the console. 
        Values Available are .None, Calls and CallsAndResponses.
        Default is None
    */
    open var logLevels = WSLogLevel.off
    open var postParameterEncoding: ParameterEncoding = URLEncoding()
    
    /**
        Displays network activity indicator at the top left hand corner of the iPhone's screen in the status bar.
        Is shown by dafeult, set it to false to hide it.
     */
    open var showsNetworkActivityIndicator = true
    
    /**
     Custom error handler block, to parse error returned in response body.
     For example: `{ error: { code: 1, message: "Server error" } }`
     */
    open var errorHandler: ((JSON) -> Error?)?
    
    open var baseURL = ""
    open var headers = [String: String]()
    
    /**
     Create a webservice instance.
     @param Pass the base url of your webservice, E.g : "http://jsonplaceholder.typicode.com"
     
     */
    public init(_ aBaseURL: String) {
        baseURL = aBaseURL
    }
    
    // MARK: - Calls
    
    internal func call(_ url: String, verb: WSHTTPVerb = .get, params: Params = Params()) -> WSRequest {
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
        r.headers = headers
        r.errorHandler = errorHandler
        return r
    }
    
    // MARK: JSON calls
    
    open func get(_ url: String, params: Params = Params()) -> Promise<JSON> {
        return getRequest(url, params: params).fetch().resolveOnMainThread()
    }
    
    open func post(_ url: String, params: Params = Params()) -> Promise<JSON> {
        return postRequest(url, params: params).fetch().resolveOnMainThread()
    }
    
    open func put(_ url: String, params: Params = Params()) -> Promise<JSON> {
        return putRequest(url, params: params).fetch().resolveOnMainThread()
    }
    
    open func delete(_ url: String, params: Params = Params()) -> Promise<JSON> {
        return deleteRequest(url, params: params).fetch().resolveOnMainThread()
    }
    
    // MARK: Void calls
    
    open func get(_ url: String, params: Params = Params()) -> Promise<Void> {
        let r = getRequest(url, params: params)
        r.returnsJSON = false
        return r.fetch().registerThen { (_: JSON) -> Void in }.resolveOnMainThread()
    }
    
    open func post(_ url: String, params: Params = Params()) -> Promise<Void> {
        let r = postRequest(url, params: params)
        r.returnsJSON = false
        return r.fetch().registerThen { (_:JSON) -> Void in }.resolveOnMainThread()
    }
    
    open func put(_ url: String, params: Params = Params()) -> Promise<Void> {
        let r = putRequest(url, params: params)
        r.returnsJSON = false
        return r.fetch().registerThen { (_:JSON) -> Void in }.resolveOnMainThread()
    }
    
    open func delete(_ url: String, params: Params = Params()) -> Promise<Void> {
        let r = deleteRequest(url, params: params)
        r.returnsJSON = false
        return r.fetch().registerThen { (_: JSON) -> Void in }.resolveOnMainThread()
    }
    
    // MARK: - Multipart
    
    open func postMultipart(_ url: String,
                            params: Params = Params(),
                            name: String,
                            data: Data,
                            fileName: String,
                            mimeType: String) -> Promise<JSON> {
        let r = postMultipartRequest(url,
                                     params:params,
                                     name:name,
                                     data: data,
                                     fileName: fileName,
                                     mimeType: mimeType)
        return r.fetch().resolveOnMainThread()
    }
    
    open func putMultipart(_ url: String,
                           params: Params = Params(),
                           name: String,
                           data: Data,
                           fileName: String,
                           mimeType: String) -> Promise<JSON> {
        let r = putMultipartRequest(url, params:params, name:name, data: data, fileName: fileName, mimeType: mimeType)
        return r.fetch().resolveOnMainThread()
    }
    
}

public extension Promise {
    
    public func resolveOnMainThread() -> Promise<T> {
        return Promise<T> { resolve, reject, progress in
            self.progress { p in
                DispatchQueue.main.async {
                    progress(p)
                }
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
