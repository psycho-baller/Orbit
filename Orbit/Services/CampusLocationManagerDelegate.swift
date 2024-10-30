//
//  CampusLocationManagerDelegate.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-28.
//
import CoreLocation
import Foundation

class CampusLocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    weak var delegate: CampusLocationDelegate?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        setupCampusGeofence()
    }

    private func setupCampusGeofence() {
        let campusRegion = CLCircularRegion(
            center: CLLocationCoordinate2D(latitude: 51.0786, longitude: -114.1304),
            radius: 800, // Adjust radius as per campus size
            identifier: "CampusRegion"
        )
        campusRegion.notifyOnEntry = true
        campusRegion.notifyOnExit = true
        locationManager.startMonitoring(for: campusRegion)
    }

    // Handle entry and exit events
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region.identifier == "CampusRegion" {
            delegate?.didEnterCampus()
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region.identifier == "CampusRegion" {
            delegate?.didExitCampus()
        }
    }
}

// Protocol to handle campus entry/exit events
protocol CampusLocationDelegate: AnyObject {
    func didEnterCampus()
    func didExitCampus()
}

class PreciseLocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    weak var delegate: LocationManagerDelegate?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    func startTrackingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopTrackingLocation() {
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        delegate?.didUpdateLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
}

