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
import BvMapCluster
import ClusterKit

class MyLayoutGuide: NSObject, UILayoutSupport {
    var insetLength: CGFloat = 0
    
    init(insetLength: CGFloat) {
        self.insetLength = insetLength
    }
    
    var length: CGFloat {
        return insetLength
    }
    
    @available(iOS 9.0, *)
    var bottomAnchor: NSLayoutYAxisAnchor {
        return self.bottomAnchor
    }
    
    @available(iOS 9.0, *)
    var topAnchor: NSLayoutYAxisAnchor {
        return self.topAnchor
    }
    
    @available(iOS 9.0, *)
    var heightAnchor: NSLayoutDimension {
        return self.heightAnchor
    }
}

@objc public enum ByvListState: Int {
    case header
    case single
    case list
}

public protocol ByvMapListCollectionViewCell {
    func updateWithObject(_ obj:Any, listState:ByvListState, at indexPath:IndexPath)
}

@objc public protocol ByvMapListDelegate {
    func cellHeight() -> CGFloat
    func cellNibName() -> String
    func pinView(mapView: MKMapView, annotation:MKAnnotation, selected:Bool) -> MKAnnotationView?
    @objc optional func itemSelected(_ item:MKAnnotation)
    @objc optional func didScrollToEnd()
    @objc optional func selectPinView(annotationView: MKAnnotationView)
    @objc optional func deSelectPinView(annotationView: MKAnnotationView)
    @objc optional func listStateDidChange(_ newState: ByvListState)
}

public protocol ByvMapListDataSource {
    func annotationsInRegion(visibleMapRect: MKMapRect) -> [MKAnnotation]
}

public class ByvMapListView: UIView {
    
    // Map
    lazy public var mapView: MKMapView = {
        let map = MKMapView()
        let algorithm = CKNonHierarchicalDistanceBasedAlgorithm()
        algorithm.cellSize = 400
        map.clusterManager.algorithm = algorithm
        map.clusterManager.marginFactor = 1
        map.clusterManager.maxZoomLevel = 16
        return map
    }()
    @IBInspectable public var selectedScale: CGFloat = 2.0
    @IBInspectable public var listMapAlpha:CGFloat = 0.8
    
    @IBInspectable public var updateRegionAutomatically:Bool = true
    @IBInspectable public var centerRegionAtPoint:Bool = false
    public var regionCenterPoint:CLLocationCoordinate2D? = nil
    @IBInspectable public var regionRadius:Double = 0.0
    @IBInspectable public var showUserInRegion:Bool = true
    @IBInspectable public var maxAnnotationsInRegion:Int = 0
    
    public var _explorationMode:Bool = false
    public var explorationMode:Bool {
        get {
            return _explorationMode
        }
        set {
            if _explorationMode != newValue {
                _explorationMode = newValue
                print("_explorationMode = \(_explorationMode)")
                if _explorationMode {
                    centerInSelectedPoi = false
                } else if _showClustersUser {
                    showClusters = true
                } else {
                    _centerInSelectedPoi = _centerInSelectedPoiUser
                }
            }
        }
    }
    
    @IBInspectable public var clusterColor: UIColor? = nil
    var _showClustersUser:Bool = false
    var _showClusters:Bool = false
    public var showClusters:Bool {
        get {
            return _showClusters
        }
        set {
            if _showClusters != newValue {
                _showClustersUser = newValue
                _showClusters = newValue
                reloadClusters()
            }
        }
    }
    
    private func reloadClusters() {
        if _showClusters {
            //Add to manager
            mapView.removeAnnotations(mapView.annotations)
            mapView.clusterManager.annotations = items as! [CKAnnotation]
            mapView.clusterManager.updateClustersIfNeeded()
        } else {
            //Remove from manager
            mapView.addAnnotations(items)
            mapView.clusterManager.annotations = []
            mapView.clusterManager.updateClustersIfNeeded()
        }
    }
    
    
    var _centerInSelectedPoiUser = true
    var _centerInSelectedPoi = true
    public var centerInSelectedPoi:Bool {
        get {
            return _centerInSelectedPoi
        }
        set {
            _centerInSelectedPoiUser = newValue
            if !newValue || (!_explorationMode && !_showClusters) {
                _centerInSelectedPoi = newValue
            }
        }
    }
    
