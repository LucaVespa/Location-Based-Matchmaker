//
//  MatchesData.swift
//  Location Matchmaker
//
//  Created by Owner on 8/8/23.
//

import Foundation

struct MatchesData: Encodable, Decodable, Hashable{
    //Goes in a hash table where the Key is the username
    var firstMatch = ""
    var mostRecentMatch = ""
    var name = ""
    
    var coordList = [Coordinates]()
    
    
    init(_ first: String, _ last: String, _ username: String, _ x: Double, _ y: Double) {
        self.firstMatch = first
        self.mostRecentMatch = last
        self.name = username
        
        
        coordList.append(Coordinates(x, y, last))
    }

}

struct Coordinates: Encodable, Decodable, Hashable{
    var x: Double
    var y: Double
    var time: String
    var date: String
    
    init(_ x: Double, _ y: Double, _ time: String) {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            return formatter
        } ()
        
        self.x = x
        self.y = y
        self.time = time
        self.date = dateFormatter.string(from: Date())
    }
}

