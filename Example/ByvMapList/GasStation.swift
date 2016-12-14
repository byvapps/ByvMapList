//
//	GasStation.swift
//
//	Create by Adrián Apodaca on 12/12/2016
//	Copyright © 2016 B&V Apps. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON
import MapKit


class GasStation : NSObject, NSCoding, MKAnnotation {

	var active : Bool!
	var address : String!
	var bioethanolPercent : Int!
	var ccaaId : Int!
	var cp : String!
	var createdAt : Int!
	var deleted : Bool!
	var eessId : Int!
	var geoRegion : GeoRegion!
	var latitude : Float!
	var location : String!
	var locationId : Int!
	var longitude : Float!
	var manual : Bool!
	var margin : String!
	var metilicEtherPercent : Float!
	var name : String!
	var priceBiodiesel : Float!
	var priceBioetanol : Float!
	var priceGasNauralComp : Float!
	var priceGasNauralLic : Float!
	var priceGasoil95 : Float!
	var priceGasoil98 : Float!
	var priceGasoilA : Float!
	var priceGasoilB : Float!
	var priceNewGasoilA : Float!
	var priceOilGases : Float!
	var priceUrea : Float!
	var province : String!
	var provinceId : String!
	var remision : String!
	var rotule : String!
	var schedule : String!
	var sellType : String!
	var stationRotule : StationRotule!
	var stationRotuleId : Int!
	var stationServices : [AnyObject]!
	var updatedAt : Int!


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		active = json["active"].boolValue
		address = json["address"].stringValue
		bioethanolPercent = json["bioethanolPercent"].intValue
		ccaaId = json["ccaaId"].intValue
		cp = json["cp"].stringValue
		createdAt = json["createdAt"].intValue
		deleted = json["deleted"].boolValue
		eessId = json["eessId"].intValue
		let geoRegionJson = json["geoRegion"]
		if !geoRegionJson.isEmpty{
			geoRegion = GeoRegion(fromJson: geoRegionJson)
		}
		latitude = json["latitude"].floatValue
		location = json["location"].stringValue
		locationId = json["locationId"].intValue
		longitude = json["longitude"].floatValue
		manual = json["manual"].boolValue
		margin = json["margin"].stringValue
		metilicEtherPercent = json["metilicEtherPercent"].floatValue
		name = json["name"].stringValue
		priceBiodiesel = json["priceBiodiesel"].floatValue
		priceBioetanol = json["priceBioetanol"].floatValue
		priceGasNauralComp = json["priceGasNauralComp"].floatValue
		priceGasNauralLic = json["priceGasNauralLic"].floatValue
		priceGasoil95 = json["priceGasoil95"].floatValue
		priceGasoil98 = json["priceGasoil98"].floatValue
		priceGasoilA = json["priceGasoilA"].floatValue
		priceGasoilB = json["priceGasoilB"].floatValue
		priceNewGasoilA = json["priceNewGasoilA"].floatValue
		priceOilGases = json["priceOilGases"].floatValue
		priceUrea = json["priceUrea"].floatValue
		province = json["province"].stringValue
		provinceId = json["provinceId"].stringValue
		remision = json["remision"].stringValue
		rotule = json["rotule"].stringValue
		schedule = json["schedule"].stringValue
		sellType = json["sellType"].stringValue
		let stationRotuleJson = json["stationRotule"]
		if !stationRotuleJson.isEmpty{
			stationRotule = StationRotule(fromJson: stationRotuleJson)
		}
		stationRotuleId = json["stationRotuleId"].intValue
		stationServices = [AnyObject]()
		let stationServicesArray = json["stationServices"].arrayValue
		for stationServicesJson in stationServicesArray{
			stationServices.append(stationServicesJson.stringValue as AnyObject)
		}
		updatedAt = json["updatedAt"].intValue
	}

	/**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> NSDictionary
	{
		let dictionary = NSMutableDictionary()
		if active != nil{
			dictionary["active"] = active
		}
		if address != nil{
			dictionary["address"] = address
		}
		if bioethanolPercent != nil{
			dictionary["bioethanolPercent"] = bioethanolPercent
		}
		if ccaaId != nil{
			dictionary["ccaaId"] = ccaaId
		}
		if cp != nil{
			dictionary["cp"] = cp
		}
		if createdAt != nil{
			dictionary["createdAt"] = createdAt
		}
		if deleted != nil{
			dictionary["deleted"] = deleted
		}
		if eessId != nil{
			dictionary["eessId"] = eessId
		}
		if geoRegion != nil{
			dictionary["geoRegion"] = geoRegion.toDictionary()
		}
		if latitude != nil{
			dictionary["latitude"] = latitude
		}
		if location != nil{
			dictionary["location"] = location
		}
		if locationId != nil{
			dictionary["locationId"] = locationId
		}
		if longitude != nil{
			dictionary["longitude"] = longitude
		}
		if manual != nil{
			dictionary["manual"] = manual
		}
		if margin != nil{
			dictionary["margin"] = margin
		}
		if metilicEtherPercent != nil{
			dictionary["metilicEtherPercent"] = metilicEtherPercent
		}
		if name != nil{
			dictionary["name"] = name
		}
		if priceBiodiesel != nil{
			dictionary["priceBiodiesel"] = priceBiodiesel
		}
		if priceBioetanol != nil{
			dictionary["priceBioetanol"] = priceBioetanol
		}
		if priceGasNauralComp != nil{
			dictionary["priceGasNauralComp"] = priceGasNauralComp
		}
		if priceGasNauralLic != nil{
			dictionary["priceGasNauralLic"] = priceGasNauralLic
		}
		if priceGasoil95 != nil{
			dictionary["priceGasoil95"] = priceGasoil95
		}
		if priceGasoil98 != nil{
			dictionary["priceGasoil98"] = priceGasoil98
		}
		if priceGasoilA != nil{
			dictionary["priceGasoilA"] = priceGasoilA
		}
		if priceGasoilB != nil{
			dictionary["priceGasoilB"] = priceGasoilB
		}
		if priceNewGasoilA != nil{
			dictionary["priceNewGasoilA"] = priceNewGasoilA
		}
		if priceOilGases != nil{
			dictionary["priceOilGases"] = priceOilGases
		}
		if priceUrea != nil{
			dictionary["priceUrea"] = priceUrea
		}
		if province != nil{
			dictionary["province"] = province
		}
		if provinceId != nil{
			dictionary["provinceId"] = provinceId
		}
		if remision != nil{
			dictionary["remision"] = remision
		}
		if rotule != nil{
			dictionary["rotule"] = rotule
		}
		if schedule != nil{
			dictionary["schedule"] = schedule
		}
		if sellType != nil{
			dictionary["sellType"] = sellType
		}
		if stationRotule != nil{
			dictionary["stationRotule"] = stationRotule.toDictionary()
		}
		if stationRotuleId != nil{
			dictionary["stationRotuleId"] = stationRotuleId
		}
		if stationServices != nil{
			dictionary["stationServices"] = stationServices
		}
		if updatedAt != nil{
			dictionary["updatedAt"] = updatedAt
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         active = aDecoder.decodeObject(forKey: "active") as? Bool
         address = aDecoder.decodeObject(forKey: "address") as? String
         bioethanolPercent = aDecoder.decodeObject(forKey: "bioethanolPercent") as? Int
         ccaaId = aDecoder.decodeObject(forKey: "ccaaId") as? Int
         cp = aDecoder.decodeObject(forKey: "cp") as? String
         createdAt = aDecoder.decodeObject(forKey: "createdAt") as? Int
         deleted = aDecoder.decodeObject(forKey: "deleted") as? Bool
         eessId = aDecoder.decodeObject(forKey: "eessId") as? Int
         geoRegion = aDecoder.decodeObject(forKey: "geoRegion") as? GeoRegion
         latitude = aDecoder.decodeObject(forKey: "latitude") as? Float
         location = aDecoder.decodeObject(forKey: "location") as? String
         locationId = aDecoder.decodeObject(forKey: "locationId") as? Int
         longitude = aDecoder.decodeObject(forKey: "longitude") as? Float
         manual = aDecoder.decodeObject(forKey: "manual") as? Bool
         margin = aDecoder.decodeObject(forKey: "margin") as? String
         metilicEtherPercent = aDecoder.decodeObject(forKey: "metilicEtherPercent") as? Float
         name = aDecoder.decodeObject(forKey: "name") as? String
         priceBiodiesel = aDecoder.decodeObject(forKey: "priceBiodiesel") as? Float
         priceBioetanol = aDecoder.decodeObject(forKey: "priceBioetanol") as? Float
         priceGasNauralComp = aDecoder.decodeObject(forKey: "priceGasNauralComp") as? Float
         priceGasNauralLic = aDecoder.decodeObject(forKey: "priceGasNauralLic") as? Float
         priceGasoil95 = aDecoder.decodeObject(forKey: "priceGasoil95") as? Float
         priceGasoil98 = aDecoder.decodeObject(forKey: "priceGasoil98") as? Float
         priceGasoilA = aDecoder.decodeObject(forKey: "priceGasoilA") as? Float
         priceGasoilB = aDecoder.decodeObject(forKey: "priceGasoilB") as? Float
         priceNewGasoilA = aDecoder.decodeObject(forKey: "priceNewGasoilA") as? Float
         priceOilGases = aDecoder.decodeObject(forKey: "priceOilGases") as? Float
         priceUrea = aDecoder.decodeObject(forKey: "priceUrea") as? Float
         province = aDecoder.decodeObject(forKey: "province") as? String
         provinceId = aDecoder.decodeObject(forKey: "provinceId") as? String
         remision = aDecoder.decodeObject(forKey: "remision") as? String
         rotule = aDecoder.decodeObject(forKey: "rotule") as? String
         schedule = aDecoder.decodeObject(forKey: "schedule") as? String
         sellType = aDecoder.decodeObject(forKey: "sellType") as? String
         stationRotule = aDecoder.decodeObject(forKey: "stationRotule") as? StationRotule
         stationRotuleId = aDecoder.decodeObject(forKey: "stationRotuleId") as? Int
         stationServices = aDecoder.decodeObject(forKey: "stationServices") as? [AnyObject]
         updatedAt = aDecoder.decodeObject(forKey: "updatedAt") as? Int

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    func encode(with aCoder: NSCoder)
	{
		if active != nil{
			aCoder.encode(active, forKey: "active")
		}
		if address != nil{
			aCoder.encode(address, forKey: "address")
		}
		if bioethanolPercent != nil{
			aCoder.encode(bioethanolPercent, forKey: "bioethanolPercent")
		}
		if ccaaId != nil{
			aCoder.encode(ccaaId, forKey: "ccaaId")
		}
		if cp != nil{
			aCoder.encode(cp, forKey: "cp")
		}
		if createdAt != nil{
			aCoder.encode(createdAt, forKey: "createdAt")
		}
		if deleted != nil{
			aCoder.encode(deleted, forKey: "deleted")
		}
		if eessId != nil{
			aCoder.encode(eessId, forKey: "eessId")
		}
		if geoRegion != nil{
			aCoder.encode(geoRegion, forKey: "geoRegion")
		}
		if latitude != nil{
			aCoder.encode(latitude, forKey: "latitude")
		}
		if location != nil{
			aCoder.encode(location, forKey: "location")
		}
		if locationId != nil{
			aCoder.encode(locationId, forKey: "locationId")
		}
		if longitude != nil{
			aCoder.encode(longitude, forKey: "longitude")
		}
		if manual != nil{
			aCoder.encode(manual, forKey: "manual")
		}
		if margin != nil{
			aCoder.encode(margin, forKey: "margin")
		}
		if metilicEtherPercent != nil{
			aCoder.encode(metilicEtherPercent, forKey: "metilicEtherPercent")
		}
		if name != nil{
			aCoder.encode(name, forKey: "name")
		}
		if priceBiodiesel != nil{
			aCoder.encode(priceBiodiesel, forKey: "priceBiodiesel")
		}
		if priceBioetanol != nil{
			aCoder.encode(priceBioetanol, forKey: "priceBioetanol")
		}
		if priceGasNauralComp != nil{
			aCoder.encode(priceGasNauralComp, forKey: "priceGasNauralComp")
		}
		if priceGasNauralLic != nil{
			aCoder.encode(priceGasNauralLic, forKey: "priceGasNauralLic")
		}
		if priceGasoil95 != nil{
			aCoder.encode(priceGasoil95, forKey: "priceGasoil95")
		}
		if priceGasoil98 != nil{
			aCoder.encode(priceGasoil98, forKey: "priceGasoil98")
		}
		if priceGasoilA != nil{
			aCoder.encode(priceGasoilA, forKey: "priceGasoilA")
		}
		if priceGasoilB != nil{
			aCoder.encode(priceGasoilB, forKey: "priceGasoilB")
		}
		if priceNewGasoilA != nil{
			aCoder.encode(priceNewGasoilA, forKey: "priceNewGasoilA")
		}
		if priceOilGases != nil{
			aCoder.encode(priceOilGases, forKey: "priceOilGases")
		}
		if priceUrea != nil{
			aCoder.encode(priceUrea, forKey: "priceUrea")
		}
		if province != nil{
			aCoder.encode(province, forKey: "province")
		}
		if provinceId != nil{
			aCoder.encode(provinceId, forKey: "provinceId")
		}
		if remision != nil{
			aCoder.encode(remision, forKey: "remision")
		}
		if rotule != nil{
			aCoder.encode(rotule, forKey: "rotule")
		}
		if schedule != nil{
			aCoder.encode(schedule, forKey: "schedule")
		}
		if sellType != nil{
			aCoder.encode(sellType, forKey: "sellType")
		}
		if stationRotule != nil{
			aCoder.encode(stationRotule, forKey: "stationRotule")
		}
		if stationRotuleId != nil{
			aCoder.encode(stationRotuleId, forKey: "stationRotuleId")
		}
		if stationServices != nil{
			aCoder.encode(stationServices, forKey: "stationServices")
		}
		if updatedAt != nil{
			aCoder.encode(updatedAt, forKey: "updatedAt")
		}

	}
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(self.latitude), longitude: Double(self.longitude))
    }
    
    var title: String? {
        return self.name
    }

    var subtitle: String? {
        return self.stationRotule.name
    }
}
