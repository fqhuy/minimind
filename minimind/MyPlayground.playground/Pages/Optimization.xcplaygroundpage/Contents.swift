//: [Previous](@previous)

import Foundation
import Surge
import minimind

var str = "Hello, playground"

//: [Next](@next)

class Quad: ObjectiveFunction {
    typealias ScalarT = Float
    typealias MatrixT = Matrix<ScalarT>
    
    public var a: ScalarT
    public var b: ScalarT
    public var c: ScalarT
    
    public init(_ a: ScalarT, _ b: ScalarT, _ c: ScalarT) {
        self.a = a
        self.b = b
        self.c = c
    }
    
    public func compute(_ x: MatrixT) -> ScalarT {
        return a * x[0, 0] * x[0,0] + b * x[0,0] + c
    }
    
    public func gradient(_ x: MatrixT) -> MatrixT {
        return MatrixT([[2 * a * x[0,0] + b]])
    }
}

var scg = SCG(objective: Quad(2.0, -3.0, 5.0), learning_rate: 0.01, init_x: Matrix<Float>([[100.0]]), maxiters: 200)


let (x, flog, _) = scg.optimize(verbose: true)
print(x)
