//
//  array_int_extension.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/12/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation

//MARK: Array extensions

public extension Array where Element: Integer {
//    public func std() -> Element {
//        let m = mean()
//        let v = mean(self.map{ powf(($0 - m), 2.0)})
//        return sqrtf(v)
//    }
//    
//    public func mean() -> Element {
//        return sum() / Element(count)
//    }
//    
//    public func mean(_ arr: [Element]) -> Element {
//        return sum(arr) / Element(arr.count)
//    }
    
    public func sum() -> Element {
        return self.reduce(0, {x, y in x + y} )
    }
    
    public func sum(_ arr: [Element]) -> Element {
        return arr.reduce(0, {x, y in x + y} )
    }
    
//    public func norm() -> Element {
//        return sqrt((self ** 2).sum())
//    }
    
//    public func cumsum() -> [Element] {
//        var tmp: Int = 0
//        var re: [Int] = []
//        for i in 0..<count {
//            tmp += self[i] as! Int
//            re.append(tmp)
//        }
//        return re
//    }
}

//MARK: ARITHMETIC

public func sum<T: Integer>(_ arr: [T]) -> T {
    return arr.reduce(0, {x,y in x + y})
}

public func prod<T: Integer>(_ arr: [T]) -> T {
    return arr.reduce(0, {x,y in x * y})
}

public func mean<T: Integer>(_ arr: [T]) -> Int {
    return (sum(arr) as! Int) / Int(arr.count)
}
