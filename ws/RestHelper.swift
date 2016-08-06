//
//  RestHelper.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 06/04/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation

// Abstract Model -> Rest URL

public func restURL<T:RestResource>(_ r:T) -> String {
    return "/\(T.restName())/\(r.restId())"
}

public protocol RestResource {
    static func restName() -> String
    func restId() -> String
}
