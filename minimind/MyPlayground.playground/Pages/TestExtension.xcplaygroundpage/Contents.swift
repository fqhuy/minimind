//: [Previous](@previous)

import Foundation
//import Surge
import minimind

var str = "Hello, playground"

//: [Next](@next)

public typealias FloatT = FloatingPoint & ExpressibleByFloatLiteral

public protocol A {
    associatedtype T
    func bar()
    
    init()
}

public protocol B {
    func foo()
}

extension A where Self: B {
    public func fzz(){
        foo()
    }
}

extension A where T == Float {
    public func foo() {
        print("when T == Float")
    }
}

extension A where T == Double {
    public func foo() {
        print("when T == Double")
        commonFoo()
    }
    
}

extension A where T: FloatT {
    public func foo() {
        print("when T: FloatT")
    }
    
    public func commonFoo() {
        print("commonFoo")
    }
}

class X<T: A & B> {
    var t: T
    public init() {
        self.t = T()
    }
    
    public func foo(){
        t.foo()
    }
}

class C: A, B {
    typealias T = Float
    
    public func bar() {
        print("bar")
    }
    
    public required init(){
        
    }
}

class D: A, B {
    typealias T = Double
    public func bar() {
        print("bar")
    }
    
    public required init(){
        
    }
}

public func foo<T: A & B>(_ lhs: T, _ rhs: T) {
    lhs.foo()
    rhs.foo()
}

let c = C()
//c.fzz()

let d = D()
//d.fzz()

let x = X<C>()
foo(c, c)

//let arr: [Float] = randArray(n: 10000)
//let t1 = clock()
//
//foo(arr)
//
//let t2 = clock()
//let d1 = Double(t2 - t1) / Double(CLOCKS_PER_SEC)
//
//print("elapsed time d1: ", d1)
//
//baz(arr as! [Float])
//
//let d2 = Double(clock() - t2) / Double(CLOCKS_PER_SEC)
//
//print("elapsed time d2: ", d2)
