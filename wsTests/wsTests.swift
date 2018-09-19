//
//  wsTests.swift
//  wsTests
//
//  Created by Sacha Durand Saint Omer on 13/11/15.
//  Copyright © 2015 s4cha. All rights reserved.
//

import Alamofire
import Arrow
import then
@testable import ws
import XCTest

// MARK: - Models

struct User {
    var identifier = 0
    var username = ""
    var email = ""
    var name = ""
    var phone = ""
    var website: NSURL?
    var company = Company()
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

// MARK: - Usage

class WSTests: XCTestCase {
    
    var ws: WS!
    
    override func setUp() {
        super.setUp()
        // Create webservice with base URL
        ws = WS("http://jsonplaceholder.typicode.com")
        ws.logLevels = .debug
        ws.postParameterEncoding = JSONEncoding.default
        ws.showsNetworkActivityIndicator = false
    }
    
    func testJSON() {
        let exp = expectation(description: "")
        
        // use "call" to get back a json
        ws.get("/users").then { (_: JSON) in
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
        ws.getRequest("/users").fetch().then { (statusCode, _, _) in
            XCTAssertEqual(statusCode, 200)
            exp.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testMultipart() {
        let exp = expectation(description: "")
        let wsFileIO = WS("https://file.io")
        wsFileIO.logLevels = .debug
        wsFileIO.postParameterEncoding = JSONEncoding.default
        wsFileIO.showsNetworkActivityIndicator = false
        
        let imgPath = Bundle(for: type(of: self)).path(forResource: "1px", ofType: "jpg")
        let img = UIImage(contentsOfFile: imgPath!)
        let data = img!.jpegData(compressionQuality: 1.0)!
        
        wsFileIO.postMultipart("", name: "file", data: data, fileName: "file", mimeType: "image/jpeg").then { _ in
            exp.fulfill()
        }.onError { _ in
            XCTFail("Posting multipart Fails")
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    // Here is typically how you would define an api endpoint.
    // aka latestUsers is a GET on /users and I should get back User objects
    func latestUsers() -> Promise<[User]> {
        return ws.get("/users")
    }
    
    func testResolveOnMainThreadWorks() {
        let thenExp = expectation(description: "test")
        let finallyExp = expectation(description: "test")
        
        func fetch() -> Promise<String> {
            return Promise { resolve, _ in
                resolve("Hello")
            }
        }
        
        fetch()
            .resolveOnMainThread()
            .then { data in
                print(data)
                thenExp.fulfill()
            }.onError { error in
                print(error)
            }.finally {
                finallyExp.fulfill()
            }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
