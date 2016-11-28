//
//  ByvMapListView.swift
//  Pods
//
//  Created by Adrian Apodaca on 27/11/16.
//
//

import UIKit
import MapKit

enum ByvListState {
    case header
    case single
    case list
}

protocol ByvMapListDataSource {
    
}

protocol ByvMapListDelegate {
    
}

public class ByvMapListView: UIView, MKMapViewDelegate {
    
    let minListTop: CGFloat = 20.0
    
    //CHange to real Cell
    let cellHeight: CGFloat = 100.0
    
    public var mapView: MKMapView = MKMapView()
    private var listView: UIView = UIView()
    private var headerView: UIView = UIView()
    private var listState:ByvListState = .header
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
        
        label.addTo(headerView, position: .all, centered: true)
        
        headerView.backgroundColor = UIColor.red
        headerView.setHeight(50)
        
        let collectionView = UIView()
        collectionView.backgroundColor = UIColor.orange
        
        let cell = UIView()
        cell.backgroundColor = UIColor.blue
        
        cell.addTo(collectionView, position: .top,  height: cellHeight)
        
        listView.addTo(self, position: .bottom, height: 100.0)
        listView.backgroundColor = UIColor.white
        listView.layer.cornerRadius = 20.0
        listView.addShadow()
        
        listView.add(subViews: [headerView, collectionView], insets: UIEdgeInsetsMake(18, 0, 0, 0))
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panHandler(sender:)))
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
    
    func changeToState(_ newState: ByvListState, animated:Bool = true) {
        listState = newState
        var height:CGFloat = 0.0
        switch listState {
        case .header:
            height = self.headerHeight()
        case .single:
            height = self.headerHeight() + self.cellHeight
        case .list:
            height = self.bounds.size.height - minListTop
        }
            
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.listView.height()?.constant = height
                self.listView.layoutIfNeeded()
            })
        } else {
            self.listView.height()?.constant = height
        }
    }
    
    var startY:CGFloat = 0.0
    
    func panHandler(sender: UIPanGestureRecognizer) {
        
        if sender.state == .began {
            startY = sender.location(in: listView).y
        }
        
        if sender.state == .changed {
            let height = getListHeight(sender.location(in: self))
            
            listView.height()?.constant = height
        }
        
        if sender.state == .ended {
            var height = getListHeight(sender.location(in: self)) - headerHeight()
            
            if height < cellHeight {
                if height < cellHeight / 2.0 {
                    changeToState(.header)
                } else {
                    changeToState(.single)
                }
            } else {
                height -= cellHeight
                if height < cellHeight {
                    changeToState(.single)
                } else {
                    changeToState(.list)
                }
            }
        }
    }
    
    func headerHeight() -> CGFloat {
        return headerView.frame.origin.y + headerView.frame.size.height
    }
    
    func getListHeight(_ point:CGPoint) -> CGFloat {
        var y = point.y - startY
        if y < minListTop {
            y = minListTop
        }
        var height = self.bounds.size.height - y
        let min = headerHeight()
        if height < min {
            height = min
        }
        
        return height
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
