//
//  WriteUserLocationData.swift
//  Location Matchmaker
//
//  Created by Luca on 7/26/22.
//

import FirebaseDatabase
import FirebaseDatabaseSwift
import Foundation

class WriteUserLocationData: ObservableObject{
    
    private let ref = Database.database().reference()
    
    
    func pushCoord(lat: Double, long: Double, user: String, tim: String, coords: String, timeKey: Int, idleness: Bool){
        let cluster: String
        if timeKey <= 15{
            cluster = "0-15"
        }else if timeKey <= 30{
            cluster = "18-30"
        }else if timeKey <= 45{
            cluster = "33-45"
        }else{
            cluster = "48-60"
        }
        
        var generatedObject = UserLocationData()
        generatedObject.key = coords
        generatedObject.Latitude = lat
        generatedObject.Longitude = long
        generatedObject.name = user
        generatedObject.time = tim
        generatedObject.isIdle = idleness
        ref.child(cluster).child(String(timeKey)).child(generatedObject.key).child(generatedObject.name).setValue(generatedObject.toDictionary)
    }
    
    func pushCoordManual(lat: Double, long: Double, user: String, tim: String, timeKey: Int){
        let cluster: String
        if timeKey <= 15{
            cluster = "0-15"
        }else if timeKey <= 30{
            cluster = "18-30"
        }else if timeKey <= 45{
            cluster = "33-45"
        }else{
            cluster = "48-60"
        }
        
        var generatedObject = UserLocationData()
        generatedObject.key = String(Int(round(lat * 1000)))+String(Int(round(long * 1000)))
        generatedObject.Latitude = lat
        generatedObject.Longitude = long
        generatedObject.name = user
        generatedObject.time = tim
        
        
        ref.child(cluster).child(String(timeKey)).child(generatedObject.key).child(generatedObject.name).setValue(generatedObject.toDictionary)
        
    }
    
    func pushIdle (idleUsername: String, lat: Double, long: Double, user: String, tim: String, coords: String, timeKey: Int, idleness: Bool){
        var generatedObject = UserLocationData()
        generatedObject.key = coords
        generatedObject.Latitude = lat
        generatedObject.Longitude = long
        generatedObject.name = user
        generatedObject.time = tim
        generatedObject.isIdle = idleness
        
        ref.child("idleMatches").child(idleUsername).child(user).setValue(generatedObject.toDictionary)
    }
}


