//
//  ContentView.swift
//  DSAQIndex
//
//  Created by Dustin Yang on 7/31/24.
//

import SwiftUI
import MapKit
import XCAAQI

struct ContentView: View {
    
    @State var vm = AppViewModel()
    
    var body: some View {
        Map(position: $vm.position, selection: $vm.selection){
//            Marker("내위치", coordinate: vm.currentLocation!).annotationTitles(.hidden)
            ForEach(vm.annotaiton){ aqi in
                Annotation(aqi.aqiDisplay, coordinate: aqi.coordinate) {
                    CircleAQIView(aqi: aqi, isSelected: aqi == vm.selection)
                }.annotationTitles(.hidden)
                    .tag(aqi)
            }
                3
            
        }.mapStyle(.hybrid(elevation: .flat, pointsOfInterest: .all, showsTraffic: false))
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .sheet(isPresented: .constant(true)) {
                ScrollView{
                    VStack{
                        if let selection = vm.selection{
                            selectedAQIView(aqi: selection)
                        }else{
                            if vm.locationStatus != .requestingLocation && vm.locationStatus != .requestingAQIConditons {
                                locationFormview
                            }
                            if vm.locationStatus == .requestingAQIConditons{
                                ProgressView("Requesting Current Air Quality Conditions....")
                            }
                            
                            if vm.locationStatus == .requestingLocation{
                                ProgressView("Requesting Current Location")
                            }
                            
                            if case let .locationNotAutorized(text) = vm.locationStatus {
                                Text(text)
                            }
                            
                            if case let .error(text) = vm.locationStatus {
                                Text(text)
                            }
                            
                        }
                    }
                    
                }
                .padding()
                .safeAreaPadding(.top)
                .presentationDetents([.height(24), .height(176)], selection: $vm.presentationDetent)
                .presentationBackground(.ultraThinMaterial)
                .presentationBackgroundInteraction(.enabled(upThrough: .height(176)))
                .interactiveDismissDisabled()
            }
            .onChange(of: vm.selection, { oldValue, newValue in
                if oldValue == nil && newValue != nil {
                    vm.presentationDetent = .height(176)
                }
            })
            .navigationTitle("Air Quality Index")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
    }
    
    
    func selectedAQIView(aqi: AQIResponse) -> some View {
        HStack(spacing: 16){
            CircleAQIView(aqi: aqi, size: CGSize(width: 80, height: 80))
                .padding(.leading)
            VStack(alignment: .leading) {
                Text("Coordinate: \(aqi.coordinate.latitude), \(aqi.coordinate.longitude)")
                Text(aqi.category)
                Text("Dominant Pollutant : \(aqi.dominantPollutant)")
                Text(aqi.displayName)

            }.padding(.top)
             .padding(.horizontal)

             .frame(maxWidth : .infinity)
        }

    }
    @ViewBuilder
    var locationFormview: some View {
        Text("Get Current SQI aorund a coordinate").font(.headline).padding(.bottom, 8)
        
         HStack {
             Text("Lat")
             TextField("Enter Latitude", value: $vm.lat, format: .number)
             Text("Lon")
             TextField("Enter Longitude", value: $vm.lon, format: .number)
         }
         .keyboardType(.decimalPad)
         .textFieldStyle(.roundedBorder)
         .padding(.bottom, 8)
        
        HStack{
            Button("Use Current Loc"){
                vm.lat = vm.currentLocation?.latitude ?? 0
                vm.lon = vm.currentLocation?.longitude ?? 0
                Task {
                    await vm.handleCoordinateChange(.init(latitude: vm.lat, longitude: vm.lon))
                }
            }.buttonStyle(.borderedProminent)
            
            Button("Refresh Data"){
            
                Task {
                    await vm.handleCoordinateChange(.init(latitude: vm.lat, longitude: vm.lon))
                }
            }.buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    NavigationStack{
        ContentView(vm: .init(radiusArray: [(4000, 1), (8000,1)]))

    }
//    , 126.89543423863009
}
