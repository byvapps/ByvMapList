//
//  StationCell.swift
//  ByvMapList
//
//  Created by Adrian Apodaca on 12/12/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import ByvMapList
import ByvUtils

class StationCell: UICollectionViewCell, ByvMapListCollectionViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var rotuleLbl: UILabel!
    @IBOutlet weak var horizontal: UIView!
    @IBOutlet weak var leftConst: NSLayoutConstraint!
    @IBOutlet weak var topConst: NSLayoutConstraint!
    @IBOutlet weak var vertical: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func updateWithObject(_ obj:Any, listState:ByvListState, at indexPath:IndexPath) {
        if let gasStation:GasStation = obj as? GasStation {
            nameLbl.text = gasStation.name
            addressLbl.text = gasStation.address
            rotuleLbl.text = gasStation.stationRotule.name
        }
        
       if indexPath.row == 0 {
            leftConst.constant = 10
            topConst.constant = self.bounds.size.height / 2.0
        } else {
            leftConst.constant = 0
            topConst.constant = 0
        }
        
        if listState == .single {
            horizontal.isHidden = false
            vertical.isHidden = true
        } else {
            horizontal.isHidden = true
            vertical.isHidden = false
        }
    }
    
    public static func collectionViewnIn(view: UIView) -> UICollectionView? {
        return view as? UICollectionView ?? view.superview.flatMap(collectionViewnIn)
    }
}
