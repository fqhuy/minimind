//: [Previous](@previous)

import Foundation
import Surge

var str = "Hello, playground"

//: [Next](@next)

public func bar<T : FloatingPoint & ExpressibleByFloatLiteral>(_ t: T) {
    print("foo")
}

public func bar( _ t: Float) {
    print("foo Float")
}

public func bar( _ t: Double) {
    print("foo Double")
}

public class A<T: FloatingPoint & ExpressibleByFloatLiteral> {
//    var v: T
    
    public init() {
        
    }
    
    public static func foo() {
        let t:T = 10.0
        bar(t)
    }
}

//extension A where T == Float {
//    public static func foo() {
//        print("when T == Float")
//    }
//}
//
//extension A where T == Double {
//    public static func foo() {
//        print("when T == Double")
//    }
//}

let a: A<Float> = A()
A<Double>.foo()




