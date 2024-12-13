//
//  FullMapView.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-27.
//

import SwiftUI
import MapKit

struct FullMapView: View {
    var sharedLocation: CLLocationCoordinate2D
    var body: some View {
        VStack{
            Map(
                position: .constant(.camera(MapCamera(centerCoordinate: sharedLocation, distance: 1000))),
                interactionModes: .all
            ) {
                Annotation("Shared Location", coordinate: sharedLocation) { //marker for the shared locatin
                    Image(systemName: "mappin.and.ellipse")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                }
                UserAnnotation()  //real time location marker for current user
            }
            .mapStyle(.standard)
            .frame(height: 500)
            //.cornerRadius(10)
            
            Spacer()
        }
        .navigationTitle("Shared Location")
        .navigationBarTitleDisplayMode(.inline)
    }
}


