//
//  GraphView.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/4/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import UIKit

@IBDesignable class GraphView: Artist {
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

    public func plot(x: [CGFloat], y: [CGFloat], c: UIColor) -> Line2D {
        let line = Line2D(x: x, y: y, frame: self.bounds)
        line.edgeColor = c
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
    
    override func drawInternal(_ rect: CGRect) {
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: 0.0, y: frame.height))
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: frame.width, y: 0.0))
        path.stroke()

    }
    
    override func autoscale() {
        for item in self.items {
            item.autoscale()
        }
    }
}
