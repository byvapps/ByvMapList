//
//  DetailViewController.swift
//  ByvMapList
//
//  Created by Adrian Apodaca on 13/12/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    public var gasStation:GasStation? = nil
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var rotuleLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let gasStation = gasStation {
            nameLbl.text = gasStation.name
            addressLbl.text = gasStation.address
            rotuleLbl.text = gasStation.stationRotule.name
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func updateWithItem(_ item:GasStation) {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
