//
//  ListHeader.swift
//  ByvMapList
//
//  Created by Adrian Apodaca on 14/12/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

class ListHeader: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "ListHeader", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

}
