//
//  matrix.swift
//  minimind
//
//  Created by Phan Quoc Huy on 5/29/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.

//  Copyright (c) 2014–2015 Mattt Thompson (http://mattt.me)
//

import Foundation
import Accelerate

typealias NumberType = Float


//MARK: SURGE
public enum MatrixAxies {
    case row
    case column
}

public struct Matrix<T> {
    public typealias Element = T
    
    public var rows: Int
    public var columns: Int
    public var size: Int {
        get {
            return rows * columns
        }
    }
    
    public var shape: (Int, Int) {
        get {
            return (rows, columns)
        }
    }
    
    var _grid: [Element]
    public var grid: [Element] {
        get {
            return _grid
        }
        set(val) {
            assert(val.count == size, "incompatible grid")
            self._grid = val
        }
    }
    
    //MARK: initialisations
    public init() {
        self.rows = 0
        self.columns = 0
        self._grid = []
    }
    
    public init(rows: Int, columns: Int, repeatedValue: Element) {
        self.rows = rows
        self.columns = columns
        
        _grid = [Element](repeating: repeatedValue, count: rows * columns)
    }

    public init(_ rows: Int,_ columns: Int,_ data: [Element]) {
        var rr: Int = rows
        var cc: Int = columns
        if rows == -1 && columns > 0{
            rr = data.count / columns
        } else if rows > 0 && columns == -1 {
            cc = data.count / rows
        }
        
        precondition(data.count == rr * cc, "data.count != rows * columns")
        
        self.rows = rr
        self.columns = cc
        _grid = data
    }
    
    public init(_ data: [[Element]]) {
        precondition(data.count > 0)
        precondition(all(data.map{ $0.count } == data[0].count) , "all dimensions in data must be equal")
        rows = data.count
        columns = data[0].count
        _grid = flatten(data)
    }
    
    public subscript(row: Int, column: Int) -> Element {
        get {
            assert(indexIsValidForRow(row, column: column))
            return grid[(row * columns) + column]
        }
        
        set {
            assert(indexIsValidForRow(row, column: column))
            grid[(row * columns) + column] = newValue
        }
    }
    
    public subscript(row: Int) -> Matrix {
        get {
            assert(row < rows)
            let startIndex = row * columns
            let endIndex = row * columns + columns
            return Matrix(1, columns, Array(grid[startIndex..<endIndex]))
        }
        
        set {
            assert(row < rows)
            assert(newValue.size == columns)
            let startIndex = row * columns
            let endIndex = row * columns + columns
            grid.replaceSubrange(startIndex..<endIndex, with: newValue.grid)
        }
    }
    
    public subscript(column column: Int) -> Matrix {
        get {
            var result: [Element] = []
            for i in 0..<rows {
                let index = i * columns + column
                result.append(self.grid[index])
            }
            return Matrix(rows, 1, result)
        }
        
        set {
            assert(column < columns)
            assert(newValue.grid.count == rows)
            for i in 0..<rows {
                let index = i * columns + column
                grid[index] = newValue.grid[i]
            }
        }
    }

    public subscript(_ rows: [Int], _ columns: [Int]) -> Matrix {
        get {
            var arr: [Element] = []
            for r in 0..<rows.count {
                for c in 0..<columns.count {
                    arr.append(self[rows[r], columns[c]])
                }
            }
            return Matrix(rows.count, columns.count, arr)
        }
        set(val) {
            for r in 0..<rows.count {
                for c in 0..<columns.count {
                    self[rows[r], columns[c]] = val[r, c]
                }
            }
        }
    }
    
    public subscript(_ rows: [Int], _ column: Int) -> Matrix {
        return self[rows, [column]]
    }
    
    public subscript(_ row: Int, _ columns: [Int]) -> Matrix {
        return self[[row], columns]
    }
    
    public subscript(_ frow: (Int) -> [Int], _ fcol: ((Int) -> [Int])) -> Matrix {
        get {
            let rows = frow(self.rows)
            let cols = fcol(self.columns)
            
            return self[rows, cols]
        }
        set(val) {
            let rows = frow(self.rows)
            let cols = fcol(self.columns)
            self[rows, cols] = val
        }
    }
    
    public subscript(_ rows: [Int]) -> Matrix {
        return self[rows, Array(0..<columns)]
    }
    
