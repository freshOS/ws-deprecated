//
//  wsTests.swift
//  wsTests
//
//  Created by Sacha Durand Saint Omer on 13/11/15.
//  Copyright © 2015 s4cha. All rights reserved.
//

import XCTest
@testable import ws
import then
import Arrow
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

extension User:RestResource {
    static func restName() -> String { return "users" }
    func restId() -> String { return "\(identifier)" }
}

// MARK: - Usage

class wsTests: XCTestCase {
    
    var ws:WS!
    
    override func setUp() {
        super.setUp()
        // Create webservice with base URL
        ws = WS("http://jsonplaceholder.typicode.com")
        ws.logLevels = .callsAndResponses
        ws.postParameterEncoding = .json
        ws.showsNetworkActivityIndicator = false
    }
    
    func testJSON() {
        let exp = expectation(description: "")
        
        // use "call" to get back a json
        ws.get("/users").then { (json:JSON) in
            exp.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testModels() {
        let exp = expectation(description: "")
        latestUsers().then { users in
            XCTAssertEqual(users.count, 10)
            
            let u = users[0]
            XCTAssertEqual(u.identifier, 1)
            exp.fulfill()
            
            print(users)
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testResponse() {
        let exp = expectation(description: "")
        ws.getRequest("/users").fetch().then { (statusCode, responseHeaders, json) in
            XCTAssertEqual(statusCode, 200)
            exp.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    // Here is typically how you would define an api endpoint.
    // aka latestUsers is a GET on /users and I should get back User objects
    func latestUsers() -> Promise<[User]> {
        return ws.get("/users")
    }
    
}
