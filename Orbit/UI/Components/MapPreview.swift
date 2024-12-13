//
//  MapPreview.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-27.
//

import SwiftUI
import MapKit

struct MapPreview: View {
    var location: CLLocationCoordinate2D
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    init(location: CLLocationCoordinate2D){
        self.location = location
        self._cameraPosition = State(initialValue: .camera(MapCamera(centerCoordinate: location, distance: 500)))
    }
    
    var body: some View {
        Map(position: $cameraPosition, interactionModes: .zoom){
            Marker("Shared Location", coordinate: location)
            UserAnnotation()
        }
        .frame(height: 200)
        .cornerRadius(10)
        .onAppear{
            cameraPosition = .camera(MapCamera(centerCoordinate: location, distance: 500))
        }
    }
}

#Preview {
    MapPreview(location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
}