    public subscript(cols columns: [Int]) -> Matrix {
        return self[Array(0..<rows), columns]
    }
    
    public subscript(_ frow: (Int) -> [Int], _ col: Int) -> Matrix {
        get {
            let rows = frow(self.rows)
            let cols = [col]
            
            return self[rows, cols]
        }
        set(val) {
            let rows = frow(self.rows)
            let cols = [col]
            self[rows, cols] = val
        }
    }
    
    public subscript(_ row: Int, _ fcol: (Int) -> [Int]) -> Matrix {
        get {
            let rows = [row]
            let cols = fcol(self.columns)
            return self[rows, cols]
        }
        set(val) {
            let rows = [row]
            let cols = fcol(self.columns)
            self[rows, cols] = val
        }
    }
    
    public subscript(_ mask: Matrix<Bool>) -> Matrix<Element> {
        get {
            var re: [Element] = []
            for r in 0..<rows {
                for c in 0..<columns {
                    if mask[r, c] == true {
                        re.append(self[r, c])
                    }
                }
            }
            return Matrix(1, re.count, re)
        }
        set(arr) {
            for r in 0..<rows {
                for c in 0..<columns {
                    if mask[r, c] == true {
                        self[r, c] = arr[0, r * columns + c]
                    }
                }
            }
        }
    }
    
    fileprivate func indexIsValidForRow(_ row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    public static func << <T>(lhs: inout Matrix<T>, rhs: T) {
        for r in 0..<lhs.rows {
            for c in 0..<lhs.columns {
                lhs[r, c] = rhs
            }
        }
    }
    
    public func reshape(_ shape: [Int]) -> Matrix {
        precondition((shape[0] * shape[1] == self.size) || (shape[0] == -1) || (shape[1] == -1), "invalid shape")
        var mat = self
        var (rr, cc) = tuple(shape)
        if (shape[0] == -1) && (shape[1] > 0) {
            assert(size % shape[1] == 0)
            rr = size / shape[1]
            cc = shape[1]
        } else if (shape[1] == -1) && (shape[0] > 0) {
            cc = size / shape[0]
            rr = shape[0]
        }
        mat.rows = rr
        mat.columns = cc
        return mat
    }
    
    public var t: Matrix {
        get {
            return transpose(self)
        }
    }
}

// MARK: - Printable

extension Matrix: CustomStringConvertible {
    public var description: String {
        var description = ""
        
        for i in 0..<rows {
            let contents = (0..<columns).map{"\(self[i, $0])"}.joined(separator: "\t")
            
            switch (i, rows) {
            case (0, 1):
                description += "(\t\(contents)\t)"
            case (0, _):
                description += "⎛\t\(contents)\t⎞"
            case (rows - 1, _):
                description += "⎝\t\(contents)\t⎠"
            default:
                description += "⎜\t\(contents)\t⎥"
            }
            
            description += "\n"
        }
        
        return description
    }
}

// MARK: - SequenceType

//extension Matrix: Sequence {
//    public func makeIterator() -> AnyIterator<ArraySlice<Element>> {
//        let endIndex = rows * columns
//        var nextRowStartIndex = 0
//        
//        return AnyIterator {
//            if nextRowStartIndex == endIndex {
//                return nil
//            }
//            
//            let currentRowStartIndex = nextRowStartIndex
//            nextRowStartIndex += self.columns
//            
//            return self.grid[currentRowStartIndex..<nextRowStartIndex]
//        }
//    }
//}

//extension Matrix: Equatable {}

//public func ==<T: Equatable> (lhs: Matrix<T>, rhs: Matrix<T>) -> Bool {
//    return lhs.rows == rhs.rows && lhs.columns == rhs.columns && lhs.grid == rhs.grid
//}

//MARK: Matrix<ScalarType>
//TODO: It is possible to move apply to the above extension. Might hurts performance though.
public extension Matrix where T: ScalarType {
    
    // apply a function to reduce an axis to scalar
    //TODO: apply<T2> might subsume this one
    public func apply(_ f: ([T]) -> T, _ axis: Int) -> Matrix {
        if axis == 0 {
            var m: Matrix = zeros(1, columns)
            for col in 0..<columns {
                m[0, col] = f(self[column: col].grid)
            }
            return m
        } else if axis == 1 {
            var m: Matrix = zeros(rows, 1)
            for row in 0..<rows {
                m[row, 0] = f(self[row].grid)
            }
            return m
        } else {
            return Matrix([[f(grid)]])
        }
    }