    @IBInspectable public var showUserLocation:Bool = false {
        didSet {
            mapView.showsUserLocation = showUserLocation
        }
    }
    
    var mapDelegates:[MKMapViewDelegate] = []
    var selectedItem:MKAnnotation? = nil
    var timer:Timer? = nil
    var fromList = false
    
    var userLocatedFirstTime = false
    
    // Collection
    public var collectionView:UICollectionView? = nil
    public var delegate:ByvMapListDelegate? = nil
    public var dataSource:ByvMapListDataSource? = nil
    public var minListTop: CGFloat = 70.0
    var _listColor: UIColor = UIColor.white
    @IBInspectable public var listColor: UIColor = .white {
        didSet {
            _listColor = listColor
            headerView.backgroundColor = _listColor
            if let collView = collectionView {
                collView.backgroundColor = _listColor
            }
            listView.backgroundColor = _listColor
        }
    }
    var _listTopCornerRadius: CGFloat = 8.0
    public var listTopCornerRadius: CGFloat {
        get {
            return _listTopCornerRadius
        }
        set(newValue) {
            _listTopCornerRadius = newValue
            listView.layer.cornerRadius = listTopCornerRadius
        }
    }
    
    var cellHeight: CGFloat = 120.0
    let cellIdentifier:String = "mapListCell"
    var items:Array<MKAnnotation> = []
    public var listView: UIView = UIView()
    var headerView: UIView = UIView()
    @IBOutlet public var xibHeader: UIView?
    var listState:ByvListState = .header
    var prePanListState:ByvListState = .header
    var isScrollToEndAlerted:Bool = false
    
    public func bottomLayoutGuide() -> UILayoutSupport {
        return LayoutGuide(length: self.listView.bounds.size.height)
    }
    
    public func addMapDelegate(newDelegate:MKMapViewDelegate) {
        for del in mapDelegates {
            if newDelegate === del {
                return
            }
        }
        mapDelegates.append(newDelegate)
    }
    
    public func removeMapDelegate(removeDelegate:MKMapViewDelegate) {
        for i in 0...mapDelegates.count - 1 {
            if removeDelegate === mapDelegates[i] {
                mapDelegates.remove(at: i)
                return
            }
        }
    }
    
    public func allItems() -> Array<MKAnnotation> {
        return items
    }
    
    public func reloadCollectionViewLayout() {
        let height = (listView.height()?.constant)! - headerHeight()
        updateListWithHeight(height)
        if let delegate = delegate {
            cellHeight = delegate.cellHeight()
        }
        if let flowLayout = collectionView?.collectionViewLayout as? ByvFlowLayout {
            flowLayout.height = cellHeight
            flowLayout.width = self.bounds.size.width
            collectionView?.collectionViewLayout.invalidateLayout()
            if let visibles = collectionView?.indexPathsForVisibleItems {
                collectionView?.reloadItems(at:visibles)
            }
        }
        if listState == .single {
            scrollToSelected()
        }
    }
    
    public func reSetItems(_ newItems: Array<MKAnnotation>) {
        isScrollToEndAlerted = false
        selectedItem = nil
        if self.listState == .single {
            changeToState(.header)
        }
        items = newItems
        collectionView?.reloadData()
        if items.count > 0 {
            collectionView?.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        }
        if _showClusters {
            mapView.clusterManager.annotations = newItems as! [CKAnnotation]
        } else {
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(items)
        }
        updateRegion()
    }
    
    public func addMoreItems(_ newItems: Array<MKAnnotation>) {
        isScrollToEndAlerted = false
        let preCount = items.count
        items.append(contentsOf: newItems)
        var rows:Array<IndexPath> = []
        for row in preCount...items.count - 1 {
            rows.append(IndexPath(row: row, section: 0))
        }
        collectionView?.insertItems(at: rows)
        if _showClusters {
            mapView.clusterManager.addAnnotations(newItems as! [CKAnnotation])
        } else {
            mapView.addAnnotations(newItems)
        }
        updateRegion()
    }
    
