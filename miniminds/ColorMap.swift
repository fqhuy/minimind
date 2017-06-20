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
        case "jet": return Jet()
        default: return Blues()
        }
    }
}

public class Blues: ColorMap {
    public typealias Element = Float
    var from: Matrix<Float> = Matrix([[1.0, 1.0, 1.0]])
    var to: Matrix<Float> = Matrix([[0.0, 0.0, 1.0]])
    
    public override func toRGB(_ e: Float) -> [Float] {
        let v: Matrix<Float> = (to - from) * e + from
        return v.grid
    }
}

public class Jet: ColorMap {
    public typealias Element = Float
    var from: Matrix<Float> = Matrix([[1.0, 0.0, 0.0]])
    var to: Matrix<Float> = Matrix([[0.0, 0.0, 1.0]])
    
    public override func toRGB(_ e: Float) -> [Float] {
        let v: Matrix<Float> = (to - from) * e + from
        return v.grid
    }
}
