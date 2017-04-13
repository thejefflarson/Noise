//
//  NoiseTests.swift
//  NoiseTests
//
//  Created by Jeff Larson on 4/1/17.
//  Copyright © 2017 Jeff Larson. All rights reserved.
//

import XCTest
@testable import Noise

class NoiseTests: XCTestCase {    
    func testLoad() {
        let expect = self.expectation(description: "Waiting for request.")
        let loader = Loader()
        loader.load("https://www.google.com") {_ in
            expect.fulfill()
        }
        self.waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testNoise() {
        let noise = Fetcher(["0.5\thttps://www.google.com/", "1.0\thttps://www.apple.com/"], withDelay: 1)
        noise.run()
        let expect = self.expectation(description: "Waiting for requests.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            noise.stop()
            XCTAssert(noise.bytes > 0)
            XCTAssert(noise.count > 0)
            expect.fulfill()
        })
        self.waitForExpectations(timeout: 6.0, handler: nil)
    }
}
