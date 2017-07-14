//
//  EnterpriseCelll.swift
//  ByvMapList
//
//  Created by Adrian Apodaca on 12/12/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import ByvMapList
import ByvUtils
import SwiftyJSON

class EnterpriseCelll: UICollectionViewCell, ByvMapListCollectionViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
//    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func updateWithObject(_ obj:Any, listState:ByvListState, at indexPath:IndexPath) {
        if let e = obj as? Enterprise, let json = e.json  {
            self.nameLbl.text = json["nombre"].stringValue
            self.typeLbl.text = json["autodenominacion"].stringValue
//            self.distanceLbl.text = "\(json["distancia"].stringValue) m"
            self.addressLbl.text = json["direccion"].stringValue
        }
    }
    
    public static func collectionViewnIn(view: UIView) -> UICollectionView? {
        return view as? UICollectionView ?? view.superview.flatMap(collectionViewnIn)
    }
}
