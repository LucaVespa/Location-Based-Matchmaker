//
//  DeviceLocationService.swift
//  Location Matchmaker
//
//  Created by Luca on 7/21/22.
//

import Combine
import CoreLocation

class DeviceLocationService: NSObject, CLLocationManagerDelegate, ObservableObject{
    var coordinatesPublisher = PassthroughSubject<CLLocationCoordinate2D, Error>()
    
    var deniedLocationAccessPublisher = PassthroughSubject<Void, Never>()
    
    private override init(){
        super.init()
    }
    
    static let shared = DeviceLocationService()
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.allowsBackgroundLocationUpdates = true
        manager.showsBackgroundLocationIndicator = true
        manager.pausesLocationUpdatesAutomatically = false
        return manager
    }()
    
    func requestLocationUpdates(){
        switch locationManager.authorizationStatus{
        case .notDetermined:
                locationManager.requestAlwaysAuthorization()
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
        
        case .restricted:
            print("Your location is restricted likely due to parental controls")
        case .denied:
            print("You have denied location services. Please change this in settings")
        
        case .authorizedWhenInUse:
            print("Location Services must be on at all times for the application to function correctly")
        @unknown default:
            deniedLocationAccessPublisher.send()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus{
        case .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            manager.stopUpdatingLocation()
            deniedLocationAccessPublisher.send()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        guard let location = locations.last else{return}
        coordinatesPublisher.send(location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        coordinatesPublisher.send(completion: .failure(error))
    }
    
    
}