    // apply a function to reduce an axis to scalar
    public func apply<T2: ScalarType>(_ f: ([T]) -> T2, _ axis: Int) -> Matrix<T2> {
        if axis == 0 {
            var m: Matrix<T2> = minimind.zeros(1, columns)
            for col in 0..<columns {
                m[0, col] = f(self[column: col].grid)
            }
            return m
        } else if axis == 1 {
            var m: Matrix<T2> = minimind.zeros(rows, 1)
            for row in 0..<rows {
                m[row, 0] = f(self[row].grid)
            }
            return m
        } else {
            return Matrix<T2>([[f(grid)]])
        }
    }
    
    // Apply a transformation function to an axis
    public func apply(_ f: ([T]) -> [T], _ axis: Int) -> Matrix<Element> {
        var re: Matrix<T> = self.zeros(rows, columns)
        switch axis {
        case 1: for c in 0..<columns {
            re[0∶, c] = Matrix(rows, 1, f(self[column: c].grid))
            }
        case 0: for r in 0..<rows {
            re[r, 0∶] = Matrix(1, columns, f(self[r].grid))
            }
        default :
            fatalError("invalid axis")
        }
        return re
    }
    
    public func apply(f: ([T], [T]) -> [T], arr: [T], axis: Int) -> Matrix<Element> {
        var re: Matrix<T> = self.zeros(rows, columns)
        switch axis {
        case 1: for c in 0..<columns {
            assert(rows == arr.count, "incompatible shape. arr.count must be equal self.rows")
            re[0∶, c] = Matrix(rows, 1, f(self[column: c].grid, arr))
            }
        case 0: for r in 0..<rows {
            assert(columns == arr.count, "incompatible shape. arr.count must be equal columns")
            re[r, 0∶] = Matrix(1, columns, f(self[r].grid, arr))
            }
        default :
            fatalError("invalid axis")
        }
        return re
    }
    
    public func sum(_ axis: Int = -1) -> Matrix {
        return apply(minimind.sum, axis)
    }
    
