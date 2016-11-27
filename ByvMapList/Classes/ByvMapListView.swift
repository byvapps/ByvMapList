//
//  ByvMapListView.swift
//  Pods
//
//  Created by Adrian Apodaca on 27/11/16.
//
//

import UIKit

import MapKit

protocol ByvMapListDataSource {
    
}

protocol ByvMapListDelegate {
    
}

public class ByvMapListView: UIView, MKMapViewDelegate {
    
    public var mapView:MKMapView = MKMapView()
    private var listView:UIView = UIView()
    private var listHeight:NSLayoutConstraint? = nil
    private var headerView:UIView = UIView()
    //public var collection:UICollectionView = UICollectionView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        load()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }
    
    public func load() {
        //Map
        mapView.addTo(self)
        
        //listView
        var separator = UIView()
        separator.backgroundColor = UIColor.gray
        separator.layer.cornerRadius = 3
        
        separator.addTo(listView, position: .top, insets: UIEdgeInsetsMake(6, 0, 0, 0), centered: true, width: 40.0, height: 6.0)
        
        var label = UILabel()
        label.text = "Prueba de Texto"
        
        label.addTo(headerView, position: .all, centered: false, height: 50.0)
        
        headerView.backgroundColor = UIColor.red
        
        let collectionView = UIView()
        collectionView.backgroundColor = UIColor.orange
        
        let cell = UIView()
        cell.backgroundColor = UIColor.blue
        
        cell.addTo(collectionView, position: .top, height: 100.0)
        
        listView.backgroundColor = UIColor.green
        listView.addTo(self, position: .bottom, height: 100.0)
        
        listView.addVertical(subViews: [headerView, collectionView], insets: UIEdgeInsetsMake(18, 0, 0, 0))
        
        for constraint in listView.constraints {
            if constraint.firstAttribute == NSLayoutAttribute.height {
                listHeight = constraint
                break
            }
        }
        
        var pan = UIPanGestureRecognizer(target: self, action: #selector(panHandler(sender:)))
        listView.addGestureRecognizer(pan)
        
//        separator.translatesAutoresizingMaskIntoConstraints = false
//        listView.addSubview(separator)
//        let views = ["view" : separator]
//        
//        var formatString = "H:[view(40.0)]"
        /*
        if #available(iOS 9.0, *) {
            separator.centerXAnchor.constraint(equalTo: listView.centerXAnchor).isActive = true
        } else {
            // Fallback on earlier versions
        }
 */
//        listView.addConstraint(NSLayoutConstraint(item: separator, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: listView, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0))
//        
//        var constraints = NSLayoutConstraint.constraints(withVisualFormat: formatString, options:[] , metrics: nil, views: views)
//        
//        NSLayoutConstraint.activate(constraints)
//        
//        formatString = "V:|-(6.0)-[view(6.0)]"
//        constraints = NSLayoutConstraint.constraints(withVisualFormat: formatString, options:[] , metrics: nil, views: views)
//        
//        NSLayoutConstraint.activate(constraints)
    }
    
    var startY:CGFloat = 0.0
    
    func panHandler(sender: UIPanGestureRecognizer) {
        
        if sender.state == .began {
            startY = sender.location(in: listView).y
        }
        
        if sender.state == .changed {
            var height = sender.location(in: self).y - startY
            if height < 0 {
               height = 0.0
            }
            height = self.bounds.size.height - height
            let min = headerView.frame.origin.y + headerView.frame.size.height
            if height < min {
                height = min
            }
            
            listHeight?.constant = height
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
