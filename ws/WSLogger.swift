//
//  WSLogger.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 13/11/2016.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation
import Alamofire


public enum WSLogLevel {
    case none
    case calls
    case callsAndResponses
}


class WSLogger {
    
    var logLevels = WSLogLevel.none
    
    func logMultipartRequest(_ request:WSRequest) {
        if logLevels != .none {
            print("\(request.httpVerb.rawValue.uppercased()) \(request.URL)")
            print("  params : \(request.params)")
            
            for (k,v) in request.headers {
                print("  \(k) : \(v)")
            }
            print("  name : \(request.multipartName), mimeType: \(request.multipartMimeType), filename: \(request.multipartFileName)")
            print("\n")
        }
    }
    
    func logRequest(_ request:DataRequest) {
        if logLevels != .none {
            if let urlRequest = request.request,
                let verb = urlRequest.httpMethod,
                let url = urlRequest.url {
                if let query = url.query {
                    print("\(verb) \(url.path)?\(query)")
                } else {
                    print("\(verb) \(url.path)")
                }
                logHeaders(urlRequest)
                logBody(urlRequest)
                print("\n")
            }
        }
    }
    
    func logResponse(_ response:DefaultDataResponse) {
        if logLevels != .none {
            logStatusCodeAndURL(response.response)
        }
        print("\n")
    }
    
    func logResponse(_ response:DataResponse<Any>) {
        if logLevels != .none {
            logStatusCodeAndURL(response.response)
        }
        if logLevels == .callsAndResponses {
            switch response.result {
            case .success(let value): print(value)
            case .failure(let error): print(error)
            }
        }
        print("\n")
    }
    
    private func logHeaders(_ urlRequest:URLRequest) {
        if let allHTTPHeaderFields = urlRequest.allHTTPHeaderFields {
            for (k,v) in allHTTPHeaderFields {
                print("  \(k) : \(v)")
            }
        }
    }
    
    private func logBody(_ urlRequest:URLRequest) {
        if let body = urlRequest.httpBody,
            let str = String(data:body, encoding: .utf8) {
            print(  "HttpBody : \(str)")
        }
    }
    
    private func logStatusCodeAndURL(_ urlResponse:HTTPURLResponse?) {
        if let urlResponse = urlResponse, let url = urlResponse.url {
            if let query = url.query {
                print("\(urlResponse.statusCode) \(url.path)?\(query)")
            } else {
                print("\(urlResponse.statusCode) \(url.path)")
            }
        }
    }
}
