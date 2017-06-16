//
//  Artist.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/5/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import UIKit
import Surge

protocol CanAutoScale {
    var x: [CGFloat] {get set}
    var y: [CGFloat] {get set}
    mutating func autoScale(_ keepRatio: Bool)
}

protocol ArtistProtocol {
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
    mutating func autoScale(_ keepRatio: Bool = true) {
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
    @IBInspectable var yScale: CGFloat = -1.0
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

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        
        context.saveGState();

        context.translateBy(x: rect.width / 2.0, y: rect.height / 2.0);
        context.scaleBy(x: xScale, y: -yScale);
        
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
        fatalError("not implemented")
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
//        self.backgroundColor = UIColor.gray
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
