//
//  WSError.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 06/04/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation
import Arrow


public struct WSError: ErrorType {

    public enum Type: Int {
        case Unknown                        = -1
        case NetworkUnreachable             = 0
        
        // 4xx Client Error
        case BadRequest                     = 400
        case Unauthorized                   = 401
        case PaymentRequired                = 402
        case Forbidden                      = 403
        case NotFound                       = 404
        case MethodNotAllowed               = 405
        case NotAcceptable                  = 406
        case ProxyAuthenticationRequired    = 407
        case RequestTimeout                 = 408
        case Conflict                       = 409
        case Gone                           = 410
        case LengthRequired                 = 411
        case PreconditionFailed             = 412
        case PayloadTooLarge                = 413
        case URITooLong                     = 414
        case UnsupportedMediaType           = 415
        case RangeNotSatisfiable            = 416
        case ExpectationFailed              = 417
        case Teapot                         = 418
        case MisdirectedRequest             = 421
        case UnprocessableEntity            = 422
        case Locked                         = 423
        case FailedDependency               = 424
        case UpgradeRequired                = 426
        case PreconditionRequired           = 428
        case TooManyRequests                = 429
        case RequestHeaderFieldsTooLarge    = 431
        case UnavailableForLegalReasons     = 451
        
        // 4xx nginx
        case NoResponse                     = 444
        case SSLCertificateError            = 495
        case SSLCertificateRequired         = 496
        case HTTPRequestSentToHTTPSPort     = 497
        case ClientClosedRequest            = 499
        
        // 5xx Server Error
        case InternalServerError            = 500
        case NotImplemented                 = 501
        case BadGateway                     = 502
        case ServiceUnavailable             = 503
        case GatewayTimeout                 = 504
        case HTTPVersionNotSupported        = 505
        case VariantAlsoNegotiates          = 506
        case InsufficientStorage            = 507
        case LoopDetected                   = 508
        case NotExtended                    = 510
        case NetworkAuthenticationRequired  = 511
    }
    
    public var type: Type
    public var code: Int { return type.rawValue }
    
    public var jsonPayload:JSON? = nil
    
    public init(httpStatusCode: Int) {
        self.type = Type(rawValue: httpStatusCode) ?? .Unknown
    }
    
}

extension WSError: CustomStringConvertible {
    
    public var description: String {
        return String(self.type)
            .stringByReplacingOccurrencesOfString("(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])",
                                                  withString: " ", options: [.RegularExpressionSearch])
    }
    
}
