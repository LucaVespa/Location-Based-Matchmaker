//
//  ReadUserLocationData.swift
//  Location Matchmaker
//
//  Created by Luca on 7/26/22.
//

import Foundation
import FirebaseDatabase
import FirebaseDatabaseSwift

class ReadUserLocationData: ObservableObject{
    
    var ref = Database.database().reference()
    @Published var value: String? = nil
    @Published var object: UserLocationData? = nil
    @Published var dataList = [UserLocationData]()
    @Published var dataListIdle = [UserLocationData]()
    
    
    func readListObject(_ coords: String, _ currentTime: Int){
        let cluster: String
        if currentTime <= 15{
            cluster = "0-15"
        }else if currentTime <= 30{
            cluster = "18-30"
        }else if currentTime <= 45{
            cluster = "33-45"
        }else{
            cluster = "48-60"
        }
        ref.child(cluster).child(String(currentTime)).child(coords).observe(.value) { parentSnapshot in
            guard let children = parentSnapshot.children.allObjects as? [DataSnapshot] else{
                // Incase of failure
                return
            }
            self.dataList = children.compactMap({ snapshot in
                return try? snapshot.data(as: UserLocationData.self)
            })
        }
    }
    
    func readListObjectIdle(_ name: String){
        ref.child("idleMatches").child(name).observe(.value) { parentSnapshot in
            guard let children = parentSnapshot.children.allObjects as? [DataSnapshot] else{
                // Incase of failure
                return
            }
            self.dataListIdle = children.compactMap({ snapshot in
                return try? snapshot.data(as: UserLocationData.self)
            })
        }
    }
    
}



