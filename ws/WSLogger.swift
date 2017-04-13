//
//  WSLogger.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 13/11/2016.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Alamofire
import Foundation

public enum WSLogLevel {
    
    @available(*, unavailable, renamed: "off")
    case none
    @available(*, unavailable, renamed: "info")
    case calls
    @available(*, unavailable, renamed: "debug")
    case callsAndResponses
    
    case off
    case info
    case debug
}

class WSLogger {
    
    var logLevels = WSLogLevel.off
    
    func logMultipartRequest(_ request: WSRequest) {
        guard logLevels != .off else {
            return
        }
        print("\(request.httpVerb.rawValue.uppercased()) '\(request.URL)'")
        print("  params : \(request.params)")
        
        for (k, v) in request.headers {
            print("  \(k) : \(v)")
        }
        print("  name : \(request.multipartName),"
            + "mimeType: \(request.multipartMimeType), filename: \(request.multipartFileName)")
        if logLevels == .debug {
            print()
        }
    }
    
    func logRequest(_ request: DataRequest) {
        guard logLevels != .off else {
            return
        }
        if let urlRequest = request.request,
            let verb = urlRequest.httpMethod,
            let url = urlRequest.url {
            print("\(verb) '\(url.absoluteString)'")
            logHeaders(urlRequest)
            logBody(urlRequest)
            if logLevels == .debug {
                print()
            }
        }
    }
    
    func logResponse(_ response: DefaultDataResponse) {
        guard logLevels != .off else {
            return
        }
        logStatusCodeAndURL(response.response)
        if logLevels == .debug {
            print()
        }
    }
    
    func logResponse(_ response: DataResponse<Any>) {
        guard logLevels != .off else {
            return
        }
        logStatusCodeAndURL(response.response)
        if logLevels == .debug {
            switch response.result {
            case .success(let value):
                print(value)
            case .failure(let error):
                print(error)
            }
        }
        if logLevels == .debug {
            print()
        }
    }
    
    private func logHeaders(_ urlRequest: URLRequest) {
        if let allHTTPHeaderFields = urlRequest.allHTTPHeaderFields {
            for (k, v) in allHTTPHeaderFields {
                print("  \(k) : \(v)")
            }
        }
    }
    
    private func logBody(_ urlRequest: URLRequest) {
        if let body = urlRequest.httpBody,
            let str = String(data:body, encoding: .utf8) {
            print("  HttpBody : \(str)")
        }
    }
    
    private func logStatusCodeAndURL(_ urlResponse: HTTPURLResponse?) {
        if let urlResponse = urlResponse, let url = urlResponse.url {
            print("\(urlResponse.statusCode) '\(url.absoluteString)'")
        }
    }
}
