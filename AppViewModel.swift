//
//  AppViewModel.swift
//  DSAQIndex
//
//  Created by Dustin Yang on 7/31/24.
//

import Foundation
import MapKit
import Observation
import SwiftUI
import XCAAQI
import Observation
//struct Location : Identifiable
//{
//    var id = UUID()
//    var coordinate : CLLocationCoordinate2D
//    var aqIndex: String
//}
enum LocationStatus: Equatable {
case requestingLocation
case locationNotAutorized(String)
case error(String)
case requestingAQIConditons
case standby

}


@Observable
class AppViewModel: NSObject {
    let locationManager = CLLocationManager()
    let aqiClient = AirQualityClient(apiKey: "GOOGLE_KEY")
    let coordinatesFinder = CoordinatesFinder()

    var currentLocation : CLLocationCoordinate2D?
    var locationStatus = LocationStatus.requestingLocation
    var position : MapCameraPosition = .automatic
    var annotaiton : [AQIResponse] = []
    var selection : AQIResponse?
    var presentationDetent = PresentationDetent.height(176)
    var lat : Double = 0
    var lon : Double = 0

    var radiusArray: [(Double, Int)]

    init(radiusArray: [(Double, Int)] = [(4000,1), (8000, 1)]){
        self.radiusArray = radiusArray
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
//        self.currentLocation = .init(latitude: 40.776676, longitude: -73.971321)
//        Task{
//            await self.handleCoordinateChange(currentLocation!)
//        }

}

    @MainActor
func handleCoordinateChange(_ coordinate: CLLocationCoordinate2D) async {
    do{
        self.locationStatus = .requestingAQIConditons
        self.position = .region(.init(center: coordinate, latitudinalMeters: 0, longitudinalMeters: 16000))
        let coordinates = getCoordinatesAround(coordinate)
        self.annotaiton = try await aqiClient.getCurrentConditions(coordinates: coordinates.map{
            ($0.latitude, $0.longitude)
        })
        
        self.locationStatus = .standby
     
    } catch{
        self.locationStatus = .error(error.localizedDescription)
    }
    
  
//        self.annotaiton = getCoordinatesAround(coordinate).map{
//            Location(coordinate: $0, aqIndex: "\((50...150).randomElement()!)")
//        }

}

func getCoordinatesAround(_ coordinate: CLLocationCoordinate2D) -> [CLLocationCoordinate2D]{
    var results : [CLLocationCoordinate2D] = [coordinate]
    radiusArray.forEach {
        results += coordinatesFinder.findCoordinates(coordinate, r: $0.0, n: $0.1)
    }
    
    return results
}
}

extension AppViewModel: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            manager.requestLocation()
        default:
            self.locationStatus = .locationNotAutorized("Unauthorized location access")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationStatus = .error(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.first?.coordinate else { return }
        if currentLocation == nil {
            lat = coordinate.latitude
            lon = coordinate.longitude
            Task { await self.handleCoordinateChange(coordinate)}
        }
        currentLocation = coordinate
    }
    
}
