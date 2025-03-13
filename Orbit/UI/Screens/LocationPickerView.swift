//
//  LocationPickerView.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-03-11.
//
import SwiftUI

struct LocationPickerView: View {
    @Binding var locationSearchText: String
    @Binding var selectedLocation: String
    @Binding var selectedLocationId: String?
    @Binding var isShowingLocationDropdown: Bool
    let locations: [Area]
    let colorScheme: ColorScheme
    
    private var filteredLocations: [Area] { 
        guard !locationSearchText.isEmpty else { return locations }
        return locations.filter { $0.name.lowercased().contains(locationSearchText.lowercased()) }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Location")
                .font(.headline)
            
            ZStack(alignment: .top) {
                VStack {
                    TextField("Select a location...", text: $locationSearchText)
                        .padding()
                        .background(ColorPalette.main(for: colorScheme))
                        .cornerRadius(12)
                        .onTapGesture {
                            withAnimation {
                                isShowingLocationDropdown = true
                            }
                        }
                    
                    if isShowingLocationDropdown {
                        LocationDropdownList(
                            locations: filteredLocations,
                            selectedLocation: $selectedLocation,
                            selectedLocationId: $selectedLocationId,
                            locationSearchText: $locationSearchText,
                            isShowingDropdown: $isShowingLocationDropdown,
                            colorScheme: colorScheme
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                
                if !locationSearchText.isEmpty {
                    HStack {
                        Spacer()
                        Button(action: {
                            locationSearchText = ""
                            selectedLocation = ""
                            selectedLocationId = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                                .padding(.trailing)
                        }
                    }
                    .offset(y: 12)
                }
            }
        }
        .onTapGesture {
            withAnimation {
                isShowingLocationDropdown = false
            }
        }
    }
}

private struct LocationDropdownList: View {
    let locations: [Area]
    @Binding var selectedLocation: String
    @Binding var selectedLocationId: String?
    @Binding var locationSearchText: String
    @Binding var isShowingDropdown: Bool
    let colorScheme: ColorScheme
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(locations) { location in
                    LocationDropdownRow(
                        location: location,
                        isSelected: selectedLocation == location.name,
                        colorScheme: colorScheme
                    )
                    .onTapGesture {
                        withAnimation {
                            selectedLocation = location.name
                            selectedLocationId = location.id
                            locationSearchText = location.name
                            isShowingDropdown = false
                        }
                    }
                }
            }
        }
        .frame(maxHeight: 200)
        .background(ColorPalette.main(for: colorScheme))
        .cornerRadius(12)
        .padding(.top, 4)
        .shadow(radius: 5)
    }
}

private struct LocationDropdownRow: View {
    let location: Area
    let isSelected: Bool
    let colorScheme: ColorScheme
    
    var body: some View {
        Text(location.name)
            .foregroundColor(ColorPalette.text(for: colorScheme))
            .padding(.vertical, 8)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? ColorPalette.accent(for: colorScheme).opacity(0.2) : Color.clear)
    }
}
