//
//  ColorMap.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/20/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation
import UIKit
import minimind



public class ColorMap {
    typealias Element = Float

    func toRGB(_ e: Element) -> [Float] {
        return [e, e, e]
    }
    
    func toUIColor(_ e: Element) -> UIColor {
        let rgb = toRGB(e)
        return UIColor(red: CGFloat(rgb[0]), green: CGFloat(rgb[1]), blue: CGFloat(rgb[2]), alpha: CGFloat(1.0))
    }
    
    public static func getColorMap(_ s: String) -> ColorMap {
        switch s {
        case "blues": return Blues()
        case "cool": return Cool()
        case "luce": return Luce()
        default: return Blues()
        }
    }
}

public class ColorMap2: ColorMap {
    var from: Matrix<Float> = Matrix([[1.0, 1.0, 1.0]])
    var to: Matrix<Float> =  Matrix([[0.0, 0.0, 0.0]])

    public override func toRGB(_ e: Float) -> [Float] {
        let v: Matrix<Float> = (to - from) * e + from
        return v.grid
    }
}

public class Blues: ColorMap2 {
    public override init() {
        super.init()
        from = Matrix([[1.0, 0.0, 0.0]])
        to = Matrix([[0.0, 0.0, 1.0]])
    }
}

public class Cool: ColorMap2 {
    public override init() {
        super.init()
        to = Matrix([[1.0, 0.7372549, 0.96470588]])
        from = Matrix([[ 0.01960784,  0.12941176,  0.45490196]])
    }
}

public class Luce: ColorMap2 {
    public override init() {
        super.init()
        to = Matrix([[ 1.0        ,  0.78039216,  0.2627451 ]])
        from = Matrix([[ 0.01960784,  0.12941176,  0.45490196]])
    }
}

