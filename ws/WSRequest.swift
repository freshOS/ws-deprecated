//
//  WSRequest.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 06/04/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation
import Alamofire
import thenPromise
import Arrow

public class WSRequest {
   
    var isMultipart = false
    var multipartData = NSData()
    var multipartName = ""
    var multipartFileName = "photo.jpg"
    var multipartMimeType = "image/jpeg"
    
    public var baseURL = ""
    public var URL = ""
    public var httpVerb = WSHTTPVerb.GET
    public var params = [String:AnyObject]()
    public var returnsJSON = true
    public var OAuthToken: String?
    public var headers = [String: String]()
    public var fullURL:String { return baseURL + URL}
    public var timeout:NSTimeInterval?
    public var logLevels = WSLogLevel.None
    public var postParameterEncoding = ParameterEncoding.URL
    public var showsNetworkActivityIndicator = true
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
        for (key, value) in headers {
            r.setValue(value, forHTTPHeaderField: key)
        }
        if let t = self.timeout {
            r.timeoutInterval = t
        }
        
        if httpVerb == .POST || httpVerb == .PUT {
            return postParameterEncoding.encode(r, parameters: params).0
        } else {
            return ParameterEncoding.URL.encode(r, parameters: params).0
        }
    }
    
    public func fetch() -> Promise<JSON> {
        return Promise<JSON> { resolve, reject, progress in
            if self.showsNetworkActivityIndicator {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            }
            if self.logLevels != .None {
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
    
    func sendMultipartRequest(resolve:(result:JSON)-> Void, reject:(error: ErrorType) -> Void, progress:(Float) -> Void) {
            upload(self.buildRequest(), multipartFormData: { (formData:MultipartFormData) -> Void in
                
                for (key,value) in self.params {
                    if let int = value as? Int {
                        let str = "\(int)"
                        if let d = str.dataUsingEncoding(NSUTF8StringEncoding) {
                            formData.appendBodyPart(data: d, name: key)
                        }
                    } else {
                        if let d = value.dataUsingEncoding(NSUTF8StringEncoding) {
                            formData.appendBodyPart(data: d, name: key)
                        }
                    }
                }

                formData.appendBodyPart(data: self.multipartData, name: self.multipartName, fileName: self.multipartFileName, mimeType: self.multipartMimeType)
                }, encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.validate().responseJSON(completionHandler: { r in
                            print("Upload done")
                            self.handleJSONResponse(r, resolve: resolve, reject: reject)
                        }).progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                            dispatch_async(dispatch_get_main_queue()) {
                                let percentage:Float = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
                                progress(percentage)
                            }
                        }
                    case .Failure(_):()
                    }
            })
    }
    
    func sendRequest(resolve:(result:JSON)-> Void, reject:(error: ErrorType) -> Void) {
        self.req = request(self.buildRequest())
        req?.validate().response(completionHandler: { req, response, data, error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.printResponseStatusCodeIfNeeded(response)
            if error == nil {
                resolve(result:JSON(["":""])!)
            } else {
                self.rejectCallWithMatchingError(response, reject: reject)
            }
        })
    }
    
    func sendJSONRequest(resolve:(result:JSON)-> Void, reject:(error: ErrorType) -> Void) {
        self.req = request(self.buildRequest())
        req?.validate().responseJSON { r in
            self.handleJSONResponse(r, resolve: resolve, reject: reject)
        }
    }
    
    func handleJSONResponse(response:Response<AnyObject, NSError>, resolve:(result:JSON)-> Void, reject:(error: ErrorType) -> Void) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.printResponseStatusCodeIfNeeded(response.response)
        switch response.result {
        case .Success(let value):
            if self.logLevels == .CallsAndResponses {
                print(value)
            }
            if let json:JSON = JSON(value) {
                resolve(result: json)
            } else {
                self.rejectCallWithMatchingError(response.response, reject: reject)
            }
        case .Failure(_):
            self.rejectCallWithMatchingError(response.response, reject: reject)
        }
    }
    
    func printResponseStatusCodeIfNeeded(response:NSHTTPURLResponse?) {
        if self.logLevels == .CallsAndResponses {
            if let sc = response?.statusCode {
                print("CODE: \(sc)")
            }
        }
    }
    
    func rejectCallWithMatchingError(response:NSHTTPURLResponse?, reject:(error: ErrorType) -> Void) {
        if let sc = response?.statusCode {
            switch sc {
            case 401:   reject(error:WSError.UnauthorizedError)
            case 404:   reject(error:WSError.NotFoundError)
            default:    reject(error:WSError.NetworkError)
            }
        } else {
            reject(error:WSError.NetworkError)
        }
    }
    
    func methodForHTTPVerb(verb:WSHTTPVerb) -> Alamofire.Method {
        switch verb {
        case .GET : return Method.GET
        case .POST : return Method.POST
        case .PUT : return  Method.PUT
        case .DELETE : return Method.DELETE
        }
    }
}
