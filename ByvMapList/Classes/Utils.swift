//
//  Utils.swift
//  Pods
//
//  Created by Adrian Apodaca on 27/11/16.
//
//

import Foundation


enum ByvPosition {
    case top
    case right
    case bottom
    case left
    case all
}

extension UIView {
    func addTo(_ superView: UIView, position:ByvPosition = .all, insets: UIEdgeInsets = UIEdgeInsets.zero, centered:Bool = false, width: CGFloat? = nil, height: CGFloat? = nil) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        superView.addSubview(self)
        let views = ["view" : self]
        
        var formatString = "H:"
        
        if position == .left || ((position == .top || position == .bottom || position == .all) && !centered) {
            formatString += "|-(\(insets.left))-"
        }
        
        formatString += "[view"
        
        if let width = width {
            formatString += "(\(width))"
        }
        
        formatString += "]"
        
        if position == .right || ((position == .top || position == .bottom || position == .all) && !centered) {
            formatString += "-(\(insets.right))-|"
        }
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: formatString, options:[] , metrics: nil, views: views)
        
        NSLayoutConstraint.activate(constraints)
        
        if centered && position != .left && position != .right {
            superView.addConstraint(NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: superView, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0))
        }
        
        formatString = "V:"
        
        if position == .top || ((position == .left || position == .right || position == .all) && !centered) {
            formatString += "|-(\(insets.top))-"
        }
        
        formatString += "[view"
        
        if let height = height {
            formatString += "(\(height))"
        }
        
        formatString += "]"
        
        if position == .bottom || ((position == .left || position == .right || position == .all) && !centered) {
            formatString += "-(\(insets.bottom))-|"
        }
        
        constraints = NSLayoutConstraint.constraints(withVisualFormat: formatString, options:[] , metrics: nil, views: views)
        
        NSLayoutConstraint.activate(constraints)
        
        if centered && position != .top && position != .left {
            superView.addConstraint(NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: superView, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0))
        }
        
    }
    
    func addVertical(subViews:Array<UIView>, insets: UIEdgeInsets = UIEdgeInsets.zero, margin: CGFloat = 0.0, height: CGFloat? = nil) {
        
        var preView: UIView? = nil
        
        for view in subViews {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
            let views = ["view" : view, "preView": preView]
            var formatString = "H:|-(\(insets.left))-[view]-(\(insets.right))-|"
            var constraints = NSLayoutConstraint.constraints(withVisualFormat: formatString, options:[] , metrics: nil, views: views)
            
            NSLayoutConstraint.activate(constraints)
            
            formatString = "V:"
            
            if let preView = preView {
                formatString += "[preView]-(\(margin))-"
            } else {
                formatString += "|-(\(insets.top))-"
            }
            
            formatString += "[view"
            
            if let _height = height {
                formatString += "(\(_height))"
            }
            
            formatString += "]"
            
            if view == subViews.last {
                formatString += "-(\(insets.bottom))-|"
            }
            
            constraints = NSLayoutConstraint.constraints(withVisualFormat: formatString, options:[] , metrics: nil, views: views)
            
            NSLayoutConstraint.activate(constraints)
            
            preView = view
        }
    }
}
