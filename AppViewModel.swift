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

@Observable
class AppViewModel {
    let aqiClient = AirQualityClient(apiKey: "AIzaSyBRFywqkh_-QZJAyv1nwtCruRWX3-lyOCE")
    var currentLocation : CLLocationCoordinate2D?
    var position : MapCameraPosition = .automatic
    var annotaiton : [(CLLocationCoordinate2D, Int)] = []
    
    init(){
        self.currentLocation = .init(latitude: 40.776676, longitude: -73.971321)
        self.position = .region(.init(center: currentLocation!, latitudinalMeters: 0, longitudinalMeters: 16000))
    }
}
