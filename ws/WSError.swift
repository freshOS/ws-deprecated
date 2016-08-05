//
//  WSError.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 06/04/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation
import Arrow

public enum WSErrorType:Int {
    case NetworkUnreachable = 0
    case Forbidden = 403
    case Unauthorized = 401
    case NotFound = 404
    case Unknown
}

public struct WSError:ErrorType {
    public var httpStatusCode = 0
    public var type:WSErrorType = .Unknown
    public var jsonPayload:JSON?
}