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

public enum WSLogLevel {
    case None
    case Calls
    case CallsAndResponses
}

var kWSJsonParsingSingleResourceKey:String? = nil
var kWSJsonParsingColletionKey:String? = nil

public class WS {
    
    public var logLevels = WSLogLevel.None
    
    public var jsonParsingSingleResourceKey:String? = nil {
        didSet {
            kWSJsonParsingSingleResourceKey = jsonParsingSingleResourceKey
        }
    }
    public var jsonParsingColletionKey:String? = nil {
        didSet {
            kWSJsonParsingColletionKey = jsonParsingColletionKey
        }
    }
    
    public init(_ aBaseURL:String) {
        baseURL = aBaseURL
    }
    
    public var baseURL = ""
    public var OAuthToken: String?
    
    public func getRequest(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> WSCall {
        return call(url, verb: .GET, params: params)
    }
    
    public func putRequest(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> WSCall {
        return call(url, verb: .PUT, params: params)
    }
    
    public func postRequest(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> WSCall {
        return call(url, verb: .POST, params: params)
    }
    
    public func deleteRequest(url:String) -> WSCall {
        return call(url, verb: .DELETE)
    }
    
    private func call(url:String, verb:HTTPVerb = .GET, params:[String:AnyObject] = [String:AnyObject]()) -> WSCall {
        let c = defaultCall()
        c.httpVerb = verb
        c.URL = url
        c.params = params
        c.returnsJSON = verb != .DELETE
        return c
    }
    
    public func defaultCall() -> WSCall {
        let r = WSCall()
        r.baseURL = baseURL
        r.logLevels = logLevels
        if let token = OAuthToken {
            r.OAuthToken = token
        }
        return r
    }
    
    //MARK: - GET
    
    
    public func get<T:protocol<ArrowParsable,RestResource>>(restResource:T, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<T> {
        return get(restURL(restResource), params: params)
    }
    
    public func get<T:ArrowParsable>(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<T> {
        return resourceCall(.GET, url: url, params: params)
    }
    
    public func get<T:protocol<ArrowParsable,RestResource>>(restResource:T, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<Void> {
        return get(restURL(restResource), params: params).then { _ -> Void in }
    }
    
    public func get(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<JSON> {
        let r = getRequest(url, params: params)
        return r.fetch()
    }
    
    public func get<T:ArrowParsable>(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<[T]> {
        let c = defaultCall()
        c.httpVerb = .GET
        c.URL = url
        c.params = params
        // Apply corresponding JSON mapper
        return c.fetch().then { json -> [T] in
            let mapper = ModelJSONParser<T>()
            let models = mapper.toModels(json)
            return models
        }
    }
    
    // Keep here for now for backwards compatibility
    @available(*, deprecated=1.2.1, message="Use 'get' instead") public func list<T:ArrowParsable>(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<[T]> {
        let c = defaultCall()
        c.httpVerb = .GET
        c.URL = url
        c.params = params
        // Apply corresponding JSON mapper
        return c.fetch().then { json -> [T] in
            let mapper = ModelJSONParser<T>()
            let models = mapper.toModels(json)
            return models
        }
    }
    
    //MARK: - POST
    
    public func post<T:protocol<ArrowParsable,RestResource>>(restResource:T, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<T> {
        return post(restURL(restResource), params: params)
    }
    
    public func post<T:ArrowParsable>(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<T> {
        return resourceCall(.POST, url: url, params: params)
    }
    
    public func post<T:protocol<ArrowParsable,RestResource>>(restResource:T, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<Void> {
        return post(restURL(restResource), params: params)
    }
    
    public func post(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<Void> {
        let r = postRequest(url, params: params)
        r.returnsJSON = false
        return r.fetch().then { json -> Void in }
    }
    
    //MARK: - PUT
    
    public func put<T:protocol<ArrowParsable,RestResource>>(restResource:T, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<T> {
        return put(restURL(restResource), params: params)
    }
    
    public func put<T:ArrowParsable>(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<T> {
        return resourceCall(.PUT, url: url, params: params)
    }
    
    public func put<T:protocol<ArrowParsable,RestResource>>(restResource:T, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<Void> {
        return put(restURL(restResource), params: params)
    }
    
    public func put(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<Void> {
        let r = putRequest(url, params: params)
        r.returnsJSON = false
        return r.fetch().then { _ -> Void in }
    }
    
    //MARK: - DELETE
    
    // auto find resource url + auto give good promise back
    public func delete<T:protocol<ArrowParsable,RestResource>>(restResource:T) -> Promise<T> {
        return delete(restURL(restResource))
    }
    
    // auto give good promise back
    public func delete<T:ArrowParsable>(url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<T> {
        return resourceCall(.DELETE, url: url, params: params)
    }

    public func delete<T:protocol<ArrowParsable,RestResource>>(restResource:T) -> Promise<Void> {
        return delete(restURL(restResource))
    }
    
    public func delete(url:String) -> Promise<Void> {
        return deleteRequest(url).fetch().then { _ -> Void in }
    }
    
    private func resourceCall<T:ArrowParsable>(verb:HTTPVerb = .GET, url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<T> {
        let c = defaultCall()
        c.httpVerb = verb
        c.URL = url
        c.params = params
        c.returnsJSON = verb != .DELETE
        
        // Apply corresponding JSON mapper
        return c.fetch().then { json -> T in
            let mapper = ModelJSONParser<T>()
            let model = mapper.toModel(json)
            return model
        }
    }
}

public class WSCall {
    
    public var baseURL = ""
    public var URL = ""
    public var httpVerb = HTTPVerb.GET
    public var params = [String:AnyObject]()
    public var returnsJSON = true
    public var OAuthToken: String?
    public var fullURL:String { return baseURL + URL}
    public var timeout:NSTimeInterval?
    public var logLevels = WSLogLevel.None
    private var req:Alamofire.Request?
    public init() {}
    
    public func cancel() {
        req?.cancel()
    }
    
    func buildRequest() -> NSMutableURLRequest {
        let url = NSURL(string: fullURL)!
        let r = NSMutableURLRequest(URL: url)
        r.HTTPMethod = httpVerb.rawValue
        if let token = OAuthToken {
            r.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Test without bearer
            if logLevels != .None {
                print("TOKEN :\(token)")
            }
        }
        if let t = self.timeout {
            r.timeoutInterval = t
        }
        return ParameterEncoding.URL.encode(r, parameters: params).0
    }
    
    public func fetch() -> Promise<JSON> {
        return Promise<JSON> { resolve, reject in
            if self.logLevels != .None {
                print("\(self.httpVerb) \(self.URL)")
                print("params : \(self.params)")
            }
            self.req = request(self.buildRequest())
            if !self.returnsJSON {
                self.req?.validate().response(completionHandler: { req, response, data, error in
                    if self.logLevels == .CallsAndResponses {
                        if let sc = response?.statusCode {
                            print("CODE: \(sc)")
                        }
                    }
                    if error == nil {
                        resolve(result: "")
                    } else {
                        reject(error:WSError.NetworkError)
                    }
                })
            } else {
                self.req?.validate().responseJSON(completionHandler: { (response) -> Void in
                    if self.logLevels == .CallsAndResponses {
                        if let sc = response.response?.statusCode {
                            print("CODE: \(sc)")
                        }
                    }
                    switch response.result {
                    case .Success(let value):
                        if self.logLevels == .CallsAndResponses {
                            print(value)
                        }
                        resolve(result: value)
                    case .Failure(_):
                        if let sc = response.response?.statusCode {
                            switch sc {
                            case 401:
                                reject(error:WSError.UnauthorizedError)
                            case 404:
                                reject(error:WSError.NotFoundError)
                            default:
                                reject(error:WSError.NetworkError)
                            }
                        } else {
                            reject(error:WSError.NetworkError)
                        }
                    }
                })
            }
        }
    }
    
    func methodForHTTPVerb(verb:HTTPVerb) -> Alamofire.Method {
        switch verb {
        case .GET : return Method.GET
        case .POST : return Method.POST
        case .PUT : return  Method.PUT
        case .DELETE : return Method.DELETE
        }
    }
}


// MARK: - Parser

public class ModelJSONParser<T:ArrowParsable> {
    
    public init() { }
    
    public func toModel(json:JSON) -> T {
        return resourceParsingBlock(json)!
    }
    
    public func toModels(json:JSON) -> [T] {
        if let resources = resourcesParsingBlock(json) {
            return resources
        } else {
            return [T]()
        }
    }
    
    private func resourcesParsingBlock(data: AnyObject) -> [T]? {
        var array = [T]()
        if let collection = collectionFromData(data) {
            for json in collection {
                if let o:T = resourceParsingBlock(json) {
                    array.append(o)
                } else {
                    return nil
                }
            }
            return array
        } else {
            return nil
        }
    }
    
    private func resourceParsingBlock(data: AnyObject) -> T? {
        if let resourceKey = resourceKeyFromData(data) {
            return T(json: resourceKey)
        } else {
            return nil
        }
    }
    
    private let resourceKeyFromData = { (data: AnyObject) -> AnyObject? in
        if let k = kWSJsonParsingSingleResourceKey {
            var r: AnyObject = data
            r <-- data[k]
            return r
        } else {
            return data
        }
    }
    
    private let collectionFromData = { (data: AnyObject) -> [AnyObject]? in
        if let k = kWSJsonParsingColletionKey {
            var c:[AnyObject]? = [AnyObject]()
            c <-- data[k]
            return c
        } else if let a = data as? [AnyObject] {
            return a
        } else {
            return nil
        }
    }
}

public enum HTTPVerb:String {
    case GET = "GET"
    case PUT = "PUT"
    case POST = "POST"
    case DELETE = "DELETE"
}

public enum WSError:ErrorType {
    case DefaultError
    case NetworkError
    case UnauthorizedError
    case NotFoundError
}


// Abstract Model -> Rest URL

public func restURL<T:RestResource>(r:T) -> String {
    return "/\(T.restName())/\(r.restId())"
}

public protocol RestResource {
    static func restName() -> String
    func restId() -> String
}
