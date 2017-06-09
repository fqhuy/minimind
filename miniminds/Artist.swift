//
//  Artist.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/5/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import UIKit
import Surge

class Artist: UIView {
    //MARK: Properties
    @IBInspectable var thickness: CGFloat = 0.5
    @IBInspectable var edgeColor: UIColor = UIColor.green
    @IBInspectable var fillColor: UIColor = UIColor.white
    @IBInspectable var xScale: CGFloat = 1.0
    @IBInspectable var yScale: CGFloat = -1.0
    
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

        context.translateBy(x: 0.0, y: rect.height / 2.0);
        context.scaleBy(x: xScale, y: -yScale);
        
        drawInternal(rect)
        
        context.restoreGState();
    }

    func drawInternal(_ rect: CGRect) {
        fatalError("not implemented")
    }
    
    func autoscale() {
        fatalError("not implemented")
    }
    
    func autocenter() {
        fatalError("not implemented")
    }
}

@IBDesignable class Line2D: Artist {
    //MARK: Properties
    var x: [CGFloat] = [0.0, 100.0, 200.0]
    var y: [CGFloat] = [100.0, 400, 300.0]
    
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
        path.lineWidth = thickness
        path.stroke()
    }
    
    override func autoscale() {
        let minX = min(x.float)
        let maxX = max(x.float)
        let minY = min(y.float)
        let maxY = max(y.float)
        
        xScale = frame.width / CGFloat(maxX - minX)
        yScale = frame.height / CGFloat(maxY - minY)
    }
    
    override func autocenter() {
        
    }
}

@IBDesignable class PathCollection: Artist {
    //MARK: Properties
    var x: [CGFloat] = [0.0, 100.0, 200.0]
    var y: [CGFloat] = [100.0, 400, 300.0]
    @IBInspectable var markerSize: CGFloat = 10.0
    
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
            path.lineWidth = thickness
            path.stroke()
        }
    }
    
    override func autoscale() {
        let minX = min(x.float)
        let maxX = max(x.float)
        let minY = min(y.float)
        let maxY = max(y.float)
        
        xScale = frame.width / CGFloat(maxX - minX)
        yScale = frame.height / CGFloat(maxY - minY)
    }
    
    override func autocenter() {
        
    }
}
