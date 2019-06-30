//
//  HeadingIndicator.swift
//  HeadingExample
//
//  Created by Daniel Zeitman on 6/30/19.
//  Copyright © 2019 Bose Corporation. All rights reserved.
//

import UIKit

@IBDesignable
class HeadingIndicator: UIView {

    
  public var degrees:CGFloat = 0.0
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        // Drawing code
        
        HeadingStyleKit.drawHeading(frame: bounds, resizing: HeadingStyleKit.ResizingBehavior.aspectFit
            , degrees: degrees)
    }
 

}
