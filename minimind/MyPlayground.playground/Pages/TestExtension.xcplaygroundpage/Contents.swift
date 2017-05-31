//: [Previous](@previous)

import Foundation
import Surge

var str = "Hello, playground"

//: [Next](@next)

public class A<T: FloatingPoint & ExpressibleByFloatLiteral> {
//    var v: T
    
    public init(){
//        v = 0.0 as! T
        
    }
    
    public func foo() {
        print("in A")
    }
    
    public func bar(_ t: T) -> T {
        let v: T = 5.0
        return v * t
    }
    
    public func mul(_ t: Matrix<T>) -> Matrix<T> {
        return t * transpose(t)
    }
}

extension A where T == Float {
    public func foo() {
        print("when T == Float")
    }
    

}

let a: A<Float> = A()
a.foo()
let x = a.bar(2000.0)
x is Double

let m = Matrix<Float>([[0.0, 1.1]])
a.mul(m)



