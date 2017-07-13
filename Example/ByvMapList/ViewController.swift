//
//  ViewController.swift
//  ByvMapList
//
//  Created by Adrian Apodaca macbook air on 11/27/2016.
//  Copyright (c) 2016 Adrian Apodaca macbook air. All rights reserved.
//

import UIKit
import MapKit
import ByvMapList
import SwiftyJSON
import CoreLocation

class ViewController: UIViewController, ByvMapListDelegate, MKMapViewDelegate {

    @IBOutlet var byvMapListView: ByvMapListView!
    
    let locationManager = CLLocationManager()
    var secondPageLoaded:Bool = false
    var headerView = ListHeader.instanceFromNib()
    
    let pin:UIImage = UIImage(named: "pin")!
    let selectedPin:UIImage = UIImage(named: "pin_selected")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        
        byvMapListView.minListTop = 44.0
        byvMapListView.load(self)
        byvMapListView.listColor = UIColor.white
        
        byvMapListView.showUserLocation = true
        
//        byvMapListView.centerRegionAtPoint = true
//        byvMapListView.regionCenterPoint = CLLocationCoordinate2D(latitude: 43.170556, longitude: -2.597556)
//        byvMapListView.regionRadius = 5000
        
        byvMapListView.showUserInRegion = false
//        byvMapListView.maxAnnotationsInRegion = 3
        
        let button = headerView.viewWithTag(10) as! UIButton
        button.addTarget(self, action: #selector(showSortList), for: .touchUpInside)
        byvMapListView.addHeaderView(headerView)
        refresh(self)
    }
    
    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print("mapView regionWillChangeAnimated!!!")
    }
    
    func pressed() {
        print("PRESSED!!!!")
    }

    @IBAction func refresh(_ sender: Any) {
        secondPageLoaded = false
        if let path = Bundle.main.path(forResource: "stations", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                var items = JSON.init(data: data).arrayValue.map({ (json) -> GasStation in
                    return GasStation.init(fromJson: json)
                })
                if let loc = locationManager.location {
                    items = items.sorted { loc.distance(from: CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude))  < loc.distance(from: CLLocation(latitude: $1.coordinate.latitude, longitude: $1.coordinate.longitude)) }
                }
                byvMapListView.reSetItems(items)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        byvMapListView.reloadCollectionViewLayout()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            self.byvMapListView.reloadCollectionViewLayout()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showSortList() {
        let actionSheet = UIAlertController(title: "Sort by", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Name", style: .default, handler: { (action) in
            var items = self.byvMapListView.allItems()
            items.sort {
                let a = $0 as! GasStation
                let b = $1 as! GasStation
                
                return a.name < b.name
            }
            self.byvMapListView.reSetItems(items)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
            actionSheet.dismiss(animated: true, completion: nil)
        }))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func cellHeight() -> CGFloat {
        return 120.0
    }
    
    func cellNibName() -> String {
        return "StationCell"
    }
    
    func pinView(mapView: MKMapView, annotation: MKAnnotation, selected: Bool) -> MKAnnotationView? {
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView: MKAnnotationView? = nil
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        } else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }
        if let annotationView = annotationView {
            if selected {
                annotationView.image = selectedPin
            } else {
                annotationView.image = pin
            }
            let y = -annotationView.image!.size.height / 2.0
            let offset = CGPoint(x: 0, y: y)
            annotationView.centerOffset = offset
        }
        
        return annotationView
    }
    
    func selectPinView(annotationView: MKAnnotationView) {
        annotationView.image = selectedPin
    }
    
    func deSelectPinView(annotationView: MKAnnotationView) {
        annotationView.image = pin
    }
    
    func itemSelected(_ item:MKAnnotation) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
        vc.gasStation = item as? GasStation
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didScrollToEnd() {
        // Load more
        print("Scrolled to End")
        if !secondPageLoaded {
            secondPageLoaded = true
            if let path = Bundle.main.path(forResource: "stations-2", ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                    let items = JSON.init(data: data).arrayValue.map({ (json) -> GasStation in
                        return GasStation.init(fromJson: json)
                    })
                    byvMapListView.addMoreItems(items)
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func listStateDidChange(_ newState: ByvListState) {
        return
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height:size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height:size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    @IBAction func changeClustering(_ sender: UIBarButtonItem) {
        byvMapListView.showClusters = !byvMapListView.showClusters
    }
}

