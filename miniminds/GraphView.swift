//
//  GraphView.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/4/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import UIKit
import minimind

@IBDesignable class GraphView: Artist {
    
    override var x: [CGFloat] {
        get{
            var xx: [CGFloat] = []
            for item in items {
                xx.append(contentsOf: item.x)
            }
            return xx
        }
        set(val) {
            
        }
    }

    override var y: [CGFloat] {
        get{
            var yy: [CGFloat] = []
            for item in items {
                yy.append(contentsOf: item.x)
            }
            return yy
        }
        set(val) {
            
        }
    }
    
    private var items: [Artist] = [] {
        willSet(newItems) {
            for item in items {
                
                item.removeFromSuperview()
            }
        }
        didSet {
            addItems(items)
        }
    }
    
    public func addItems(_ artists: [Artist]) {
        for item in artists {
            item.center = self.convert(self.center, from: item)
            addSubview(item)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func plot(x: [CGFloat], y: [CGFloat], c: UIColor, s: CGFloat) -> Line2D {
        let line = Line2D(x: x, y: y, frame: self.bounds)
        line.edgeColor = c
        line.lineWidth = s
        self.items.append(line)
        return line
    }
    
    public func scatter(x: [CGFloat], y: [CGFloat], c: UIColor, s: CGFloat ) -> PathCollection {
        let coll = PathCollection(x: x, y: y, frame:  self.bounds) //self.frame
        coll.edgeColor = c
        coll.markerSize = s
        self.items.append(coll)
        return coll
    }
    
    public func imshow(_ x: Matrix<Float>, _ interpolation: String = "nearest", _ cmap: String = "blues") -> Image2D {
        let im = Image2D(x, interpolation, cmap, self.bounds)
        self.items.append(im)
        return im 
    }
    
    override func drawInternal(_ rect: CGRect) {
        
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: 0.0, y: frame.height))
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: frame.width, y: 0.0))
        path.stroke()

    }
    
    func autoScaleAll(_ keepRatio: Bool = true) {
//        autoScale(keepRatio)
//        let minX = min(x.float)
//        let maxX = max(x.float)
//        let minY = min(y.float)
//        let maxY = max(y.float)
//        
//        xScale = frame.width / CGFloat(maxX - minX)
//        yScale = frame.height / CGFloat(maxY - minY) // 2
//        
//        if keepRatio {
//            xScale = min(xScale, yScale)
//            yScale = xScale
//        }
        
        for item in self.items {
            item.scale(xScale, yScale)
            
        }
    }
}