    public func updateRegion(_ animated:Bool = true) {
        if (updateRegionAutomatically) {
            if centerRegionAtPoint {
                var loc = regionCenterPoint
                if loc == nil {
                    loc = mapView.userLocation.coordinate
                }
                if let loc = loc {
                    let region = MKCoordinateRegionMakeWithDistance(loc, regionRadius, regionRadius)
                    mapView.setRegion(region, animated: animated)
                    return
                }
            } else {
                var itemsToShow:[MKAnnotation] = items
                if maxAnnotationsInRegion > 0 {
                    itemsToShow = []
                    var to = maxAnnotationsInRegion
                    if items.count < maxAnnotationsInRegion {
                        to = items.count
                    }
                    if to > 0 {
                        for i in 1...to {
                            itemsToShow.append(items[i - 1])
                        }
                    }
                }
                if showUserInRegion {
                    if mapView.userLocation.coordinate.latitude != 0.0 && mapView.userLocation.coordinate.longitude != 0.0 {
                        itemsToShow.append(mapView.userLocation)
                    }
                }
                mapView.showAnnotations(itemsToShow, animated: animated)
                if _showClusters {
                    mapView.removeAnnotations(itemsToShow)
                }
            }
        }
    }
    
    public func addHeaderView(_ newHeader: UIView) {
        for view in headerView.subviews {
            view.removeFromSuperview()
        }
        headerView.setHeight(newHeader.bounds.size.height)
        newHeader.removeFromSuperview()
        newHeader.addTo(headerView)
    }
    
    public func load(_ delegate:ByvMapListDelegate) {
        self.delegate = delegate
        
        self.backgroundColor = UIColor.black
        
        //Map
        mapView.addTo(self)
        mapView.delegate = self
        self.sendSubview(toBack: mapView)
        
        //listView
        let separator = UIView()
        separator.backgroundColor = UIColor.gray
        separator.layer.cornerRadius = 3
        
        separator.addTo(listView, position: .top, insets: UIEdgeInsetsMake(6, 0, 0, 0), centered: true, width: 40.0, height: 6.0)
        
        headerView.backgroundColor = listColor
        headerView.setHeight(25)
        if let view = xibHeader {
            self.addHeaderView(view)
        }
        
        cellHeight = delegate.cellHeight()
        let flowLayout = ByvFlowLayout()
        flowLayout.height = cellHeight
        flowLayout.width = self.bounds.size.width
        
        let collView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collView.delegate = self
        collView.dataSource = self
        collView.backgroundColor = listColor
        collView.isPagingEnabled = false
        
        collView.register(UINib.init(nibName: delegate.cellNibName(), bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        
        collectionView = collView
        collectionView!.delegate = self
        
        listView.addTo(self, position: .bottom, height: self.headerHeight())
        listView.backgroundColor = listColor
        listView.layer.cornerRadius = listTopCornerRadius
        listView.addShadow(opacity: 0.1, radius: 2.0)
        listView.layer.shadowOffset = CGSize(width: 0, height: -4)
        
        listView.add(subViews: [headerView, collView], insets: UIEdgeInsetsMake(20, 0, 0, 0))
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panHandler(sender:)))
        listView.addGestureRecognizer(pan)
        
        self.reloadCollectionViewLayout()
    }
    
    public func showFullList(animated: Bool = true) {
        self.changeToState(.list, animated: animated)
    }
    
    public func hideList(animated: Bool = true) {
        self.changeToState(.header, animated: animated)
    }
    
