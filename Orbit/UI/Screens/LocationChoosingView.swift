//
//  LocationChoosingView.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-27.
//

import SwiftUI
import MapKit

//used in the MessageView for users to choose a location to share
struct LocationChoosingView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var cameraPosition: MapCameraPosition
    @Binding private var pinLocation: CLLocationCoordinate2D
    var onShareLocation: (CLLocationCoordinate2D) -> Void
    
    init(initialCoordinate: CLLocationCoordinate2D, pinLocation: Binding<CLLocationCoordinate2D>, onShareLocation: @escaping (CLLocationCoordinate2D) -> Void){
        self._cameraPosition = State(initialValue: .camera(MapCamera(centerCoordinate: initialCoordinate, distance: 500)))
        self._pinLocation = pinLocation
        self.onShareLocation = onShareLocation
    }
    
    var body: some View {
        VStack{
          
            MapReader{ reader in
                Map(position: $cameraPosition, interactionModes: .all) {
                    UserAnnotation()  //current user location pin
                    Annotation("Selected Location", coordinate: pinLocation){
                        Image(systemName: "mappin.and.ellipse")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    }
                }
                .onTapGesture{ tappedPlace in
                    if let coordinate = reader.convert(tappedPlace, from: .local) {
                        pinLocation = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        print("Tapped location \(pinLocation)")
                    }
                    
                }
                .mapStyle(.standard)
                .frame(height: 500)
                //.cornerRadius(10)
                
            }
         
            Button("Share Location") {
                print("Location Selected: \(pinLocation.latitude), \(pinLocation.longitude)")
                onShareLocation(pinLocation)

            }
            .buttonStyle(.borderedProminent)
            .foregroundColor(ColorPalette.text(for: colorScheme))
            .tint(ColorPalette.main(for: colorScheme))
            .padding()
            
            
        }
        .background(ColorPalette.background(for: colorScheme))
    }
    
  
}


