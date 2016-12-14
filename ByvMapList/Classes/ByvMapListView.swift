//
//  ByvMapListView.swift
//  Pods
//
//  Created by Adrian Apodaca on 27/11/16.
//
//

import UIKit
import MapKit
import ByvUtils

public typealias ByvPinImage = (UIImage, CGPoint)

enum ByvListState {
    case header
    case single
    case list
}

public protocol ByvMapListCollectionViewCell {
    func updateWithObject(_ obj:Any)
}

public protocol ByvMapListDelegate {
    func cellHeight() -> CGFloat;
    func cellNibName() -> String;
    func pinImage(_ item:MKAnnotation, selected:Bool) -> ByvPinImage
    func itemSelected(_ item:MKAnnotation)
}

public class ByvMapListView: UIView, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let minListTop: CGFloat = 44.0
    
    //Change to real Cell
    var cellHeight: CGFloat = 120.0
    
    //Map
    public var mapView: MKMapView = MKMapView()
    public var selectedScale:CGFloat = 2.0
    public var listMapAlpha:CGFloat = 0.8
    private var selectedItem:MKAnnotation? = nil
    private var timer:Timer? = nil
    private var fromList = false
    
    public var collectionView:UICollectionView? = nil
    public var delegate:ByvMapListDelegate? = nil
    
    let cellIdentifier:String = "mapListCell"
    private var items:Array<Any> = []
    private var listView: UIView = UIView()
    private var headerView: UIView = UIView()
    private var listState:ByvListState = .header
    //public var collection:UICollectionView = UICollectionView()
    
    public func reSetItems(_ newItems: Array<Any>) {
        items = newItems
        collectionView?.reloadData()
        collectionView?.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(items as! [MKAnnotation])
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    public func load(_ delegate:ByvMapListDelegate) {
        self.delegate = delegate
        
        self.backgroundColor = UIColor.black
        
        //Map
        mapView.addTo(self)
        mapView.delegate = self
        
        //listView
        var separator = UIView()
        separator.backgroundColor = UIColor.gray
        separator.layer.cornerRadius = 3
        
        separator.addTo(listView, position: .top, insets: UIEdgeInsetsMake(6, 0, 0, 0), centered: true, width: 40.0, height: 6.0)
        
        var label = UILabel()
        label.text = "Prueba de Texto"
        
        label.addTo(headerView, position: .all, centered: true)
        
        headerView.backgroundColor = UIColor.lightGray
        headerView.setHeight(50)
        
        cellHeight = delegate.cellHeight()
        var flowLayout = ByvFlowLayout()
        flowLayout.height = cellHeight
        flowLayout.width = self.bounds.size.width
        
        let collView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collView.delegate = self
        collView.dataSource = self
        collView.backgroundColor = UIColor.orange
        collView.isPagingEnabled = false
        
        collView.register(UINib.init(nibName: delegate.cellNibName(), bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        
        collectionView = collView
        collectionView!.delegate = self
        
        listView.addTo(self, position: .bottom, height: self.headerHeight())
        listView.backgroundColor = UIColor.white
        listView.layer.cornerRadius = 20.0
        listView.addShadow(opacity: 0.5, radius: 5.0)
        
        listView.add(subViews: [headerView, collView], insets: UIEdgeInsetsMake(20, 0, 0, 0))
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panHandler(sender:)))
        listView.addGestureRecognizer(pan)
    }
    
    func changeToState(_ newState: ByvListState, animated:Bool = true) {
        let flowLayout = collectionView?.collectionViewLayout as! ByvFlowLayout
        if listState != newState {
            if newState == .single {
                flowLayout.direction = .horizontal
                collectionView?.isPagingEnabled = true
            } else {
                flowLayout.direction = .vertical
                collectionView?.isPagingEnabled = false
            }
        }
        
        // Update Frame
        listState = newState
        var height:CGFloat = 0.0
        switch listState {
        case .header:
            height = self.headerHeight()
            if selectedItem != nil {
                mapView.deselectAnnotation(selectedItem, animated: true)
                selectedItem = nil
            }
        case .single:
            height = self.headerHeight() + self.cellHeight
        case .list:
            height = self.bounds.size.height - minListTop
        }
            
        if animated {
            var frame = self.listView.frame
            let diff = height - frame.size.height
            if diff != 0 {
                frame.origin.y -= diff
                frame.size.height += diff
                UIView.animate(withDuration: 0.3, animations: {
                    self.listView.height()?.constant = height
                    if diff < 0 {
                        self.listView.layoutIfNeeded()
                    } else {
                        self.listView.frame = frame
                    }
                    if self.listState == .list {
                        self.mapView.alpha = self.listMapAlpha
                    } else {
                        self.mapView.alpha = 1.0
                    }
                }, completion: { (finished) in
                    self.stateChanged()
                })
            }
        } else {
            self.listView.height()?.constant = height
            if listState == .list {
                mapView.alpha = listMapAlpha
            } else {
                mapView.alpha = 1.0
            }
            stateChanged()
        }
    }
    
    func stateChanged() {
        collectionView?.collectionViewLayout.invalidateLayout()
        if self.listState == .single && selectedItem != nil {
            Timer.scheduledTimer(timeInterval: 0.1, target:self, selector: #selector(self.scrollToSelected), userInfo: nil, repeats: false)
            if fromList {
                fromList = false
                if delegate != nil {
                    delegate?.itemSelected(selectedItem!)
                }
            }
        } else if listState == .header {
            collectionView?.collectionViewLayout.invalidateLayout()
            collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
    
    var startY:CGFloat = 0.0
    
    func panHandler(sender: UIPanGestureRecognizer) {
        
        if sender.state == .began {
            startY = sender.location(in: listView).y
            if listState == .single {
                let flowLayout = collectionView?.collectionViewLayout as! ByvFlowLayout
                flowLayout.direction = .vertical
                collectionView?.isPagingEnabled = false
                collectionView?.collectionViewLayout.invalidateLayout()
                collectionView?.scrollToItem(at: IndexPath(row: indexOfSelectedItem(), section: 0), at: .top, animated: false)
            }
        }
        
        if sender.state == .changed {
            let height = getListHeight(sender.location(in: self))
            listView.height()?.constant = height
            var alpha:CGFloat = 1.0
            let heightDiff = height - self.headerHeight() - cellHeight
            let max = self.bounds.size.height - minListTop - self.headerHeight() - cellHeight
            alpha = 1.0 - ((heightDiff / max) * (1.0 - listMapAlpha))
            if alpha > 1.0 {
                alpha = 1.0
            }
            mapView.alpha = alpha
        }
        
        if sender.state == .ended {
            var height = getListHeight(sender.location(in: self)) - headerHeight()
            updateListWithHeight(height)
        }
    }
    
    func indexOfSelectedItem() -> Int {
        let index = items.index { (item) -> Bool in
            return item as! NSObject === selectedItem as! NSObject
        }
        var result = 0
        if let index = index {
            result = index
        }
        return result
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
    
    public func updateListWithHeight(_ height:CGFloat) {
        if self.listState == .list {
            let max = self.bounds.size.height - minListTop
            if height < max - cellHeight * 1.5 {
                if selectedItem != nil {
                    changeToState(.single)
                } else {
                    changeToState(.header)
                }
            } else {
                changeToState(.list)
            }
        } else if self.listState == .header {
            let max = self.bounds.size.height - minListTop
            if height > cellHeight {
                changeToState(.list)
            } else {
                changeToState(.header)
            }
        } else if self.listState == .single {
            let max = self.bounds.size.height - minListTop
            if height > cellHeight * 1.5 {
                changeToState(.list)
            } else if height < cellHeight * 0.5 {
                changeToState(.header)
            } else {
                changeToState(.single)
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : ByvMapListCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ByvMapListCollectionViewCell
        
        cell.updateWithObject(items[indexPath.row])
        
        return cell as! UICollectionViewCell
    }
    
    func scrollToSelected() {
        var rect = collectionView!.bounds
        rect.origin.x = UIScreen.main.bounds.size.width * CGFloat(indexOfSelectedItem())
        if collectionView?.contentOffset.x != rect.origin.x {
            collectionView?.scrollRectToVisible(rect, animated: true)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if listState == .single {
            let index = Int(scrollView.contentOffset.x / self.bounds.size.width)
            let newItem = items[index] as! MKAnnotation
            if selectedItem == nil || selectedItem as! NSObject != newItem as! NSObject {
                selectedItem = newItem
                mapView.selectAnnotation(newItem, animated: true)
            }
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            listView.height()?.constant += scrollView.contentOffset.y
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if listState != .single {
            if !decelerate {
                var height = (listView.height()?.constant)!
                updateListWithHeight(height)
            }
        }
    }
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        var offset:CGPoint = CGPoint(x: 0, y: 0)
        mapView.setCenter(view.annotation!.coordinate, animated: true)
        if let pinImage = delegate?.pinImage(view.annotation!, selected: true) {
            view.image = pinImage.0
            offset = pinImage.1
        }
        if self.selectedScale != 1 {
            UIView.animate(withDuration: 0.3, animations: {
                let transform:CGAffineTransform = CGAffineTransform.identity
                view.transform = transform
                view.centerOffset = offset
            })
        }
        if selectedItem == nil || selectedItem as! NSObject != view.annotation as! NSObject {
            selectedItem = view.annotation
            if listState != .single {
                changeToState(.single)
            } else {
                scrollToSelected()
            }
        }
    }
    
    public func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let pinImage = delegate?.pinImage(view.annotation!, selected: false) {
            view.image = pinImage.0
            view.centerOffset = pinImage.1
        }
        UIView.animate(withDuration: 0.3, animations: {
            let transform:CGAffineTransform = CGAffineTransform.init(scaleX: 1.0/self.selectedScale, y: 1.0/self.selectedScale)
            view.transform = transform
            var offset = view.centerOffset
            offset.x /= self.selectedScale
            offset.y /= self.selectedScale
            view.centerOffset = offset
        })
        selectedItem = nil
        timer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector: #selector(deselectAnnotation(_:)), userInfo: nil, repeats: false)
    }
    
    func deselectAnnotation(_ timer:Timer?) {
        if listState == .single && selectedItem == nil {
            changeToState(.header)
        }
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't want to show a custom image if the annotation is the user's location.
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        // Better to make this class property
        let annotationIdentifier = "AnnotationIdentifier"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }
        
        if let annotationView = annotationView {
            // Configure your annotation view here
            annotationView.canShowCallout = false
            if let pinImage = delegate?.pinImage(annotation, selected: (selectedItem != nil && selectedItem as! NSObject == annotation as! NSObject)) {
                annotationView.image = pinImage.0
                var offset = pinImage.1
                offset.x /= self.selectedScale
                offset.y /= self.selectedScale
                annotationView.centerOffset = offset
                let transform:CGAffineTransform = CGAffineTransform.init(scaleX: 1.0/self.selectedScale, y: 1.0/self.selectedScale)
                annotationView.transform = transform
            }
        }
        
        return annotationView
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = items[indexPath.row] as? MKAnnotation {
            if listState == .list {
                fromList = true
                mapView.selectAnnotation(item, animated: true)
            } else {
                if delegate != nil {
                    delegate?.itemSelected(item)
                }
            }
        }
        
    }
    
    // Show compass below top toolbar
//    override var topLayoutGuide: UILayoutSupport {
//        let navigationBarOffset = (navigationController != nil) ? CGRectGetMaxY(navigationController!.navigationBar.frame) : 0
//        let itemOffset = topItemHeight ?? 0
//        return MapLayoutGuide(insetLength: navigationBarOffset + itemOffset)
//    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
