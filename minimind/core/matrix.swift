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
public typealias FloatType = ExpressibleByFloatLiteral & FloatingPoint
public typealias IntType = Integer

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
    
    public init(_ data: [[Element]]) {
        precondition(data.count > 0)
        precondition(all(data.map{ $0.count } == data[0].count) , "all dimensions in data must be equal")
        let m: Int = data.count
        let n: Int = data[0].count
        
        
        let repeatedValue: Element = data[0][0]
        
        self.init(rows: m, columns: n, repeatedValue: repeatedValue)
        
        for (i, row) in data.enumerated() {
            _grid.replaceSubrange(i*n..<i*n+Swift.min(m, row.count), with: row)
        }
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
        precondition(shape[0] * shape[1] == self.size, "invalid shape")
        var mat = self        
        mat.rows = shape[0]
        mat.columns = shape[1]
        
        return mat
    }
    
//    public func apply(_ f: ([T]) -> T, _ axis: Int) -> Matrix {
//        if axis == 0 {
//            var m: Matrix<T> = Matrix<T>(1, columns, 0 as! T)
//            for col in 0..<columns {
//                m[0, col] = f(self[column: col].grid)
//            }
//            return m
//        } else if axis == 1 {
//            var m: Matrix<T> = zeros(rows, 1)
//            for row in 0..<rows {
//                m[row, 0] = f(self[row].grid)
//            }
//            return m
//        } else {
//            return Matrix<T>([[f(grid)]])
//        }
//    }
    
    // Apply a transformation function to an axis
    public func apply(_ f: ([Element], [Element]) -> [Element], _ arr: [Element], _ axis: Int = 0) -> Matrix<Element> {
        var re: Matrix<Element> = self.zeros(rows, columns)
        switch axis {
        case 1: for c in 0..<columns {
            re[0∶, c] = Matrix(rows, 1, f(self[column: c].grid, arr))
            }
        case 0: for r in 0..<rows {
            re[r, 0∶] = Matrix(1, columns, f(self[r].grid, arr))
            }
        default :
            fatalError("invalid axis")
        }
        return re
    }
    
    public func zeros(_ rows: Int, _ columns: Int) -> Matrix<Element> {
        fatalError("unimplemented")
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

extension Matrix: Sequence {
    public func makeIterator() -> AnyIterator<ArraySlice<Element>> {
        let endIndex = rows * columns
        var nextRowStartIndex = 0
        
        return AnyIterator {
            if nextRowStartIndex == endIndex {
                return nil
            }
            
            let currentRowStartIndex = nextRowStartIndex
            nextRowStartIndex += self.columns
            
            return self.grid[currentRowStartIndex..<nextRowStartIndex]
        }
    }
}

//extension Matrix: Equatable {}

//public func ==<T: Equatable> (lhs: Matrix<T>, rhs: Matrix<T>) -> Bool {
//    return lhs.rows == rhs.rows && lhs.columns == rhs.columns && lhs.grid == rhs.grid
//}

//MARK: MINIMIND
public extension Matrix {
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
}


//MARK: OPERATORS


//public func ==<T: Equatable>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<Bool> {
//    precondition(lhs.shape == rhs.shape, "Can't compare matrices with different shapes")
//    var mat =  Matrix<Bool>(rows: lhs.rows, columns: lhs.columns,repeatedValue: true)
//    for r in 0..<lhs.rows {
//        for c in 0..<lhs.columns {
//            mat[r, c] = lhs[r, c] == rhs[r, c]
//        }
//    }
//    return mat
//}


//public func +(lhs: Matrix<Float>, rhs: Matrix<Float>) -> Matrix<Float> {
//    var mat = lhs
//    if lhs.shape == rhs.shape{
//        mat = add(lhs, y: rhs)
//    } else if (lhs.rows == rhs.rows) && (rhs.columns == 1) {
//        for col in 0..<lhs.columns {
//            mat[column: col] = lhs[column: col] + rhs[column: 0]
//        }
//    } else if (lhs.columns == rhs.columns) && (rhs.rows == 1) {
//        for row in 0..<lhs.rows {
//            mat[row] = lhs[row] + rhs[0]
//        }
//    } else {
//        fatalError("incompatible matrix shapes")
//    }
//    return mat
//}

public func * <T: FloatType>(lhs: Matrix<T>, rhs: T) -> Matrix<T> {
    var newmat = lhs
    newmat.grid = newmat.grid * rhs
    return newmat
}

public func /<T: FloatType> (lhs: Matrix<T>, rhs: T) -> Matrix<T> {
    var newmat = lhs
    newmat.grid = newmat.grid / rhs
    return newmat
}

public func div (mat: Matrix<Float>, scalar: Float) -> Matrix<Float> {
    return mat / scalar 
}

infix operator ∘
// Entry-wise product
public func ∘<T: FloatType>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
    var newmat = lhs
    newmat.grid = lhs.grid * rhs.grid
    return newmat
}

infix operator **
public func ** (_ mat: Matrix<Float>, _ e: Float) -> Matrix<Float> {
    let newgrid: [Float] = mat.grid.map{ powf($0, e) }
    return Matrix<Float>( mat.rows, mat.columns, newgrid)
}

//MARK: LINEAR ALGEBRA & MATH

public func sqrt<T: FloatType>(_ mat: Matrix<T>) -> Matrix<T> {
    return Matrix<T>(mat.rows, mat.columns, sqrt(mat.grid))
}

