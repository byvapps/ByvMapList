//
//  ByvFlowLayout.swift
//  Pods
//
//  Created by Adrian Apodaca on 13/12/16.
//
//

import UIKit

public class ByvFlowLayout: UICollectionViewFlowLayout {
    public var direction:UICollectionViewScrollDirection = .vertical
    public var width:CGFloat = 0.0
    public var height:CGFloat = 0.0
    public var margin:CGFloat = 0.0
    
    override public func prepare() {
        super.prepare()
        
        self.scrollDirection = direction
        self.itemSize = CGSize(width: width, height: height)
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = 0
        self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
}
