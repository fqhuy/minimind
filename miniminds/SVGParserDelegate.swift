//
//  SVGParserDelegate.swift
//  minimind
//
//  Created by Phan Quoc Huy on 7/1/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation

class SVGParserDelegate: NSObject, XMLParserDelegate {
    var paths:[[Float]] = []
    var parser = XMLParser()
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if(elementName=="path")
        {
           let d = attributeDict["d"]!
           let pairs = d.components(separatedBy: CharacterSet(charactersIn: "MLZ") )
            var points: [Float] = []
            for pair in pairs {
                if pair == "" {
                    continue
                }
                let xy = pair.components(separatedBy: ",")
                points.append(Float(xy[0])!)
                points.append(Float(xy[1])!)
            }
            paths.append(points)
        }
    }
}
