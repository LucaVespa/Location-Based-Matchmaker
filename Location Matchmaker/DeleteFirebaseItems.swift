//
//  DeleteFirebaseItems.swift
//  Location Matchmaker
//
//  Created by Luca on 8/3/22.
//

import Foundation
import FirebaseDatabase
import FirebaseDatabaseSwift

class DeleteFirebaseItems: ObservableObject{
    var ref = Database.database().reference()
    
    func deleteIdle (name: String){
        ref.child("idleMatches").child(name).removeValue()
    }
    
    //Used for client side deletes, should be changed to server side if using a paid model
    func scheduledDeletes(timeKey: Int){
        let cluster: String
        
        if timeKey <= 15 && timeKey != 0{
            cluster = "18-30"
        }else if timeKey <= 30 && timeKey != 0{
            cluster = "33-45"
        }else if timeKey <= 45 && timeKey != 0{
            cluster = "48-60"
        }else{
            cluster = "0-15"
        }
        ref.child(cluster).removeValue()
    }
}
    
