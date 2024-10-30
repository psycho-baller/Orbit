//
//  CampusLocationManagerDelegate.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-28.
//
import CoreLocation
import Foundation

protocol CampusLocationDelegate: AnyObject {
    func didEnterCampus()
    func didExitCampus()
}

class CampusLocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    weak var delegate: CampusLocationDelegate?

    private let campusRegion = CLCircularRegion(
        center: CLLocationCoordinate2D(
            latitude: 51.07452, longitude: -114.1202),  // Campus center coordinates
        radius: 800,
        identifier: "CampusRegion"
    )

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        setupCampusGeofence()
//        checkIfInsideCampus()  // Perform the initial campus check

    }

    private func setupCampusGeofence() {
        campusRegion.notifyOnEntry = true
        campusRegion.notifyOnExit = true
        locationManager.startMonitoring(for: campusRegion)
    }

    // Initial check if the user is already inside campus
    func checkIfInsideCampus() {
        print(
            "CampusLocationManager - checkIfInsideCampus: Checking initial location."
        )

        if let location = locationManager.location {
            if campusRegion.contains(location.coordinate) {
                print(
                    "CampusLocationManager - checkIfInsideCampus: User is inside campus at app launch."
                )
                delegate?.didEnterCampus()  // Trigger enter campus event if inside
            } else {
                print(
                    "CampusLocationManager - checkIfInsideCampus: User is outside campus at app launch."
                )
            }
        } else {
            print(
                "CampusLocationManager - checkIfInsideCampus: Location not available."
            )
        }
    }

    // Handle entry and exit events
    func locationManager(
        _ manager: CLLocationManager, didEnterRegion region: CLRegion
    ) {
        if region.identifier == "CampusRegion" {
            print(
                "CampusLocationManager - didEnterRegion: User entered campus region."
            )

            delegate?.didEnterCampus()
        }
    }

    func locationManager(
        _ manager: CLLocationManager, didExitRegion region: CLRegion
    ) {
        if region.identifier == "CampusRegion" {
            print(
                "CampusLocationManager - didExitRegion: User exited campus region."
            )

            delegate?.didExitCampus()
        }
    }
}
