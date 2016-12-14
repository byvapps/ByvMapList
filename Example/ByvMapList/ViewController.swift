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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let path = Bundle.main.path(forResource: "stations", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let items = JSON.init(data: data).arrayValue.map({ (json) -> GasStation in
                    return GasStation.init(fromJson: json)
                })
                byvMapListView.load(self)
                byvMapListView.reSetItems(items)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
//            image = UIImage(named: "pin_promo")!
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
        /*
        let station:GasStation = item as! GasStation
        let alert = UIAlertController(title: "Selected", message: "Item (\(station.name))", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
 */
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

