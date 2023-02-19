//
//  BoundTests.swift
//  MorningBearKitTests
//
//  Created by Young Bin on 2023/02/17.
//  Copyright © 2023 com.dache. All rights reserved.
//

import XCTest

@testable import MorningBearKit

final class BoundTests: XCTestCase {
    @HotBound var mockBound: Int!

    override func setUpWithError() throws {
        mockBound = 0
    }

    override func tearDownWithError() throws {
        mockBound = nil
    }

    func testAtomic() throws {
        let concurrentQueue = DispatchQueue(label: "concurrent.test", attributes: .concurrent)
        
        XCTAssertEqual(mockBound, 0)
        // It can resist a small amount of stress
        // but should aware that it doesn't ensure 100% success rate
        var expectations = [XCTestExpectation]()
        mockBound = 0
        
        let `repeat` = 10
        for _ in 0..<`repeat` {
            let expectation = XCTestExpectation(description: "wait until finishes")
            
            concurrentQueue.async {
                self.mockBound += 1
                expectation.fulfill()
            }
            
            expectations.append(expectation)
        }
        
        wait(for: expectations, timeout: 5)
        XCTAssertEqual(mockBound, `repeat`)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
