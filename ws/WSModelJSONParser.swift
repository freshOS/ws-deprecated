//
//  WSModelJSONParser.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 06/04/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation
import Arrow

public class WSModelJSONParser<T:ArrowParsable> {
    
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
            var t = T()
            if let json = JSON(resourceKey) {
                t.deserialize(json)
            }
            return t
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
        } else if let a = data as? JSON {
            if let array = a.data as? [AnyObject] {
                return array
            }
            return [""]
        } else {
            return nil
        }
    }
}