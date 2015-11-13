//
//  wsTests.swift
//  wsTests
//
//  Created by Sacha Durand Saint Omer on 13/11/15.
//  Copyright © 2015 s4cha. All rights reserved.
//

import XCTest
@testable import ws

// MARK: - Models

struct User {
    var identifier = 0
    var username = ""
    var email = ""
    var name = ""
    var phone = ""
    var website:NSURL?
    var company = Company() // TODO test optinals and forced
    var address = Address()
}

//todo Does not work when useing forced !

struct Company {
    var bs = ""
    var catchPhrase = ""
    var name = ""
}

struct Address {
    var city = ""
    var street = ""
    var suite = ""
    var zipcode = ""
    var geo = Geo()
}

struct Geo {
    var lat = ""
    var lng = ""
}


// MARK: - JSON mapping

import Arrow

extension User:ArrowParsable {
    init(json: JSON) {
        identifier <-- json["id"]
        username <-- json["username"]
        email <-- json["email"]
        name <-- json["name"]
        phone <-- json["phone"]
        
        var urlString = ""
        urlString <-- json["website"]
        website = NSURL(string: urlString)
        company <== json["company"]
        address <== json["address"]
        
    }
}

extension Company:ArrowParsable {
    init(json: JSON) {
        bs <-- json["bs"]
        catchPhrase <-- json["catchPhrase"]
        name <-- json["name"]
    }
}

extension Address:ArrowParsable {
    init(json: JSON) {
        city <-- json["city"]
        street <-- json["street"]
        zipcode <-- json["zipcode"]
        suite <-- json["suite"]
        geo <== json["geo"]
    }
}

extension Geo:ArrowParsable {
    init(json: JSON) {
        lat <-- json["lat"]
        lng <-- json["lng"]
    }
}

// MARK: - Usage

class wsTests: XCTestCase {
    
    var ws:WS!
    
    override func setUp() {
        super.setUp()
        // Create webservice with base URL
        ws = WS("http://jsonplaceholder.typicode.com")
    }
    
    func testJSON() {
        let exp = expectationWithDescription("")
        
        // use "call" to get back a json
        ws.call("/users").succeeds { json in
            print(json)
            exp.fulfill()
        }
        waitForExpectationsWithTimeout(3, handler: nil)
    }
    
    func testModels() {
        let exp = expectationWithDescription("")
        latestUsers().succeeds { users in
            for u in users {
                print(u)
            }
            exp.fulfill()
        }
        waitForExpectationsWithTimeout(3, handler: nil)
    }
    
    // Here is typically how you would define an api endpoint.
    // aka latestUsers is a GET on /users and I should get back User objects
    func latestUsers() -> Promise<[User]> {
        return ws.resourcesCall(url: "/users")
    }
    
}
