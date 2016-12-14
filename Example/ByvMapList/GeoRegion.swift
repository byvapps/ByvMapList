//
//	GeoRegion.swift
//
//	Create by Adrián Apodaca on 12/12/2016
//	Copyright © 2016 B&V Apps. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON


class GeoRegion : NSObject, NSCoding{

	var iSO : String!
	var countryISO3 : String!
	var geoCountry : GeoCountry!
	var name : String!
	var regionCP : String!


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		iSO = json["ISO"].stringValue
		countryISO3 = json["countryISO3"].stringValue
		let geoCountryJson = json["geoCountry"]
		if !geoCountryJson.isEmpty{
			geoCountry = GeoCountry(fromJson: geoCountryJson)
		}
		name = json["name"].stringValue
		regionCP = json["regionCP"].stringValue
	}

	/**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> NSDictionary
	{
		let dictionary = NSMutableDictionary()
		if iSO != nil{
			dictionary["ISO"] = iSO
		}
		if countryISO3 != nil{
			dictionary["countryISO3"] = countryISO3
		}
		if geoCountry != nil{
			dictionary["geoCountry"] = geoCountry.toDictionary()
		}
		if name != nil{
			dictionary["name"] = name
		}
		if regionCP != nil{
			dictionary["regionCP"] = regionCP
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         iSO = aDecoder.decodeObject(forKey: "ISO") as? String
         countryISO3 = aDecoder.decodeObject(forKey: "countryISO3") as? String
         geoCountry = aDecoder.decodeObject(forKey: "geoCountry") as? GeoCountry
         name = aDecoder.decodeObject(forKey: "name") as? String
         regionCP = aDecoder.decodeObject(forKey: "regionCP") as? String

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    func encode(with aCoder: NSCoder)
	{
		if iSO != nil{
			aCoder.encode(iSO, forKey: "ISO")
		}
		if countryISO3 != nil{
			aCoder.encode(countryISO3, forKey: "countryISO3")
		}
		if geoCountry != nil{
			aCoder.encode(geoCountry, forKey: "geoCountry")
		}
		if name != nil{
			aCoder.encode(name, forKey: "name")
		}
		if regionCP != nil{
			aCoder.encode(regionCP, forKey: "regionCP")
		}

	}

}