    public func zeros(_ rows: Int, _ columns: Int) -> Matrix {
        return minimind.zeros(rows, columns)
    }
}


//MARK: OPERATORS

public func add<T: ScalarType>(_ x: Matrix<T>, y: Matrix<T>) -> Matrix<T> {
    checkMatrices(x, y, "same")
    return Matrix<T>( x.rows, x.columns, (0..<x.grid.count).map{ i in x.grid[i] + y.grid[i] } )
}

public func add<T: ScalarType>(_ x: Matrix<T>, y: T) -> Matrix<T> {
    return Matrix<T>( x.rows, x.columns, (0..<x.grid.count).map{ i in x.grid[i] + y } )
}

public func add<T: ScalarType>(_ x: T, y: Matrix<T>) -> Matrix<T> {
    return Matrix<T>( y.rows, y.columns, (0..<y.grid.count).map{ i in x + y.grid[i] } )
}

public func sub<T: ScalarType>(_ x: Matrix<T>, y: Matrix<T>) -> Matrix<T> {
    checkMatrices(x, y, "same")
    return Matrix<T>( x.rows, x.columns, (0..<x.grid.count).map{ i in x.grid[i] - y.grid[i] } )
}

public func sub<T: ScalarType>(_ x: Matrix<T>, y: T) -> Matrix<T> {
    return Matrix<T>( x.rows, x.columns, (0..<x.grid.count).map{ i in x.grid[i] - y } )
}

public func sub<T: ScalarType>(_ x: T, y: Matrix<T>) -> Matrix<T> {
    return Matrix<T>( y.rows, y.columns, (0..<y.grid.count).map{ i in x - y.grid[i] } )
}

public func mul<T: ScalarType>(_ x: Matrix<T>, y: Matrix<T>) -> Matrix<T> {
    checkMatrices(x, y, "same")
    return Matrix<T>( x.rows, x.columns, (0..<x.grid.count).map{ i in x.grid[i] * y.grid[i] } )
}

public func mul<T: ScalarType>(_ x: Matrix<T>, y: T) -> Matrix<T> {
    return Matrix<T>( x.rows, x.columns, (0..<x.grid.count).map{ i in x.grid[i] * y } )
}

public func mul<T: ScalarType>(_ x: T, y: Matrix<T>) -> Matrix<T> {
    return Matrix<T>( y.rows, y.columns, (0..<y.grid.count).map{ i in x * y.grid[i] } )
}

public func div<T: ScalarType>(_ x: Matrix<T>, y: Matrix<T>) -> Matrix<T> {
    checkMatrices(x, y, "same")
    return Matrix<T>( x.rows, x.columns, (0..<x.grid.count).map{ i in x.grid[i] / y.grid[i] } )
}

public func div<T: ScalarType>(_ x: Matrix<T>, y: T) -> Matrix<T> {
    return Matrix<T>( x.rows, x.columns, (0..<x.grid.count).map{ i in x.grid[i] / y } )
}

public func div<T: ScalarType>(_ x: T, y: Matrix<T>) -> Matrix<T> {
    return Matrix<T>( y.rows, y.columns, (0..<y.grid.count).map{ i in x / y.grid[i] } )
}

public func kron<T: ScalarType>(_ x: Matrix<T>, _ y: Matrix<T>) -> Matrix<T> {
    var mat: Matrix<T> = zeros(x.rows * y.rows, x.columns * y.columns)
    for lr in 0..<x.rows {
        for lc in 0..<x.columns {
            for rr in 0..<y.rows {
                for rc in 0..<y.columns {
                    mat[lr * y.rows + rr, lc * y.columns + rc] = x[lr, lc] * x[rr, rc]
                }
            }
        }
        
    }
    return mat
}

public func +<T: ScalarType>(_ x: Matrix<T>, y: Matrix<T>) -> Matrix<T> {
    return add(x, y: y)
}

public func +<T: ScalarType>(_ x: Matrix<T>, y: T) -> Matrix<T> {
    return add(x, y: y)
}

public func +<T: ScalarType>(_ x: T, y: Matrix<T>) -> Matrix<T> {
    return add(x, y: y)
}

public func -<T: ScalarType>(_ x: Matrix<T>, y: Matrix<T>) -> Matrix<T> {
    return sub(x, y: y)
}

public func -<T: ScalarType>(_ x: Matrix<T>, y: T) -> Matrix<T> {
    return sub(x, y: y)
}

public func -<T: ScalarType>(_ x: T, y: Matrix<T>) -> Matrix<T> {
    return sub(x, y: y)
}

public func *<T: ScalarType>(_ x: Matrix<T>, y: Matrix<T>) -> Matrix<T> {
    return mul(x, y: y)
}

public func *<T: ScalarType>(_ x: Matrix<T>, y: T) -> Matrix<T> {
    return mul(x, y: y)
}

public func *<T: ScalarType>(_ x: T, y: Matrix<T>) -> Matrix<T> {
    return mul(x, y: y)
}

public func /<T: ScalarType>(_ x: Matrix<T>, y: Matrix<T>) -> Matrix<T> {
    return div(x, y: y)
}

public func /<T: ScalarType>(_ x: Matrix<T>, y: T) -> Matrix<T> {
    return div(x, y: y)
}

public func /<T: ScalarType>(_ x: T, y: Matrix<T>) -> Matrix<T> {
    return div(x, y: y)
}

infix operator ∘
// Entry-wise product
public func ∘<T: ScalarType>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
    var newmat = lhs
    newmat.grid = lhs.grid * rhs.grid
    return newmat
}

infix operator ⊗
//Kronecker product
public func ⊗ <T: ScalarType>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
    var mat: Matrix<T> = zeros(lhs.rows * rhs.rows, lhs.columns * rhs.columns)
    for lr in 0..<lhs.rows {
        for lc in 0..<lhs.columns {
            for rr in 0..<rhs.rows {
                for rc in 0..<rhs.columns {
                    mat[lr * rhs.rows + rr, lc * rhs.columns + rc] = lhs[lr, lc] * rhs[rr, rc]
                }
            }
        }
        
    }
    return mat
}

// Columns wise operators
infix operator |+
public func |+<T: ScalarType>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
    return lhs.apply(f: {(x: [T], y: [T]) -> [T] in x + y}, arr: rhs.grid, axis: 1)
}

infix operator |-
public func |-<T: ScalarType>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
    return lhs.apply(f: {(x: [T], y: [T]) -> [T] in x - y}, arr: rhs.grid, axis: 1)
}

