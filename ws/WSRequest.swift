//
//  WSRequest.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 06/04/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation
import Alamofire
import then
import Arrow

open class WSRequest {
   
    var isMultipart = false
    var multipartData = Data()
    var multipartName = ""
    var multipartFileName = "photo.jpg"
    var multipartMimeType = "image/jpeg"
    
    open var baseURL = ""
    open var URL = ""
    open var httpVerb = WSHTTPVerb.get
    open var params = [String:Any]()
    open var returnsJSON = true
    open var OAuthToken: String?
    open var headers = [String: String]()
    open var fullURL:String { return baseURL + URL}
    open var timeout:TimeInterval?
    open var logLevels = WSLogLevel.none
    open var postParameterEncoding: ParameterEncoding = URLEncoding()
    open var showsNetworkActivityIndicator = true
    fileprivate var req:DataRequest?//Alamofire.Request?
    public init() {}
    
    open func cancel() {
        req?.cancel()
    }
    
    func buildRequest() -> URLRequest {
        let url = Foundation.URL(string: fullURL)!
        var r = URLRequest(url: url)
        r.httpMethod = httpVerb.rawValue
        if let token = OAuthToken {
            r.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Test without bearer
            if logLevels != .none {
                print("TOKEN :\(token)")
            }
        }
        for (key, value) in headers {
            r.setValue(value, forHTTPHeaderField: key)
        }
        if let t = timeout {
            r.timeoutInterval = t
        }
        
        if httpVerb == .post || httpVerb == .put {
            return try! postParameterEncoding.encode(r, with: params)
        } else {
            return try! URLEncoding.default.encode(r, with: params)
        }
    }
    
    /// Returns Promise containing JSON
    open func fetch() -> Promise<JSON> {
        return fetch().registerThen { (_, _, json) in json }
    }
    
    /// Returns Promise containing response status code, headers and parsed JSON
    open func fetch() -> Promise<(Int, [AnyHashable: Any], JSON)> {
        return Promise<(Int, [AnyHashable: Any], JSON)> { resolve, reject, progress in
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                if self.showsNetworkActivityIndicator {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                }
                if self.logLevels != .none {
                    print("\(self.httpVerb) \(self.URL)")
                    print("params : \(self.params)")
                    if self.isMultipart {
                        print("\(self.multipartName): \(self.multipartMimeType) \(self.multipartFileName)")
                    }
                }
                if self.isMultipart {
                    self.sendMultipartRequest(resolve, reject: reject, progress:progress)
                } else if !self.returnsJSON {
                    self.sendRequest(resolve, reject: reject)
                } else {
                    self.sendJSONRequest(resolve, reject: reject)
                }
            }
        }
    }
    
    func sendMultipartRequest(_ resolve:@escaping (_ result:(Int, [AnyHashable: Any], JSON))-> Void, reject:@escaping (_ error: Error) -> Void, progress:@escaping (Float) -> Void) {
        upload(multipartFormData: { formData in
            for (key,value) in self.params {
                if let int = value as? Int {
                    let str = "\(int)"
                    if let d = str.data(using: String.Encoding.utf8) {
                        formData.append(d, withName: key)
                    }
                } else {
                    if let str = value as? String, let data = str.data(using: String.Encoding.utf8) {
                        formData.append(data, withName: key)
                    }
                }
            }
            formData.append(self.multipartData,
                            withName: self.multipartName,
                            fileName: self.multipartFileName,
                            mimeType: self.multipartMimeType)
        }, with: self.buildRequest()) { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress { p in
                    progress(Float(p.fractionCompleted))
                }.validate().responseJSON { r in
                    print("Upload done")
                    self.handleJSONResponse(r, resolve: resolve, reject: reject)
                }
            case .failure(_):
                print("error")
            }
        }
    }
    
    func sendRequest(_ resolve:@escaping (_ result:(Int, [AnyHashable: Any], JSON))-> Void, reject:@escaping (_ error: Error) -> Void) {
        self.req = request(self.buildRequest())
        let bgQueue = DispatchQueue.global(qos:DispatchQoS.QoSClass.default)
        req?.validate().response(queue: bgQueue) { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.printResponseStatusCodeIfNeeded(response.response)
            if response.error == nil {
                resolve((response.response?.statusCode ?? 0, response.response?.allHeaderFields ?? [:], JSON(1 as AnyObject)!))
            } else {
                self.rejectCallWithMatchingError(response.response, data: response.data, reject: reject)
            }
        }
    }
    
    func sendJSONRequest(_ resolve:@escaping (_ result:(Int, [AnyHashable: Any], JSON))-> Void, reject:@escaping (_ error: Error) -> Void) {
        self.req = request(self.buildRequest())
        let bgQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
        req?.validate().responseJSON(queue: bgQueue) { r in
            self.handleJSONResponse(r, resolve: resolve, reject: reject)
        }
    }
    
    func handleJSONResponse(_ response:DataResponse<Any>, resolve:(_ result:(Int, [AnyHashable: Any], JSON))-> Void, reject:(_ error: Error) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        printResponseStatusCodeIfNeeded(response.response)
        
        switch response.result {
        case .success(let value):
            if logLevels == .callsAndResponses {
                print(value)
            }
            if let json:JSON = JSON(value as AnyObject?) {
                resolve((response.response?.statusCode ?? 0, response.response?.allHeaderFields ?? [:], json))
            } else {
                rejectCallWithMatchingError(response.response, data:response.data, reject: reject)
            }
        case .failure(let error):
            print(error)
            rejectCallWithMatchingError(response.response, data:response.data, reject: reject)
        }
    }
    
    func printResponseStatusCodeIfNeeded(_ response:HTTPURLResponse?) {
        if logLevels == .callsAndResponses {
            if let sc = response?.statusCode {
                print("CODE: \(sc)")
            }
        }
    }
    
    func rejectCallWithMatchingError(_ response:HTTPURLResponse?, data:Data? = nil, reject:(_ error: Error) -> Void) {
        var error = WSError(httpStatusCode: response?.statusCode ?? 0)
        if let d = data,
            let json = try? JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions.allowFragments),
            let j = JSON(json as AnyObject?) {
            error.jsonPayload = j
        }
        reject(error as Error)
    }
    
    func methodForHTTPVerb(_ verb:WSHTTPVerb) -> HTTPMethod {
        switch verb {
        case .get : return .get
        case .post : return .post
        case .put : return  .put
        case .delete : return .delete
        }
    }
}
