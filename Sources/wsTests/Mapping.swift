//
//  Mapping.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 13/04/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Arrow

extension User: ArrowParsable {
    mutating func deserialize(_ json: JSON) {        
        identifier <-- json["id"]
        username <-- json["username"]
        email <-- json["email"]
        name <-- json["name"]
        phone <-- json["phone"]
        website <-- json["website"]
        company <-- json["company"]
        address <-- json["address"]
        
    }
}

extension Company: ArrowParsable {
    mutating func deserialize(_ json: JSON) {
        bs <-- json["bs"]
        catchPhrase <-- json["catchPhrase"]
        name <-- json["name"]
    }
}

extension Address: ArrowParsable {
    mutating func deserialize(_ json: JSON) {
        city <-- json["city"]
        street <-- json["street"]
        zipcode <-- json["zipcode"]
        suite <-- json["suite"]
        geo <-- json["geo"]
    }
}

extension Geo: ArrowParsable {
    mutating func deserialize(_ json: JSON) {
        lat <-- json["lat"]
        lng <-- json["lng"]
    }
}
