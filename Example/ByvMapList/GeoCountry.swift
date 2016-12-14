//
//	GeoCountry.swift
//
//	Create by Adrián Apodaca on 12/12/2016
//	Copyright © 2016 B&V Apps. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON


class GeoCountry : NSObject, NSCoding{

	var iSO : String!
	var iSO3 : String!
	var iSONumeric : Int!
	var areaKm2 : Int!
	var capital : String!
	var continentCode : String!
	var country : String!
	var currencyCode : String!
	var equivalentFipsCode : String!
	var fips : String!
	var languageCodes : String!
	var neighbours : String!
	var pcFormat : String!
	var pcRegex : String!
	var phone : String!
	var population : Int!
	var tld : String!


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		iSO = json["ISO"].stringValue
		iSO3 = json["ISO3"].stringValue
		iSONumeric = json["ISONumeric"].intValue
		areaKm2 = json["areaKm2"].intValue
		capital = json["capital"].stringValue
		continentCode = json["continentCode"].stringValue
		country = json["country"].stringValue
		currencyCode = json["currencyCode"].stringValue
		equivalentFipsCode = json["equivalentFipsCode"].stringValue
		fips = json["fips"].stringValue
		languageCodes = json["languageCodes"].stringValue
		neighbours = json["neighbours"].stringValue
		pcFormat = json["pcFormat"].stringValue
		pcRegex = json["pcRegex"].stringValue
		phone = json["phone"].stringValue
		population = json["population"].intValue
		tld = json["tld"].stringValue
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
		if iSO3 != nil{
			dictionary["ISO3"] = iSO3
		}
		if iSONumeric != nil{
			dictionary["ISONumeric"] = iSONumeric
		}
		if areaKm2 != nil{
			dictionary["areaKm2"] = areaKm2
		}
		if capital != nil{
			dictionary["capital"] = capital
		}
		if continentCode != nil{
			dictionary["continentCode"] = continentCode
		}
		if country != nil{
			dictionary["country"] = country
		}
		if currencyCode != nil{
			dictionary["currencyCode"] = currencyCode
		}
		if equivalentFipsCode != nil{
			dictionary["equivalentFipsCode"] = equivalentFipsCode
		}
		if fips != nil{
			dictionary["fips"] = fips
		}
		if languageCodes != nil{
			dictionary["languageCodes"] = languageCodes
		}
		if neighbours != nil{
			dictionary["neighbours"] = neighbours
		}
		if pcFormat != nil{
			dictionary["pcFormat"] = pcFormat
		}
		if pcRegex != nil{
			dictionary["pcRegex"] = pcRegex
		}
		if phone != nil{
			dictionary["phone"] = phone
		}
		if population != nil{
			dictionary["population"] = population
		}
		if tld != nil{
			dictionary["tld"] = tld
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
         iSO3 = aDecoder.decodeObject(forKey: "ISO3") as? String
         iSONumeric = aDecoder.decodeObject(forKey: "ISONumeric") as? Int
         areaKm2 = aDecoder.decodeObject(forKey: "areaKm2") as? Int
         capital = aDecoder.decodeObject(forKey: "capital") as? String
         continentCode = aDecoder.decodeObject(forKey: "continentCode") as? String
         country = aDecoder.decodeObject(forKey: "country") as? String
         currencyCode = aDecoder.decodeObject(forKey: "currencyCode") as? String
         equivalentFipsCode = aDecoder.decodeObject(forKey: "equivalentFipsCode") as? String
         fips = aDecoder.decodeObject(forKey: "fips") as? String
         languageCodes = aDecoder.decodeObject(forKey: "languageCodes") as? String
         neighbours = aDecoder.decodeObject(forKey: "neighbours") as? String
         pcFormat = aDecoder.decodeObject(forKey: "pcFormat") as? String
         pcRegex = aDecoder.decodeObject(forKey: "pcRegex") as? String
         phone = aDecoder.decodeObject(forKey: "phone") as? String
         population = aDecoder.decodeObject(forKey: "population") as? Int
         tld = aDecoder.decodeObject(forKey: "tld") as? String

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
		if iSO3 != nil{
			aCoder.encode(iSO3, forKey: "ISO3")
		}
		if iSONumeric != nil{
			aCoder.encode(iSONumeric, forKey: "ISONumeric")
		}
		if areaKm2 != nil{
			aCoder.encode(areaKm2, forKey: "areaKm2")
		}
		if capital != nil{
			aCoder.encode(capital, forKey: "capital")
		}
		if continentCode != nil{
			aCoder.encode(continentCode, forKey: "continentCode")
		}
		if country != nil{
			aCoder.encode(country, forKey: "country")
		}
		if currencyCode != nil{
			aCoder.encode(currencyCode, forKey: "currencyCode")
		}
		if equivalentFipsCode != nil{
			aCoder.encode(equivalentFipsCode, forKey: "equivalentFipsCode")
		}
		if fips != nil{
			aCoder.encode(fips, forKey: "fips")
		}
		if languageCodes != nil{
			aCoder.encode(languageCodes, forKey: "languageCodes")
		}
		if neighbours != nil{
			aCoder.encode(neighbours, forKey: "neighbours")
		}
		if pcFormat != nil{
			aCoder.encode(pcFormat, forKey: "pcFormat")
		}
		if pcRegex != nil{
			aCoder.encode(pcRegex, forKey: "pcRegex")
		}
		if phone != nil{
			aCoder.encode(phone, forKey: "phone")
		}
		if population != nil{
			aCoder.encode(population, forKey: "population")
		}
		if tld != nil{
			aCoder.encode(tld, forKey: "tld")
		}

	}

}