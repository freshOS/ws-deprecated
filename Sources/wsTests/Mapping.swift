//
//  Mapping.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 13/04/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation
import Arrow

//extension Collection: ArrowParsable where Self.Element: ArrowParsable {
//    
//}

extension User: Decodable {
    
    init(from decoder: Decoder) throws {
        identifier = 0
        username = ""
        email = ""
        name = ""
        phone = ""
        website = NSURL(string:"http://")
        company = Company()
        address = Address()
    }
}

extension FooBar: Decodable {
    
    init(from decoder: Decoder) throws {
        print("called")
        self.init(rawValue: "")!
    }
}

extension Article: Decodable {

    init(from decoder: Decoder) throws {
        id = 12
        name = "default"
    }
//    mutating func deserialize(_ json: JSON) {
//        id <-- json["id"]
//        name <-- json["name"]
//    }
}


//extension CodableArticle: Decodable {
////    mutating func deserialize(_ json: JSON) {
////        id <-- json["id"]
////        name <-- json["name"]
////    }
//}

//enum FooBar: String {
//    case foo = "Foo"
//    case bar = "Bar"
//}
//
//extension FooBar: ArrowInitializable {}

/**
 TEST JSON:
 {
     "count": 2,
     "articles": [
         {
             "id": 1,
             "name": "Foo"
         },
         {
             "id": 2,
             "name": "Bar"
         }
     ],
     "error":
     {
         "code": 0,
         "message": "No error"
     }
 }
 */


//import Arrow
//extension User: ArrowParsable {
//    mutating func deserialize(_ json: JSON) {
//        identifier <-- json["id"]
//        username <-- json["username"]
//        email <-- json["email"]
//        name <-- json["name"]
//        phone <-- json["phone"]
//        website <-- json["website"]
//        company <-- json["company"]
//        address <-- json["address"]
//
//    }
//}

//extension Company: ArrowParsable {
//    mutating func deserialize(_ json: JSON) {
//        bs <-- json["bs"]
//        catchPhrase <-- json["catchPhrase"]
//        name <-- json["name"]
//    }
//}
//
//extension Address: ArrowParsable {
//    mutating func deserialize(_ json: JSON) {
//        city <-- json["city"]
//        street <-- json["street"]
//        zipcode <-- json["zipcode"]
//        suite <-- json["suite"]
//        geo <-- json["geo"]
//    }
//}
//
//extension Geo: ArrowParsable {
//    mutating func deserialize(_ json: JSON) {
//        lat <-- json["lat"]
//        lng <-- json["lng"]
//    }
//}
