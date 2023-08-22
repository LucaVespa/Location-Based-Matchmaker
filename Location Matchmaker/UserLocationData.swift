//
//  UserLocationData.swift
//  Location Matchmaker
//
//  Created by Luca on 7/26/22.
//

import Foundation

struct UserLocationData: Encodable, Decodable, Hashable{
    
    var key = ""
    var name = ""
    var Latitude = 0.0
    var Longitude = 0.0
    var time = ""
    var isIdle = false
}

extension Encodable{
    var toDictionary: [String: Any]?{
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
    }
}