infix operator |*
public func |*<T: ScalarType>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
    return lhs.apply(f: {(x: [T], y: [T]) -> [T] in x * y}, arr: rhs.grid, axis: 1)
}

infix operator |∘
public func |∘<T: ScalarType>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
    return lhs.apply(f: {(x: [T], y: [T]) -> [T] in x * y}, arr: rhs.grid, axis: 1)
}

infix operator |/
public func |/<T: ScalarType>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
    return lhs.apply(f: {(x: [T], y: [T]) -> [T] in x / y}, arr: rhs.grid, axis: 1)
}

// Row-wise operators

infix operator .+
public func .+<T: ScalarType>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
    return lhs.apply(f: {(x: [T], y: [T]) -> [T] in x + y}, arr: rhs.grid, axis: 0)
}

infix operator .-
public func .-<T: ScalarType>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
    return lhs.apply(f: {(x: [T], y: [T]) -> [T] in x - y}, arr: rhs.grid, axis: 0)
}

infix operator .*
public func .*<T: ScalarType>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
    return lhs.apply(f: {(x: [T], y: [T]) -> [T] in x * y}, arr: rhs.grid, axis: 0)
}

infix operator .∘
public func .∘<T: ScalarType>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
    return lhs.apply(f: {(x: [T], y: [T]) -> [T] in x * y}, arr: rhs.grid, axis: 0)
}

infix operator ./
public func ./<T: ScalarType>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
    return lhs.apply(f: {(x: [T], y: [T]) -> [T] in x / y}, arr: rhs.grid, axis: 0)
}

//MARK: LINEAR ALGEBRA & MATH
public func norm<T: FloatingPointScalarType>(_ mat: Matrix<T>, _ ord: String = "fro", p: T = 2, q: T = 1) -> T {
    switch ord {
    case "fro", "euclidean" :
        return sqrt(trace(mat * mat.t))
    default:
        return sqrt(trace(mat * mat.t))
//        var val = 0.0
//        let o = Int(ord)!
//        
//        for r in 0..<mat.rows {
//            var cval = 0.0
//            for c in 0..<mat.columns {
//                cval += pow(abs(mat[r, c]), p)
//            }
//            cval = pow(cval, q / p)
//            val += cval
//        }
//        val = pow(val, 1.0 / q)
//        return val
    }
}

public func sign<T: ScalarType>(_ mat: Matrix<T>) -> Matrix<T> {
    return Matrix<T>(mat.rows, mat.columns, sign(mat.grid))
}

public func sqrt<T: FloatType>(_ mat: Matrix<T>) -> Matrix<T> {
    return Matrix<T>(mat.rows, mat.columns, sqrt(mat.grid))
}

public func abs<T: ScalarType>(_ mat: Matrix<T>) -> Matrix<T> {
    var newmat = mat
    newmat.grid = minimind.abs(newmat.grid)
    return newmat
}

public func max<T: ScalarType>(_ mat: Matrix<T>) -> T {
    return minimind.max(mat.grid)
}

public func min<T: ScalarType>(_ mat: Matrix<T>) -> T {
    return minimind.min(mat.grid)
}

public func max<T: ScalarType>(_ mat: Matrix<T>, axis: Int) -> Matrix<T> {
    return mat.apply(minimind.max, axis)
}

public func min<T: ScalarType>(_ mat: Matrix<T>, axis: Int) -> Matrix<T> {
    return mat.apply(minimind.min, axis)
}

public func argmax<T: ScalarType>(_ mat: Matrix<T>, _ axis: Int) -> Matrix<IndexType> {
    return mat.apply(minimind.argmax, axis)
}

public func argmin<T: ScalarType>(_ mat: Matrix<T>, _ axis: Int) -> Matrix<IndexType> {
    return mat.apply(minimind.argmin, axis)
}

public func cross_add<T: ScalarType>(_ lhs: Matrix<T>, _ rhs: Matrix<T>) -> Matrix<T> {
    precondition((lhs.columns == 1) && (rhs.columns == 1), "lhs and rhs must have shape (N, 1)")
    
    var re: Matrix<T> = zeros(lhs.rows, rhs.rows)
    for i in 0..<lhs.rows {
        for j in 0..<rhs.rows {
            re[i, j] = lhs[i, 0] + rhs[j, 0]
        }
    }
    return re
}

