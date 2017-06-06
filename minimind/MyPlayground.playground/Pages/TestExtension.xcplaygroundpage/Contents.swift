//: [Previous](@previous)

import Foundation
import Surge
import minimind

var str = "Hello, playground"

//: [Next](@next)


public func baz<T : FloatingPoint & ExpressibleByFloatLiteral>(_ t: [T]) {
    print("bar")
    switch t[0] {
    case is Float:
        baz(t as! [Float])
    case is Double:
        baz(t as! [Double])
    default:
        print("foo")
    }
}

public func baz( _ t: [Float]) -> Float {
    let x = sum(t)
    print("foo Float")
    return x
}

public func baz( _ t: [Double]) -> Double {
    let x = sum(t)
    print("foo Double")
    return x
}

public class A<T: FloatingPoint & ExpressibleByFloatLiteral> {
//    var v: T
    
    public init() {
        
    }
    
    public func foo(_ t: [T]) {
        baz(t)
    }
}

public func foo<T: FloatType>(_ t: [T]) {
    baz(t)
}

//extension A where T == Float {
//    public static func foo() {
//        bar(T(10.0))
//    }
//}

//
//extension A where T == Double {
//    public static func foo() {
//        print("when T == Double")
//    }
//}

let arr: [Float] = randArray(n: 10000)
let t1 = clock()

foo(arr)

let t2 = clock()
let d1 = Double(t2 - t1) / Double(CLOCKS_PER_SEC)

print("elapsed time d1: ", d1)

baz(arr as! [Float])

let d2 = Double(clock() - t2) / Double(CLOCKS_PER_SEC)

print("elapsed time d2: ", d2)