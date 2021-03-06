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
                yy.append(contentsOf: item.y)
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
    
    public func plotAnimation(x: [[CGFloat]], y: [[CGFloat]], c: UIColor, s: CGFloat) -> Line2D {
        let line = Line2D(x: x[0], y: y[0], frame: self.bounds)
        line.edgeColor = c
        line.lineWidth = s
        self.items.append(line)

        var i = 0
//        line.transform = CGAffineTransform(scaleX: 0, y: 0)
//        UIView.animate(withDuration: 2.0, animations: {
//            line.transform = CGAffineTransform(scaleX: 1, y: 1)
//        }
//        )
        
        UIView.animateKeyframes(withDuration: 5.0, delay: 0.5, animations: {
//            line.edgeColor = UIColor.white
            for i in [0, 1, 2] {
                UIView.addKeyframe(withRelativeStartTime: Double(i) * 0.3, relativeDuration: 0.3, animations: {
                    line.x = x[i]
                    line.y = y[i]
                }
                )
            }
        }, completion: nil)
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
        self.autoScale(keepRatio)
        for item in self.items {
            item.scale(xScale, yScale)
            
        }
    }
}