public func trace<T: ScalarType>(_ mat: Matrix<T>) ->T {
    return sum(diag(mat).grid)
}

//MARK: TRAVERSE

public func reduce_sum<T: ScalarType>(_ mat: Matrix<T>,_ axis: Int = -1) -> Matrix<T> {
    return mat.apply(minimind.sum, axis)
}

public func reduce_prod<T: ScalarType>(_ mat: Matrix<T>,_ axis: Int = -1) -> Matrix<T> {
    return mat.apply(minimind.prod, axis)
}

//MARK: ACCESS

public func diag<T: ScalarType>(_ mat: Matrix<T>) -> Matrix<T> {
    var dmat: Matrix<T> = zeros(1, mat.columns)
    for i in 0..<mat.columns {
        dmat[0, i] = mat[i, i]
    }
    return dmat
}

public func tril<T: ScalarType>(_ mat: Matrix<T>) -> Matrix<T> {
    var dmat = mat
    for i in 0..<mat.rows{
        for j in 0...i {
            if i != j {
                dmat[j, i] = T.zero
            }
        }
    }
    return dmat
}

public func triu<T: ScalarType>(_ mat: Matrix<T>) -> Matrix<T> {
    var dmat = mat
    for i in 0..<mat.rows{
        for j in 0...i {
            if i != j {
                dmat[i, j] = T.zero
            }
        }
    }
    return dmat
}

//MARK: TRANSFORMERS
public func transpose<T>(_ mat: Matrix<T>) -> Matrix<T>{
    var newmat = mat
    newmat.rows = mat.columns
    newmat.columns = mat.rows
    for r in 0..<newmat.rows {
        for c in 0..<newmat.columns {
            newmat[r, c] = mat[c, r]
        }
    }
    return newmat
}

public func clip<T: ScalarType>(_ mat: Matrix<T>, _ floor: T, _ ceil: T, _ inplace: Bool = false) -> Matrix<T> {
        var newmat = mat
        newmat.grid = clip(mat.grid, floor, ceil)
        return newmat
}

public func tile<T: ScalarType>(_ mat: Matrix<T>, _ shape: [Int]) -> Matrix<T> {
    var newmat: Matrix<T> = zeros(mat.rows * shape[0], mat.columns * shape[1])
    for row in 0..<shape[0] {
        for col in 0..<shape[1] {
            for i in 0..<mat.rows {
                for j in 0..<mat.columns {
                    newmat[row * mat.rows + i, col * mat.columns + j] = mat[i, j]
                }
            }
        }
    }
    return newmat
}

public func vstack<T>(_ mats: [Matrix<T>]) -> Matrix<T> {
    checkMatrices(mats, "sameColumns")
    let rows = mats.map{ x in x.rows}.sum()
    var data = [T]()
    for i in 0..<mats.count {
        data.append(contentsOf: mats[i].grid)
    }
    return Matrix<T>(rows, mats[0].columns, data)
}

public func hstack<T>(_ mats: [Matrix<T>]) -> Matrix<T> {
    checkMatrices(mats, "sameRows")
    let cols = mats.map{ x in x.columns}.sum()
    let newmats = mats.map{ transpose($0) }
    return Matrix<T>(mats[0].rows, cols, transpose(vstack(newmats)).grid)
}

//MARK: CREATORS
public func diagonal<T: ScalarType>(_ a: [T]) -> Matrix<T> {
    var m: Matrix<T> = zeros(a.count, a.count)
    for i in 0..<a.count {
        m[i, i] = a[i]
    }

    return m
}

public func ones<T: ScalarType>(_ rows: Int, _ columns: Int) -> Matrix<T> {
    return Matrix<T>(rows: rows, columns: columns, repeatedValue: T.one)
}

public func zeros<T: ScalarType>(_ rows: Int, _ columns: Int) -> Matrix<T> {
    return Matrix<T>(rows: rows, columns: columns, repeatedValue: T.zero)
}

public func zeros_like<T: ScalarType>(_ mat: Matrix<T>) -> Matrix<T> {
    return zeros(mat.rows, mat.columns)
}

public func eye<T: ScalarType>(_ D: Int) -> Matrix<T> {
    var mat = Matrix<T>(rows: D, columns: D, repeatedValue: T.zero)
    for i in 0..<D {
        mat[i, i] = T.one
    }
    return mat
}

