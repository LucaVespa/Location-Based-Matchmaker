//
//  MapView.swift
//  Location Matchmaker
//
//  Created by Owner on 8/8/23.
//
////THINGS TO CHANGE:
///add actual verification system

import SwiftUI
import MapKit

struct MapLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let date: String
    let time: String
    
    init(name: String, coordinate: CLLocationCoordinate2D, date: String, time: String) {
        self.name = name
        self.coordinate = coordinate
        self.date = date
        self.time = time
    }
}

struct MapView: View {

    @Binding var indexNum : Int
    @Binding var name : String
    
    @State private var selectedLocation: MapLocation? = nil
    @State private var selectedDate = ""
    @State private var selectedTime = ""
    
    @State var coordinates = [Coordinates]()
    @State var mapLocations = [MapLocation]()
    
    @State private var mapRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    
    
    var body: some View {
        ZStack{
            Map(
               coordinateRegion: $mapRegion,
               annotationItems: mapLocations,
               annotationContent: { locations in
                   MapAnnotation(coordinate: locations.coordinate) {
                       PinView().onTapGesture {
                           updateSelectedPin(locations: locations)
                       }.scaleEffect(
                        selectedLocation?.coordinate.latitude == locations.coordinate.latitude && selectedLocation?.coordinate.longitude == locations.coordinate.longitude ? 1.5 : 0.7
                       )
                   }
               }
            ).overlay(
                VStack{
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    ZStack{
                        Text("").frame(width: 350.0, height: 50.0).background(Color.white).foregroundColor(.black).cornerRadius(8)
                        HStack{
                            Spacer()
                            Text("Date: \(selectedDate)").foregroundColor(.black)
                            Spacer()
                            Text("Time: \(selectedTime)").foregroundColor(.black)
                            Spacer()
                        }
                    }
                    Spacer()
                }
            )
        }.ignoresSafeArea().onAppear{
            loadSavedCoordinates()
            placePins()
        }
    }
    
    func loadSavedCoordinates(){
        if let data = UserDefaults.standard.data(forKey: "savedCoords"){
            do{
                let decoder = JSONDecoder()
                coordinates = try decoder.decode([Coordinates].self, from: data)
            }catch{
                print("Could not Decode Array")
            }
        }
    }
    
    func placePins(){
        
        if !coordinates.isEmpty {
              mapRegion = MKCoordinateRegion(
                  center: CLLocationCoordinate2D(latitude: coordinates[0].x, longitude: coordinates[0].y),
                  span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
          }
          
          for coords in coordinates {
              let tempMapLocation = MapLocation(name: name, coordinate: CLLocationCoordinate2D(latitude: coords.x, longitude: coords.y), date: coords.date, time: coords.time)
              mapLocations.append(tempMapLocation)
          }
          
          if let firstLocation = mapLocations.first {
              selectedLocation = firstLocation
              selectedDate = firstLocation.date
              selectedTime = firstLocation.time
          }
    }
    
    func updateSelectedPin(locations: MapLocation){
        selectedLocation = locations
        selectedDate = locations.date
        selectedTime = locations.time
    }
}
/*if !coordinates.isEmpty {
    mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: coordinates[0].x, longitude: coordinates[0].y),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
}

for coords in coordinates{
    let tempMapLocation = MapLocation(name: name, coordinate: CLLocationCoordinate2D(latitude: coords.x, longitude: coords.y), date: coords.date, time: coords.time)
    mapLocations.append(tempMapLocation)
    selectedLocation = tempMapLocation
    selectedDate = coords.date
    selectedTime = coords.time
}*/
