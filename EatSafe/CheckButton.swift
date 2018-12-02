//
//  CheckButton.swift
//  EatSafe
//
//  Created by Edward Arenberg on 12/2/18.
//  Copyright © 2018 Edward Arenberg. All rights reserved.
//

import UIKit

class CheckButton : UIButton {
    var isChecked = false {
        didSet {
            setNeedsDisplay()
        }
    }
    override func draw(_ rect: CGRect) {
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
        drawCircles(rect: rect)
    }
    func drawCircles(rect: CGRect){
        
        if isChecked {
            let gap : CGFloat = 8
            let btnColor = UIColor.white
            let innerCircleLayer = CAShapeLayer()
            let rectForInnerCircle = CGRect(x: gap, y: gap, width: rect.width - 2 * gap, height: rect.height - 2 * gap)
            innerCircleLayer.path = UIBezierPath(ovalIn: rectForInnerCircle).cgPath
            innerCircleLayer.fillColor = btnColor.cgColor
            layer.addSublayer(innerCircleLayer)
        } else {
            if let l = layer.sublayers?.first(where: {$0 is CAShapeLayer}) { l.removeFromSuperlayer() }
        }
        self.layer.shouldRasterize =  true
        self.layer.rasterizationScale = UIScreen.main.nativeScale
    }
}
