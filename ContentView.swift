//
//  ContentView.swift
//  DSAQIndex
//
//  Created by Dustin Yang on 7/31/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @State var vm = AppViewModel()
    
    var body: some View {
        Map(position: $vm.position){
            Marker("내위치", coordinate: vm.currentLocation!).annotationTitles(.hidden)
                
            
        }.mapStyle(.hybrid(elevation: .flat, pointsOfInterest: .all, showsTraffic: false))
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
    }
}

#Preview {
    ContentView()
}
