//
//  arrayTests.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/15/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import XCTest
@testable import minimind

class arrayTests: XCTestCase {
    var a: [Float] = [0.0, 1.0, 2.0, 3.0]

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testArrange() {
        let v: [Float] = arange(-2.0, 2.1, 2.0 / 3.0)
    }

    func testMath() {
        XCTAssert(all(a.cumsum() == [0.0, 1.0, 3.0, 6.0]))
        XCTAssert(a.sum() == 6.0)
        XCTAssert(a.max() == 3.0)
        XCTAssert(a.min() == 0.0)
    }
    
    func testAlgorithms() {
        let b = [5, 3, 1 , 2, 10, 11, 9]
        let (sortedB, ids) = quicksort(b)
//        print(sortedB, ids)
        XCTAssertFalse(all([true, false, true]))
        XCTAssert(all([true, true, true]))
        XCTAssert(all(sortedB == b.sorted()))
        XCTAssert(all(ids == [2, 3, 1, 0, 6, 4, 5]))
        XCTAssert(argmax(b) == 5)
        XCTAssert(argmin(b) == 2)
        XCTAssert(max(b) == 11)
        XCTAssert(min(b) == 1)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
