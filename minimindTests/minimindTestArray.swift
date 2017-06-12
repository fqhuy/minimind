//
//  minimindTestArray.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/12/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import XCTest
@testable import minimind

class minimindTestArray: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAlgorithms() {
        let v: [Float] = [0.1, 0.3, 0.5, 0.9]
        let a: [Float] = [0.2, 0.4]
        
        print(binarysearch(v, 0.4))

    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
