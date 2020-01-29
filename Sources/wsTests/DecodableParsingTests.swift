//
//  File.swift
//  
//
//  Created by Sacha DSO on 28/01/2020.
//

import Foundation
import ws
import XCTest

class DecodableMappingTests: XCTestCase {
    
    var ws: WS!
    
    private let path = "581c82711000003c24ea7806"
    
    override func setUp() {
        super.setUp()
        
        ws = WS("http://www.mocky.io/v2/")
        ws.logLevels = .debug
        
//        ws.errorHandler = { wsjson in
//            if let json = JSON(wsjson), let errorPayload = json["error"] {
//                var code = 0
//                var message = ""
//                code <-- errorPayload["code"]
//                message <-- errorPayload["message"]
//                if code != 0 {
//                    return NSError(domain: "WS", code: code, userInfo: [NSLocalizedDescriptionKey: message])
//                }
//            }
//            return nil
//        }
    }
    
    func testMapping() {
        let e = expectation(description: "")

        getArticles()
            .then { articles in
                XCTAssertEqual(articles.count, 2)
                e.fulfill()
            }
            .onError { error in
                print("ERROR: \(error)")
                XCTFail("Mapping fails")
                e.fulfill()
            }

        waitForExpectations(timeout: 10, handler: nil)
    }

//    func testTypeMapping() {
//        let e = expectation(description: "")
//        getArticlesCount()
//            .then { count in
//                XCTAssertEqual(count, 2)
//                e.fulfill()
//            }
//            .onError { error in
//                print("ERROR: \(error)")
//                XCTFail("Type Mapping Fails")
//                e.fulfill()
//            }
//
//        waitForExpectations(timeout: 10, handler: nil)
//    }

    func testRawTypeMapping() {
        let e = expectation(description: "")
            
        getFooBar()
            .then { foobar in
                XCTAssertEqual(foobar, FooBar.foo)
                e.fulfill()
            }
            .onError{ error in
                print("ERROR: \(error)")
                XCTFail("Raw type mapping fails")
                e.fulfill()
            }

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func getArticles() -> WSCall<[Article]> {
        return ws.get(path, keypath: "articles")
    }
    
//    func getArticlesCount(2) -> WSCall<Int> {
//        return ws.get(path, keypath: "count")
//    }
//
    func getFooBar() -> WSCall<FooBar> {
        return ws.get(path, keypath: "articles.0.name")
    }
}

