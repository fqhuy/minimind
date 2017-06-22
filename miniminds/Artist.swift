//
//  Artist.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/5/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import UIKit
import minimind

protocol CanAutoScale {
    var x: [CGFloat] {get}
    var y: [CGFloat] {get}
    mutating func autoScale(_ keepRatio: Bool)
}

protocol ArtistProtocol: class {
    var lineWidth: CGFloat {get set}
    var edgeColor: UIColor {get set}
    var fillColor: UIColor {get set}
    var xScale: CGFloat {get set}
    var yScale: CGFloat {get set}
    var frame: CGRect {get set}
    func drawInternal(_ rect: CGRect)
    func autoCenter()
}

extension ArtistProtocol where Self: CanAutoScale {
    func autoScale(_ keepRatio: Bool = true) {
        let minX = min(x.float)
        let maxX = max(x.float)
        let minY = min(y.float)
        let maxY = max(y.float)
        
        xScale = frame.width / CGFloat(maxX - minX)
        yScale = frame.height / CGFloat(maxY - minY) // 2
        
        if keepRatio {
            xScale = min(xScale, yScale)
            yScale = xScale
        }
    }
}

class Artist: UIView, ArtistProtocol, CanAutoScale {

    //MARK: Properties
    @IBInspectable var _lineWidth: CGFloat = 0.5
    @IBInspectable var edgeColor: UIColor = UIColor.green
    @IBInspectable var fillColor: UIColor = UIColor.white
    @IBInspectable var xScale: CGFloat = 1.0
    @IBInspectable var yScale: CGFloat = 1.0
    
    var xScaleFactor: CGFloat = 1.0
    var yScaleFactor: CGFloat = -1.0
    var xOrigin: CGFloat = 0
    var yOrigin: CGFloat = 0

    
    var x: [CGFloat] {
        get {
            return [frame.minX, frame.maxX]
        }
        
        set(val) {
            
        }
    }
    
    var y: [CGFloat] {
        get {
            return [frame.minY, frame.maxY]
        }
        
        set(val) {
            
        }
    }
    
    public var lineWidth: CGFloat {
        get {
            return _lineWidth / max(xScale, yScale)
        }
        set(val) {
            _lineWidth = val
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.xOrigin = frame.width / 2.0
        yOrigin = frame.height / 2.0

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        
        context.saveGState();

        context.translateBy(x: xOrigin, y: yOrigin);
        context.scaleBy(x: xScaleFactor * xScale, y: yScaleFactor * yScale);
        
        drawInternal(rect)
        
        context.restoreGState();
    }
    
    func scale(_ x: CGFloat, _ y: CGFloat) {
        xScale = x
        yScale = y
    }

    func drawInternal(_ rect: CGRect) {
        fatalError("not implemented")
    }
    
    func autoCenter() {
        self.xOrigin = CGFloat(mean(x.float))
        self.yOrigin = CGFloat(mean(y.float))
    }
}


@IBDesignable class Line2D: Artist {
    //MARK: Properties
    var _x: [CGFloat] = [0.0, 100.0, 200.0]
    var _y: [CGFloat] = [100.0, 400, 300.0]
    override var x: [CGFloat] {
        get {
            return _x
        }
        set(val) {
            _x = val
        }
    }
    override var y: [CGFloat] {
        get {
            return _y
        }
        set(val) {
            _y = val
        }
    }
    
    //MARK: Initialisations
    init(x: [CGFloat], y: [CGFloat], frame: CGRect) {
        super.init(frame: frame)
        
        self.x = x
        self.y = y
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawInternal(_ rect: CGRect) {
        
        let path = UIBezierPath()
        let point = CGPoint(x: self.x[0], y: self.y[0] )
        path.move(to: point)
        for i in 1..<x.count {
            path.addLine(to: CGPoint(x: self.x[i], y: self.y[i] ))
        }
        edgeColor.setStroke()
        path.lineWidth = lineWidth
        path.stroke()
    }

    override func autoCenter() {
        
    }
}

@IBDesignable class PathCollection: Artist {
    //MARK: Properties
    var _x: [CGFloat] = [0.0, 100.0, 200.0]
    var _y: [CGFloat] = [100.0, 400, 300.0]
    
    override var x: [CGFloat] {
        get {
            return _x
        }
        set(val) {
            _x = val
        }
    }
    override var y: [CGFloat] {
        get {
            return _y
        }
        set(val) {
            _y = val
        }
    }
    
    @IBInspectable var _markerSize: CGFloat = 10.0
    
    public var markerSize: CGFloat {
        get {
            return _markerSize / max(xScale, yScale)
        }
        set(val) {
            _markerSize = val
        }
    }
    
