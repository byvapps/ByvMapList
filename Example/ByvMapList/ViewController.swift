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

class ViewController: UIViewController, ByvMapListDelegate {

    @IBOutlet var byvMapListView: ByvMapListView!
    
    var secondPageLoaded:Bool = false
    var headerView = ListHeader.instanceFromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        byvMapListView.load(self)
        byvMapListView.collectionView?.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        
        let button = headerView.viewWithTag(10) as! UIButton
        button.addTarget(self, action: #selector(showSortList), for: .touchUpInside)
        byvMapListView.addHeaderView(headerView)
        byvMapListView.minListTop = 44.0
        refresh(self)
    }

    @IBAction func refresh(_ sender: Any) {
        secondPageLoaded = false
        if let path = Bundle.main.path(forResource: "stations", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let items = JSON.init(data: data).arrayValue.map({ (json) -> GasStation in
                    return GasStation.init(fromJson: json)
                })
                byvMapListView.reSetItems(items)
            } catch let error {
                print(error.localizedDescription)
            }
        }
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
    
    func pinImage(_ item:MKAnnotation, selected:Bool) -> ByvPinImage {
        var image = UIImage(named: "pin")!
        if selected {
            image = UIImage(named: "pin_selected")!
        }
        let y = -image.size.height / 2.0
        let offset = CGPoint(x: 0, y: y)
        return ByvPinImage(image, offset)
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
}

