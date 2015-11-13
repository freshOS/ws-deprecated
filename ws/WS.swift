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

class WS {
    
    init(_ aBaseURL:String) {
        baseURL = aBaseURL
    }
    
    var baseURL = ""
    var OAuthToken: String?
    
    //MARK: - Call building helpers
    
    func call() -> WSCall {
        let r = WSCall()
        r.baseURL = baseURL
        if let token = OAuthToken {
            r.OAuthToken = token
        }
        return r
    }
    
    
    func call(url:String, verb:HTTPVerb = .GET, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<JSON> {
        let c = call()
        c.httpVerb = verb
        c.URL = url
        c.params = params
        c.returnsJSON = verb != .DELETE
        return c.fetch()
    }
    
    func call(verb:HTTPVerb = .GET, url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<JSON> {
        let c = call()
        c.httpVerb = verb
        c.URL = url
        c.params = params
        c.returnsJSON = verb != .DELETE
        return c.fetch()
    }
    
    func Call<T:ArrowParsable>(verb:HTTPVerb = .GET, url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<T> {
        let c = call()
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
    
    
    func resourceCall<T:ArrowParsable>(verb:HTTPVerb = .GET, url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<T> {
        let c = call()
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
    
    func resourcesCall<T:ArrowParsable>(verb:HTTPVerb = .GET, url:String, params:[String:AnyObject] = [String:AnyObject]()) -> Promise<[T]> {
        let c = call()
        c.httpVerb = verb
        c.URL = url
        c.params = params
        c.returnsJSON = verb != .DELETE
        
        // Apply corresponding JSON mapper
        return c.fetch().then { json -> [T] in
            let mapper = ModelJSONParser<T>()
            let models = mapper.toModels(json)
            return models
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
    
    
    public func fetch() -> Promise<JSON> {
        return Promise<JSON> { resolve, reject in
            // Add Authorization Token when available.
            var headers:[String:String]? = nil
            if let token = self.OAuthToken {
                headers = ["Authorization" : "Bearer \(token)" ]
            }
            
            print("\(self.httpVerb) \(self.URL)")
            print("params : \(self.params)")
            
            let req = request(self.methodForHTTPVerb(self.httpVerb), self.fullURL, parameters: self.params, encoding: ParameterEncoding.URL, headers: headers)
            if !self.returnsJSON {
                req.validate().response(completionHandler: { req, response, data, error in
                    if let sc = response?.statusCode {
                        print("CODE: \(sc)")
                    }
                    if error == nil {
                        resolve(object: "")
                    } else {
                        reject(err:WSError.NetworkError)
                    }
                })
            } else {
                req.validate()
                req.validate().responseJSON { response in
//                    if let JSON = response.result.value {
//                         resolve(object: JSON)
//                    } else {
//                        reject(err:WSError.NetworkError)
//                    }
//                    //TODO handle error
                    switch response.result {
                    case .Success(let value):
                        resolve(object: value)
                    case .Failure(let error):
                        reject(err:error)
                    }
                }
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


class ModelJSONParser<T:ArrowParsable> {
    
    func toModel(json:JSON) -> T {
        return resourceParsingBlock(json)!
    }
    
    func toModels(json:JSON) -> [T] {
        return resourcesParsingBlock(json)!
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
        let resourceKey = resourceKeyFromData(data)
        return T(json: resourceKey)
    }
    
    private let resourceKeyFromData = { (data: AnyObject) -> AnyObject in
        var r: AnyObject = data
        r <-- data["resource"]
        return r
    }
    
    private let collectionFromData = { (data: AnyObject) -> [AnyObject]? in
//        var c:[AnyObject]? = [AnyObject]()
//        c <-- data["collection"]
//        return c
        if let a = data as? [AnyObject] {
            return a
        } else {
            return nil
        }
    }
}


public enum HTTPVerb {
    case GET
    case PUT
    case POST
    case DELETE
}