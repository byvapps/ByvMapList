//
//  Enterprise.swift
//  Galdakao
//
//  Created by Adrian Apodaca on 22/6/17.
//  Copyright © 2017 byvapps. All rights reserved.
//

import Foundation
import MapKit
import SwiftyJSON
import ClusterKit

class Enterprise: NSObject, CKAnnotation {
    
    weak public var cluster: CKCluster?
    
    public var json:JSON!
    
    init(from: JSON) {
        self.json = from
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: json["latitud"].doubleValue, longitude: json["longitud"].doubleValue)
    }
    
    var title: String? {
        return ""
    }
    
    var subtitle: String? {
        return ""
    }
    
    var name:String {
        get {
            return json["nombre"].stringValue
        }
    }
    
    static public func items(from items:[JSON]) -> [Enterprise] {
        var response:[Enterprise] = []
        for item in items {
            response.append(Enterprise(from: item))
        }
        return response
    }
    
    static public var allItems:[Enterprise] = {
        var response:[Enterprise] = []
        let url = Bundle.main.url(forResource: "galdakao_ge", withExtension: "json")!
        do {
            let data = try Data(contentsOf: url)
            let json = JSON(data)
            response = Enterprise.items(from: json.arrayValue)
        } catch {
        }
        return response
    }()
}
