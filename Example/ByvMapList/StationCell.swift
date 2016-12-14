//
//  StationCell.swift
//  ByvMapList
//
//  Created by Adrian Apodaca on 12/12/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import ByvMapList

class StationCell: UICollectionViewCell, ByvMapListCollectionViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var rotuleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func updateWithObject(_ obj:Any) {
        if let gasStation:GasStation = obj as? GasStation {
            nameLbl.text = gasStation.name
            addressLbl.text = gasStation.address
            rotuleLbl.text = gasStation.stationRotule.name
        }
    }
    
}