    init(x: [CGFloat], y: [CGFloat], frame: CGRect) {
        super.init(frame: frame)
        self.x = x
        self.y = y
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawInternal(_ rect: CGRect) {
        
        fillColor.setFill()
        edgeColor.setStroke()
        for i in 0..<x.count {
            let r = CGRect(x: x[i] - markerSize / 2.0, y: y[i] - markerSize / 2.0, width: markerSize, height: markerSize)
            let path = UIBezierPath(ovalIn: r)
            path.lineWidth = lineWidth
            path.stroke()
        }
    }
    
    override func autoCenter() {
        
    }
}

@IBDesignable class Image2D: Artist {
    var _x: [CGFloat] = [0.0, 100.0, 200.0]
    var _y: [CGFloat] = [100.0, 400, 300.0]
    var mat: Matrix<Float> = Matrix()
    var cmap: ColorMap = ColorMap()
    var resamplingFactor: Int = 3
    
    var rows: Int {
        get {
            return mat.rows
        }
    }

    var cols: Int {
        get {
            return mat.columns
        }
    }
    
    var pixWidth: CGFloat {
        get {
            return CGFloat(Float(frame.width) / Float(mat.columns))
        }
    }
    var pixHeight: CGFloat {
        get {
            return CGFloat(Float(frame.height) / Float(mat.rows))
        }
    }

    
    override var x: [CGFloat] {
        get {
            return linspace(Float(0.0), Float(frame.width), self.mat.columns).cgFloat
        }
        set(val) {
            _x = val
        }
    }
    override var y: [CGFloat] {
        get {
            return linspace(Float(0.0), Float(frame.height), self.mat.rows).cgFloat
        }
        set(val) {
            _y = val
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init(_ mat: Matrix<Float>, _ interpolation: String="bicubic", _ cmap: String = "blues", _ frame: CGRect) {
        super.init(frame: frame)
        
        switch interpolation {
            case "bicubic":
            var C: Matrix<Float> = zeros(Int(mat.rows * resamplingFactor), Int(mat.columns * resamplingFactor))
            for r in 0..<mat.rows {
                for c in 0..<mat.columns {
                    C[r * resamplingFactor, c * resamplingFactor] = mat[r, c]
                }
            }
                
            self.mat = bicubicInterpolation(C, resamplingFactor + 3)
            case "nearest":
            self.mat = mat
            default: break
        }
        self.mat = normalize(self.mat)
        self.cmap = ColorMap.getColorMap(cmap)
        self.edgeColor = UIColor.clear
        yScaleFactor = 1.0
        xOrigin = 0.0
        yOrigin = 0.0
    }
    
    func bicubicInterpolation(_ mat: Matrix<Float>, _ factor: Int = 3) -> Matrix<Float> {
        func bicubic(_ x: Float, _ a: Float = -0.5) -> Float {
            if abs(x) <= 1 {
                return (a + 2.0) * powf(abs(x),3.0) - (a + 3.0) * powf(abs(x),2.0) + 1
            } else if (1 < abs(x)) && (abs(x) <= 2) {
                return a * powf(abs(x),3.0) - 5.0 * a * powf(abs(x),2.0) + 8.0 * a * abs(x) - 4.0 * a
            }
            else {
                return 0.0
            }
        }
        var A = mat
        let K = Matrix([arange(-2.0, 2.0, 2.0 / Float(factor)).map{ bicubic($0) }]) //
//        let K = Matrix<Float>([[0.333, 0.666, 1.0, 0.666, 0.333]]) //
        A = minimind.conv(A, K)
        return A
    }
    
    func normalize(_ mat: Matrix<Float>) -> Matrix<Float> {
        var newmat = mat - minimind.min(mat)
        newmat = newmat * (1.0 / minimind.max(newmat))
        newmat = clip(newmat, 0.0, 1.0)
        return newmat
    }
    
    override func drawInternal(_ rect: CGRect) {
        edgeColor.setStroke()
        for r in 0..<rows {
            for c in 0..<cols {
                let pixel = UIBezierPath(rect: CGRect(x: x[r], y: y[c], width: pixWidth, height: pixHeight))
                let color = cmap.toUIColor(mat[r, c])
                color.setFill()
                pixel.fill()
            }
        }
        
    }
}

@IBDesignable class Contour: Artist {
    //MARK: Properties
    var _x: [CGFloat] = [0.0, 100.0, 200.0]
    var _y: [CGFloat] = [100.0, 400, 300.0]
    
    override var x: [CGFloat] {
        get {
            return _x
        }
        set(val) {
            _x = val
        }
    }
    override var y: [CGFloat] {
        get {
            return _y
        }
        set(val) {
            _y = val
        }
    }
    
    var z: [CGFloat] = [0.0, 100.0, 100.0, 0.0, 100.0, 100.0]
    var nLevels: Int = 3
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(x: [CGFloat], y: [CGFloat], z: [CGFloat], nLevels: Int, frame: CGRect) {
        super.init(frame: frame)
        self.x = x
        self.y = y
        self.z = z
        self.nLevels = nLevels
    }
    
    override func drawInternal(_ rect: CGRect) {
        fillColor.setFill()
        edgeColor.setStroke()
        
        let (X, Y) = minimind.meshgrid(x.float, y.float)
        let Z = Matrix(len(x), len(y), z.float)
        
        for i in 0..<nLevels {
            
        }
    }
}
