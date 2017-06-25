//: [Previous](@previous)

import Foundation
import minimind

var str = "Hello, playground"

//: [Next](@next)

protocol A {
    associatedtype T
    var i: T {get set}
    func foo()
}

extension A {
    func foo() {
        print(i)
    }
}

public class BB: A{
    public typealias T = Int
    public var i: T = 10
    
    func bar() {
        foo()
    }
}

let b = BB()
b.bar()