public func abs<T: FloatType>(_ mat: Matrix<T>) -> Matrix<T> {
    var newmat = mat
    newmat.grid = abs(newmat.grid)
    return newmat
}

public func max<T: FloatType>(_ mat: Matrix<T>) -> T {
    return mat.grid.max()!
}

public func min<T: FloatType>(_ mat: Matrix<T>) -> T {
    return mat.grid.min()!
}

public func cross_add<T: FloatType>(_ lhs: Matrix<T>, _ rhs: Matrix<T>) -> Matrix<T> {
    precondition((lhs.columns == 1) && (rhs.columns == 1), "lhs and rhs must have shape (N, 1)")
    
    var re: Matrix<T> = zeros(lhs.rows, rhs.rows)
    for i in 0..<lhs.rows {
        for j in 0..<rhs.rows {
            re[i, j] = lhs[i, 0] + rhs[j, 0]
        }
    }
    return re
}

public func trace<T: FloatType>(_ mat: Matrix<T>) ->T {
    return reduce_sum(diag(mat))![0,0]
}

//MARK: TRAVERSE

public func reduce_sum<T: FloatType>(_ mat: Matrix<T>,_ axis: Int? = nil) -> Matrix<T>? {
    if axis == nil {
        var newmat = Matrix<T>([[0.0]])
        newmat[0,0] = mat.grid.reduce(0.0, {x , y in x + y})
        return newmat
    } else if axis! == 1 {
        var newmat = Matrix<T>(rows: mat.rows, columns: 1, repeatedValue: 0.0)
        for i in 0..<mat.rows {
            newmat.grid[i] = mat[i].grid.reduce(0.0, {x,y in x+y})
        }

        return newmat
    } else if axis! == 0 {
        var newmat = Matrix<T>(rows: 1, columns: mat.columns, repeatedValue: 0.0)
        for i in 0..<mat.columns {
            newmat.grid[i] = mat[column: i].grid.reduce(0.0, {x,y in x+y})
        }
        return newmat
    } else {
        return nil
    }
}

public func reduce_prod<T: FloatType>(_ mat: Matrix<T>,_ axis: Int? = nil) -> Matrix<T>? {
    if axis == nil {
        var newmat = Matrix<T>([[0.0]])
        newmat[0,0] = mat.grid.reduce(1.0, {x , y in x * y})
        return newmat
    } else if axis! == 1 {
        var newmat = Matrix<T>(rows: mat.rows, columns: 1, repeatedValue: 0.0)
        for i in 0..<mat.rows {
            newmat.grid[i] = mat[i].grid.reduce(1.0, {x,y in x * y})
        }
        
        return newmat
    } else if axis! == 0 {
        var newmat = Matrix<T>(rows: 1, columns: mat.columns, repeatedValue: 0.0)
        for i in 0..<mat.columns {
            newmat.grid[i] = mat[column: i].grid.reduce(1.0, {x,y in x * y})
        }
        return newmat
    } else {
        return nil
    }
}

//MARK: ACCESS

public func diag<T: FloatType>(_ mat: Matrix<T>) -> Matrix<T> {
    var dmat = Matrix<T>(rows: 1, columns: mat.columns, repeatedValue: 0.0)
    for i in 0..<mat.columns {
        dmat[0, i] = mat[i, i]
    }
    return dmat
}

public func tril<T: FloatType>(_ mat: Matrix<T>) -> Matrix<T> {
    var dmat = mat
    for i in 0..<mat.rows{
        for j in 0...i {
            if i != j {
                dmat[j, i] = 0
            }
        }
    }
    return dmat
}

public func triu<T: FloatType>(_ mat: Matrix<T>) -> Matrix<T> {
    var dmat = mat
    for i in 0..<mat.rows{
        for j in 0...i {
            if i != j {
                dmat[i, j] = 0
            }
        }
    }
    return dmat
}

//MARK: TRANSFORMERS

public func clip<T: FloatType>(_ mat: Matrix<T>, _ floor: T, _ ceil: T, _ inplace: Bool = false) -> Matrix<T> {
        var newmat = mat
        newmat.grid = clip(mat.grid, floor, ceil)
        return newmat
}

public func tile<T: FloatType>(_ mat: Matrix<T>, _ shape: [Int]) -> Matrix<T> {
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

//public func hstack<T>(_ mats: [Matrix<T>]) -> Matrix<T> {
//    checkMatrices(mats, "sameRows")
//    let cols = mats.map{ x in x.columns}.sum()
//    var data = [T]()
//    for i in 0..<mats.count {
//        data.append(contentsOf: mats[i].grid)
//    }
//    return Matrix<T>(mats[0].rows, cols, data)
//}

//MARK: CREATORS
public func diagonal<T: FloatType>(_ a: [T]) -> Matrix<T> {
    var m: Matrix<T> = zeros(a.count, a.count)
    for i in 0..<a.count {
        m[i, i] = a[i]
    }

    return m
}

public func ones<T: FloatType>(_ rows: Int, _ columns: Int) -> Matrix<T> {
    return Matrix<T>(rows: rows, columns: columns, repeatedValue: 1.0 as T)
}

public func zeros<T: FloatType>(_ rows: Int, _ columns: Int) -> Matrix<T> {
    return Matrix<T>(rows: rows, columns: columns, repeatedValue: 0.0 as T)
}

public func eye<T: FloatType>(_ D: Int) -> Matrix<T> {
    var mat = Matrix<T>(rows: D, columns: D, repeatedValue: 0.0)
    for i in 0..<D {
        mat[i, i] = 1.0
    }
    return mat
}

