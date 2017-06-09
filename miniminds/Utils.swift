//
//  Utils.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/9/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation
import UIKit

public extension Array where Element == CGFloat {
    public var float: [Float] {
        get {
            return self.map{ Float($0) }
        }
    }
}
