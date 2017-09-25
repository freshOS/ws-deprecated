//
//  WSRequest.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 06/04/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Alamofire
import Arrow
import Foundation
import then

open class WSRequest {
   
    var isMultipart = false
    var multipartData = Data()
    var multipartName = ""
    var multipartFileName = "photo.jpg"
    var multipartMimeType = "image/jpeg"
    
    open var baseURL = ""
    open var URL = ""
    open var httpVerb = WSHTTPVerb.get
    open var params = [String: Any]()
    open var returnsJSON = true
    open var headers = [String: String]()
    open var fullURL: String { return baseURL + URL }
    open var timeout: TimeInterval?
    open var logLevels: WSLogLevel {
        get { return logger.logLevels }
        set { logger.logLevels = newValue }
    }
    open var postParameterEncoding: ParameterEncoding = URLEncoding()
    open var showsNetworkActivityIndicator = true
    open var errorHandler: ((JSON) -> Error?)?
    
    private let logger = WSLogger()
    
    fileprivate var req: DataRequest?//Alamofire.Request?
    
    public init() {}
    
    open func cancel() {
        req?.cancel()
    }
    
    func buildRequest() -> URLRequest {
        let url = Foundation.URL(string: fullURL)!
        var r = URLRequest(url: url)
        r.httpMethod = httpVerb.rawValue
        for (key, value) in headers {
            r.setValue(value, forHTTPHeaderField: key)
        }
        if let t = timeout {
            r.timeoutInterval = t
        }
        
        var request: URLRequest?
        if httpVerb == .post || httpVerb == .put {
            request = try? postParameterEncoding.encode(r, with: params)
        } else {
            request = try? URLEncoding.default.encode(r, with: params)
        }
        return request ?? r
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
                    WSNetworkIndicator.shared.startRequest()
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
    
    func sendMultipartRequest(_ resolve: @escaping (_ result: (Int, [AnyHashable: Any], JSON)) -> Void,
                              reject: @escaping (_ error: Error) -> Void,
                              progress:@escaping (Float) -> Void) {
        upload(multipartFormData: { formData in
            for (key, value) in self.params {
                let str: String
                switch value {
                case let opt as Any?:
                    if let v = opt {
                        str = "\(v)"
                    } else {
                        continue
                    }
                default:
                    str = "\(value)"
                }
                if let data = str.data(using: .utf8) {
                    formData.append(data, withName: key)
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
                    self.handleJSONResponse(r, resolve: resolve, reject: reject)
                }
            case .failure: ()
            }
        }
        logger.logMultipartRequest(self)
    }
    
    func sendRequest(_ resolve:@escaping (_ result: (Int, [AnyHashable: Any], JSON)) -> Void,
                     reject: @escaping (_ error: Error) -> Void) {
        self.req = request(self.buildRequest())
        logger.logRequest(self.req!)
        let bgQueue = DispatchQueue.global(qos:DispatchQoS.QoSClass.default)
        req?.validate().response(queue: bgQueue) { response in
            WSNetworkIndicator.shared.stopRequest()
            self.logger.logResponse(response)
            if response.error == nil {
                resolve((response.response?.statusCode ?? 0,
                         response.response?.allHeaderFields ?? [:], JSON(1 as AnyObject)!))
            } else {
                self.rejectCallWithMatchingError(response.response, data: response.data, reject: reject)
            }
        }
    }
    
    func sendJSONRequest(_ resolve: @escaping (_ result: (Int, [AnyHashable: Any], JSON)) -> Void,
                         reject: @escaping (_ error: Error) -> Void) {
        self.req = request(self.buildRequest())
        logger.logRequest(self.req!)
        let bgQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
        req?.validate().responseJSON(queue: bgQueue) { r in
            self.handleJSONResponse(r, resolve: resolve, reject: reject)
        }
    }
    
    func handleJSONResponse(_ response: DataResponse<Any>,
                            resolve: (_ result: (Int, [AnyHashable: Any], JSON)) -> Void,
                            reject: (_ error: Error) -> Void) {
        WSNetworkIndicator.shared.stopRequest()
        logger.logResponse(response)
        switch response.result {
        case .success(let value):
            if let json: JSON = JSON(value as AnyObject?) {
                if let error = errorHandler?(json) {
                    reject(error)
                    return
                }
                resolve((response.response?.statusCode ?? 0, response.response?.allHeaderFields ?? [:], json))
            } else {
                rejectCallWithMatchingError(response.response, data:response.data, reject: reject)
            }
        case .failure:
            rejectCallWithMatchingError(response.response, data:response.data, reject: reject)
        }
    }
    
    func rejectCallWithMatchingError(_ response: HTTPURLResponse?,
                                     data: Data? = nil,
                                     reject: (_ error: Error) -> Void) {
        var error = WSError(httpStatusCode: response?.statusCode ?? 0)
        if let d = data,
            let json = try? JSONSerialization.jsonObject(with: d,
                                                         options: JSONSerialization.ReadingOptions.allowFragments),
            let j = JSON(json as AnyObject?) {
            error.jsonPayload = j
        }
        reject(error as Error)
    }
    
    func methodForHTTPVerb(_ verb: WSHTTPVerb) -> HTTPMethod {
        switch verb {
        case .get:
            return .get
        case .post:
            return .post
        case .put:
            return  .put
        case .delete:
            return .delete
        }
    }
}
