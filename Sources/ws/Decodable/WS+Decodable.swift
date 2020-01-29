////
////  File.swift
////  
////
////  Created by Sacha DSO on 28/01/2020.
////
//
import Foundation
import Combine

open class WSModelJSONParser<T> {
    
    public init() {}
    
    private func isKeyPath(_ key: String) -> Bool {
        return key.split {$0 == "."}.count > 1
    }
    
    func resourceDataZ(from wsJSON: WSJSON, keypath: String?) -> WSJSON {
        if let kp = keypath {
            if isKeyPath(kp) {
                if let p = parseKeyPath(from: wsJSON, keyPath: kp) {
                    return p
                }
            } else {
                if let p = regularParsing(from: wsJSON, key: kp) {
                    return p
                }
            }
        }
        return wsJSON
    
//        if let json = wsJSON as? [String: AnyObject],
//            let k = keypath, !k.isEmpty,
//            let j = json[k] {
//            return j
//        }
//        return wsJSON
    }
//    
    func regularParsing(from wsJSON: WSJSON, key: String) -> WSJSON? {
        guard let d = wsJSON as? [String: Any], let x = d[key] else {
            return nil
        }
        return x
    }
    
    func parseKeyPath(from wsJSON: WSJSON, keyPath: String) -> WSJSON? {
        var intermediateValue = wsJSON
        for k in keysForKeyPath(keyPath) {
            if !tryParseJSONKeyPathKey(k, intermediateValue: &intermediateValue) {
                return nil
            }
        }
        return intermediateValue
    }
    
    func keysForKeyPath(_ keyPath: String) -> [String] {
        return keyPath.split {$0 == "."}.map(String.init)
    }
    
    func tryParseJSONKeyPathKey(_ key: String, intermediateValue: inout WSJSON) -> Bool {
        if let ik = Int(key), let dic = intermediateValue as? [AnyObject] { // Array index
             let value = dic[ik]
            intermediateValue = value
        } else if let dic = intermediateValue as? [String: AnyObject]  { // Key
            intermediateValue = dic[key] ?? intermediateValue
        } else {
            return false
        }
        return true
    }
}
//
//
//
public extension WS {
    
    func get<T: Decodable>(_ url: String, params: Params = Params(), keypath: String? = nil) -> WSCall<T> {
        return typeCall(.get, url: url, params: params, keypath: keypath)
    }
    
    func getList<T: Decodable> (_ url: String, params: Params = Params(), keypath: String? = nil) -> WSCall<[T]> {
        let keypath = keypath ?? defaultCollectionParsingKeyPath
        let req = getRequest(url, params: params)
        return req.fetch().map { (json:WSJSON) in
            return WSModelJSONParser<T>().toModels(json, keypath: keypath)
        }.eraseToAnyPublisher()
    }
}

extension WS {
    
    private func typeCall<T: Decodable>(_ verb: WSHTTPVerb,
                                                 url: String, params: Params = Params(),
                                                 keypath: String? = nil) -> WSCall<T> {
        let c = defaultCall()
        c.httpVerb = verb
        c.URL = url
        c.params = params
        
        // Apply corresponding JSON mapper
        return c.fetch().tryMap { (json:WSJSON) -> T in
            if let t: T = WSModelJSONParser<T>().toModel(json, keypath: keypath) {
                return t
            } else {
                throw WSError.unableToParseResponse
            }
        }.eraseToAnyPublisher().receiveOnMainThread()
    }
}


extension WSModelJSONParser where T: Decodable {
    
    open func toModel(_ wsJSON: WSJSON, keypath: String? = nil) -> T? {
        let subJSON = resourceDataZ(from: wsJSON, keypath: keypath)
        if let type = subJSON as? T {
            return type
        }
        
        if let str = subJSON as? String {
            let decoder = JSONDecoder()
             if let jsonData = str.data(using: .utf8), let t = try? decoder.decode(T.self, from: jsonData) {
                 return t
             } else {
                 return nil
             }
        }
        
        if let arr = subJSON as? NSArray {
            
        }
        
        let decoder = JSONDecoder()
        let jsonData = subJSON as! Data
        if let t = try? decoder.decode(T.self, from: jsonData) {
            return t
        } else {
            return nil
        }
    }
 
    open func toModels(_ wsJSON: WSJSON, keypath: String? = nil) -> [T] {
        let arrayJSON = resourceDataZ(from: wsJSON, keypath: keypath)
        if let array = arrayJSON as? [WSJSON] {
            let models = array.map { (jsonObject:WSJSON) -> T in
                let decoder = JSONDecoder()
                let t = try! decoder.decode(T.self, from: jsonObject as! Data)
                return t
            }
        }
        return [T]()
    }
}
        
////
////        return array.map { resource(from: $0) }
////
////
////        let decoder = JSONDecoder()
////        //        print(json)
////        //        let t: T = try! decoder.decode(T.self, from: json as! Data)
////        //        return t
////
////        return [T].init(resourceData(from: arrowJSON, keypath: keypath))
//    }
//    
////    private func resource(from json: WSJSON) -> T {
////        let decoder = JSONDecoder()
////        print(json)
////        let t: T = try! decoder.decode(T.self, from: json as! Data)
////        return t
////    }
//}
