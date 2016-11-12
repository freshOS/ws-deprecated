//
//  WSModelJSONParser.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 06/04/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation
import Arrow


var kWSDefaultCollectionParsingKeyPath:String? = nil

open class WSModelJSONParser<T:ArrowParsable> {
    
    public init() { }
    
    open func toModel(_ json: JSON) -> T {
        return resource(from: json)
    }
    
    open func toModels(_ json: JSON) -> [T] {
        if let k = kWSDefaultCollectionParsingKeyPath, let j = json[k], let array = j.collection {
            return array.map { resource(from: $0) }
        }
        guard let array = json.collection else {
            return [T]()
        }
        return array.map { resource(from: $0) }
    }
    
    private func resource(from json: JSON) -> T {
        var t = T()
        t.deserialize(json)
        return t
    }
}
