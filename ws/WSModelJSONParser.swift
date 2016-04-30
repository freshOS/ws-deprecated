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
    
    private func resourcesParsingBlock(json: JSON) -> [T]? {
        var array = [T]()
        let collection = collectionFrom(json)
    
        if let a = collection.data as? [AnyObject] {
            for jsonEntry in a {
                if let jsonPart = JSON(jsonEntry), o:T = resourceParsingBlock(jsonPart) {
                    array.append(o)
                } else {
                    return nil
                }
            }
            return array
        }
        return nil
    }
    
    private func resourceParsingBlock(json: JSON) -> T? {
        let resourceKey = resourceKeyFromData(json)
        var t = T()
        t.deserialize(resourceKey)
        return t
    }
    
    private let resourceKeyFromData = { (json: JSON) -> JSON in
        if let k = kWSJsonParsingSingleResourceKey, j = json[k] {
            return j
        }
        return json
    }
    
    private func collectionFrom(json: JSON) -> JSON {
        if let k = kWSJsonParsingColletionKey, j = json[k] {
            return j
        }
        return json
    }
}