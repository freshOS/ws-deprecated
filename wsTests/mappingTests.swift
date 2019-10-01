//
//  mappingTests.swift
//  ws
//
//  Created by Max Konovalov on 04/11/2016.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Arrow
import Then
@testable import ws
import XCTest

struct Article {
    var id: Int = 0
    var name: String = ""
}

extension Article: ArrowParsable {
    mutating func deserialize(_ json: JSON) {
        id <-- json["id"]
        name <-- json["name"]
    }
}

enum FooBar: String {
    case foo = "Foo"
    case bar = "Bar"
}

extension FooBar: ArrowInitializable {}

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

class MappingTests: XCTestCase {
    
    var ws: WS!
    
    private let path = "581c82711000003c24ea7806"
    
    override func setUp() {
        super.setUp()
        
        ws = WS("http://www.mocky.io/v2/")
        ws.logLevels = .debug
        
        ws.errorHandler = { json in
            if let errorPayload = json["error"] {
                var code = 0
                var message = ""
                code <-- errorPayload["code"]
                message <-- errorPayload["message"]
                if code != 0 {
                    return NSError(domain: "WS", code: code, userInfo: [NSLocalizedDescriptionKey: message])
                }
            }
            return nil
        }
    }
    
    func testMapping() {
        let e = expectation(description: "")
        
        getArticles()
            .then({ articles in
                XCTAssertEqual(articles.count, 2)
                e.fulfill()
            })
            .onError({ error in
                print("ERROR: \(error)")
                XCTFail("Mapping fails")
                e.fulfill()
            })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testTypeMapping() {
        let e = expectation(description: "")
        
        getArticlesCount()
            .then({ count in
                XCTAssertEqual(count, 2)
                e.fulfill()
            })
            .onError({ error in
                print("ERROR: \(error)")
                XCTFail("Type Mapping Fails")
                e.fulfill()
            })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRawTypeMapping() {
        let e = expectation(description: "")
        
        getFooBar()
            .then({ foobar in
                XCTAssertEqual(foobar, FooBar.foo)
                e.fulfill()
            })
            .onError({ error in
                print("ERROR: \(error)")
                XCTFail("Raw type mapping fails")
                e.fulfill()
            })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func getArticles() -> Promise<[Article]> {
        return ws.get(path, keypath: "articles")
    }
    
    func getArticlesCount() -> Promise<Int> {
        return ws.get(path, keypath: "count")
    }
    
    func getFooBar() -> Promise<FooBar> {
        return ws.get(path, keypath: "articles.0.name")
    }
    
}