    func changeToState(_ newState: ByvListState, animated:Bool = true) {
        let flowLayout = collectionView?.collectionViewLayout as! ByvFlowLayout
        //        if listState != newState {
        if newState == .single {
            flowLayout.direction = .horizontal
            collectionView?.isPagingEnabled = true
        } else {
            flowLayout.direction = .vertical
            collectionView?.isPagingEnabled = false
        }
        //        }
        
        // Update Frame
        listState = newState
        prePanListState = newState
        var height:CGFloat = 0.0
        switch listState {
        case .header:
            height = self.headerHeight()
            if selectedItem != nil {
                if _showClusters {
                    mapView.clusterManager.deselectAnnotation((selectedItem as! CKAnnotation), animated: true)
                } else {
                    mapView.deselectAnnotation(selectedItem, animated: true)
                }
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
        self.mapView.setNeedsLayout()
        self.mapView.layoutIfNeeded()
        collectionView?.collectionViewLayout.invalidateLayout()
        if let visibles = collectionView?.indexPathsForVisibleItems {
            collectionView?.reloadItems(at:visibles)
        }
        if self.listState == .single, let selectedItem = selectedItem {
            Timer.scheduledTimer(timeInterval: 0.1, target:self, selector: #selector(self.scrollToSelected), userInfo: nil, repeats: false)
            if fromList {
                fromList = false
                if delegate != nil {
                    delegate?.itemSelected?(selectedItem)
                }
            }
        } else if listState == .header {
            collectionView?.collectionViewLayout.invalidateLayout()
            if let visibles = collectionView?.indexPathsForVisibleItems {
                collectionView?.reloadItems(at:visibles)
            }
            if items.count > 0 {
                collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }
        delegate?.listStateDidChange?(self.listState)
        //        collectionView?.reloadData()
    }
    
    var startY:CGFloat = 0.0
    
    @objc func panHandler(sender: UIPanGestureRecognizer) {
        
        if sender.state == .began {
            startY = sender.location(in: listView).y
            prePanListState = listState
            if listState == .single {
                listState = .list
                let flowLayout = collectionView?.collectionViewLayout as! ByvFlowLayout
                flowLayout.direction = .vertical
                collectionView?.isPagingEnabled = false
                collectionView?.collectionViewLayout.invalidateLayout()
                if let visibles = collectionView?.indexPathsForVisibleItems {
                    collectionView?.reloadItems(at:visibles)
                }
                if items.count > 0 {
                    collectionView?.scrollToItem(at: IndexPath(row: indexOfSelectedItem(), section: 0), at: .top, animated: false)
                }
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
            let height = getListHeight(sender.location(in: self)) - headerHeight()
            updateListWithHeight(height)
        }
    }
    
    func indexOfSelectedItem() -> Int {
        if selectedItem != nil {
            let index = items.index { (item) -> Bool in
                return item as! NSObject === selectedItem as! NSObject
            }
            var result = 0
            if let index = index {
                result = index
            }
            return result
        } else  {
            return 0
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
    
    public func updateListWithHeight(_ height:CGFloat) {
        if self.prePanListState == .list {
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
        } else if self.prePanListState == .header {
            if height > cellHeight {
                changeToState(.list)
            } else {
                changeToState(.header)
            }
        } else if self.prePanListState == .single {
            if height > cellHeight * 1.5 {
                changeToState(.list)
            } else if height < cellHeight * 0.5 {
                changeToState(.header)
            } else {
                changeToState(.single)
            }
        }
    }
    
    @objc func scrollToSelected() {
        var rect = collectionView!.bounds
        rect.origin.x = UIScreen.main.bounds.size.width * CGFloat(indexOfSelectedItem())
        if collectionView?.contentOffset.x != rect.origin.x {
            collectionView?.scrollRectToVisible(rect, animated: true)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if listState == .single {
            let index = Int(scrollView.contentOffset.x / self.bounds.size.width)
            let newItem = items[index]
            if selectedItem == nil || selectedItem as! NSObject != newItem as! NSObject {
                selectedItem = newItem
                if _showClusters {
                    mapView.clusterManager.selectAnnotation((newItem as! CKAnnotation), animated: true)
                } else {
                    mapView.selectAnnotation(newItem, animated: true)
                }
            }
        } else {
            let height = (listView.height()?.constant)! - headerHeight()
            updateListWithHeight(height)
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            listView.height()?.constant += scrollView.contentOffset.y
        }
        
        if listState == .list {
            //Check vertically
            if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height - cellHeight && !isScrollToEndAlerted {
                isScrollToEndAlerted = true
                if delegate != nil {
                    delegate?.didScrollToEnd?()
                }
            }
        } else if listState == .single {
            //Check horizontally
            if scrollView.contentOffset.x >= scrollView.contentSize.width - scrollView.bounds.size.width && !isScrollToEndAlerted {
                isScrollToEndAlerted = true
                if delegate != nil {
                    delegate?.didScrollToEnd?()
                }
            }
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if listState != .single {
            if !decelerate {
                let height = (listView.height()?.constant)! - headerHeight()
                updateListWithHeight(height)
            }
        }
    }
    
    // Show compass below top toolbar
    //    override var topLayoutGuide: UILayoutSupport {
    //        let navigationBarOffset = (navigationController != nil) ? CGRectGetMaxY(navigationController!.navigationBar.frame) : 0
    //        let itemOffset = topItemHeight ?? 0
    //        return MapLayoutGuide(insetLength: navigationBarOffset + itemOffset)
    //    }
    
}


// MARK: UICollectionViewDataSource

extension ByvMapListView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : ByvMapListCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ByvMapListCollectionViewCell
        
        cell.updateWithObject(items[indexPath.row], listState: listState, at: indexPath)
        
        return cell as! UICollectionViewCell
    }
}


// MARK: UICollectionViewDelegate

extension ByvMapListView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if listState == .list {
            fromList = true
            let newItem = items[indexPath.row]
            if selectedItem != nil {
                if _showClusters {
                    mapView.clusterManager.deselectAnnotation((selectedItem as! CKAnnotation), animated: true)
                } else {
                    mapView.deselectAnnotation(selectedItem, animated: true)
                }
            }
            if _showClusters {
                mapView.clusterManager.selectAnnotation((newItem as! CKAnnotation), animated: true)
            } else {
                mapView.selectAnnotation(newItem, animated: true)
            }
        } else {
            if delegate != nil {
                delegate?.itemSelected?(items[indexPath.row])
            }
        }
    }
}


// MARK: MKMapViewDelegate

extension ByvMapListView: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't want to show a custom image if the annotation is the user's location.
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let reuseId = "Cluster"
        if let cluster = annotation as? CKCluster {
            if cluster.count > 1 {
                var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
                if clusterView == nil {
                    if let clusterColor = clusterColor {
                        clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, configuration: FBAnnotationClusterViewConfiguration.default(color: clusterColor))
                    } else {
                        clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, configuration: FBAnnotationClusterViewConfiguration.default())
                    }
                } else {
                    clusterView?.annotation = annotation
                }
                return clusterView
            }
        }
        var annotationView: MKAnnotationView? = delegate?.pinView(mapView: mapView, annotation: annotation, selected: (selectedItem != nil && selectedItem as! NSObject == annotation as! NSObject))
        if annotationView == nil {
            // Better to make this class property
            if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) {
                annotationView = dequeuedAnnotationView
                annotationView?.annotation = annotation
            } else {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            }
        }
        
        if let annotationView = annotationView {
            var offset = annotationView.centerOffset
            offset.x /= self.selectedScale
            offset.y /= self.selectedScale
            annotationView.centerOffset = offset
            let transform:CGAffineTransform = CGAffineTransform.init(scaleX: 1.0/self.selectedScale, y: 1.0/self.selectedScale)
            annotationView.transform = transform
        }
        
        return annotationView
    }
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard !(view.annotation is MKUserLocation) else {
            return
        }
        if _showClusters, let cluster = view.annotation as? CKCluster {
            if cluster.count > 1 {
                mapView.showCluster(cluster, animated: true)
                return
            } else {
                self.mapView.clusterManager.selectAnnotation(cluster.firstAnnotation!, animated: false)
            }
        }
        delegate?.selectPinView?(annotationView: view)
        if _centerInSelectedPoi {
            mapView.setCenter(view.annotation!.coordinate, animated: true)
        }
        if self.selectedScale != 1 {
            UIView.animate(withDuration: 0.3, animations: {
                let transform:CGAffineTransform = CGAffineTransform.identity
                view.transform = transform
                var offset = view.centerOffset
                offset.x *= self.selectedScale
                offset.y *= self.selectedScale
                view.centerOffset = offset
            })
        }
        if selectedItem == nil || selectedItem as! NSObject != view.annotation as! NSObject {
            if let cluster = view.annotation as? CKCluster {
                selectedItem = cluster.firstAnnotation
            } else {
                selectedItem = view.annotation
            }
            if listState != .single {
                changeToState(.single)
            } else {
                scrollToSelected()
            }
        }
    }
    
    
    public func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard !(view.annotation is MKUserLocation) else {
            return
        }
        delegate?.deSelectPinView?(annotationView: view)
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
    
    @objc func deselectAnnotation(_ timer:Timer?) {
        if listState == .single && selectedItem == nil {
            changeToState(.header)
        }
    }
    
    
    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        for del in mapDelegates {
            if del.responds(to: #selector(mapView(_:regionWillChangeAnimated:))) {
                del.mapView!(mapView, regionWillChangeAnimated: animated)
                return
            }
        }
    }
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if _explorationMode, let items = dataSource?.annotationsInRegion(visibleMapRect: mapView.visibleMapRect) {
            self.items = items
            self.collectionView?.reloadData()
            if _showClusters {
                mapView.clusterManager.annotations = items as! [CKAnnotation]
                mapView.clusterManager.updateClustersIfNeeded()
            } else {
                mapView.removeAnnotations(mapView.annotations)
                mapView.addAnnotations(items)
            }
        }
        if _showClusters {
            mapView.clusterManager.updateClustersIfNeeded()
        }
        for del in mapDelegates {
            if del.responds(to: #selector(mapView(_:regionDidChangeAnimated:))) {
                del.mapView!(mapView, regionDidChangeAnimated: animated)
                return
            }
        }
    }
    public func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        for del in mapDelegates {
            if del.responds(to: #selector(mapViewWillStartLoadingMap(_:))) {
                del.mapViewWillStartLoadingMap!(mapView)
                return
            }
        }
    }
    public func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        for del in mapDelegates {
            if del.responds(to: #selector(mapViewDidFinishLoadingMap(_:))) {
                del.mapViewDidFinishLoadingMap!(mapView)
                return
            }
        }
    }
    public func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        for del in mapDelegates {
            if del.responds(to: #selector(mapViewDidFailLoadingMap(_:withError:))) {
                del.mapViewDidFailLoadingMap!(mapView, withError: error)
                return
            }
        }
    }
    public func mapViewWillStartRenderingMap(_ mapView: MKMapView){
        for del in mapDelegates {
            if del.responds(to: #selector(mapViewWillStartRenderingMap(_:))) {
                del.mapViewWillStartRenderingMap!(mapView)
                return
            }
        }
    }
    public func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool){
        for del in mapDelegates {
            if del.responds(to: #selector(mapViewDidFinishRenderingMap(_:fullyRendered:))) {
                del.mapViewDidFinishRenderingMap!(mapView, fullyRendered: fullyRendered)
                return
            }
        }
    }
    public func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for del in mapDelegates {
            if del.responds(to: #selector(mapView(_:didAdd:) as (MKMapView, [MKAnnotationView]) -> Void)) {
                del.mapView!(mapView, didAdd: views)
                return
            }
        }
    }
    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        for del in mapDelegates {
            if del.responds(to: #selector(mapView(_:annotationView:calloutAccessoryControlTapped:))) {
                del.mapView!(mapView, annotationView: view, calloutAccessoryControlTapped: control)
                return
            }
        }
    }
    public func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
        for del in mapDelegates {
            if del.responds(to: #selector(mapViewWillStartLocatingUser(_:))) {
                del.mapViewWillStartLocatingUser!(mapView)
                return
            }
        }
    }
    public func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
        for del in mapDelegates {
            if del.responds(to: #selector(mapViewDidStopLocatingUser(_:))) {
                del.mapViewDidStopLocatingUser!(mapView)
                return
            }
        }
    }
    public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !userLocatedFirstTime {
            userLocatedFirstTime = true
            if (centerRegionAtPoint && regionCenterPoint == nil) || (!centerRegionAtPoint && showUserInRegion) {
                updateRegion()
            }
        }
        for del in mapDelegates {
            if del.responds(to: #selector(mapView(_:didUpdate:))) {
                del.mapView!(mapView, didUpdate: userLocation)
                return
            }
        }
    }
    public func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        for del in mapDelegates {
            if del.responds(to: #selector(mapView(_:didFailToLocateUserWithError:))) {
                del.mapView!(mapView, didFailToLocateUserWithError: error)
                return
            }
        }
    }
    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        for del in mapDelegates {
            if del.responds(to: #selector(mapView(_:annotationView:didChange:fromOldState:))) {
                del.mapView!(mapView, annotationView: view, didChange: newState, fromOldState: oldState)
                return
            }
        }
    }
    public func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        for del in mapDelegates {
            if del.responds(to: #selector(mapView(_:didChange:animated:))) {
                del.mapView!(mapView, didChange: mode, animated: animated)
                return
            }
        }
    }
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        for del in mapDelegates {
            if del.responds(to: #selector(mapView(_:rendererFor:))) {
                return del.mapView!(mapView, rendererFor:overlay)
            }
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
    public func mapView(_ mapView: MKMapView, didAdd renderers: [MKOverlayRenderer]){
        for del in mapDelegates {
            if del.responds(to: #selector(mapView(_:didAdd:) as (MKMapView, [MKOverlayRenderer]) -> Void)) {
                del.mapView!(mapView, didAdd: renderers)
            }
        }
    }
}
