//
//  PreciseLocationManagerDelegate.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-08.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

import Appwrite
import CoreLocation

protocol PreciseLocationManagerDelegate: AnyObject {
    func didUpdateLocation(latitude: Double, longitude: Double)
}

class PreciseLocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager
    weak var delegate: PreciseLocationManagerDelegate?  // Delegate to inform about location updates
    private var isMeetingInProgress = false  // Track if user is in a meetup session
    private var isHighAccuracyMode = false  // Track if high-accuracy mode is enabled



    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        setStandardAccuracy()  // Set standard accuracy by default

    }
    
    // MARK: - Public Methods
    func startTrackingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopTrackingLocation() {
        locationManager.stopUpdatingLocation()
    }

    func enableHighPrecisionMode() {
        isMeetingInProgress = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation  // Most precise mode
        locationManager.startUpdatingLocation()  // Ensure updates are active
        print("PreciseLocationManager: High precision mode activated for meetup.")
    }

    func disableHighPrecisionMode() {
        isMeetingInProgress = false
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters  // Reset to standard accuracy
        print("PreciseLocationManager: High precision mode deactivated, reverted to standard accuracy.")
    }

    // MARK: - Accuracy Modes
   func setStandardAccuracy() {
       locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
       locationManager.distanceFilter = 10  // Update only if user moves 10m
       isHighAccuracyMode = false
   }

   func setHighAccuracy() {
       locationManager.desiredAccuracy = kCLLocationAccuracyBest
       locationManager.distanceFilter = kCLDistanceFilterNone  // Update with every movement
       isHighAccuracyMode = true
   }
    
    // MARK: - Enable High Accuracy for Meetups

    func enableHighAccuracyForMeetup() {
        setHighAccuracy()
        startTrackingLocation()
        print("High-accuracy mode enabled for meetup.")
    }

    func disableHighAccuracyAfterMeetup() {
        setStandardAccuracy()
        startTrackingLocation()  // Continue with standard tracking
        print("High-accuracy mode disabled after meetup.")
    }

    // MARK: - CLLocationManager Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
    
        let userLatitude = location.coordinate.latitude
        let userLongitude = location.coordinate.longitude
        
        // Notify delegate (UserViewModel) of new precise location
        delegate?.didUpdateLocation(latitude: userLatitude, longitude: userLongitude)
    }
    
    // Helper function to update general location in Appwrite
    func updateUserGeneralLocation(area: String) {
        // Here you would call your backend to update the user’s general location
        // For example:
        // AppwriteAPI.updateUserLocation(area: area)
        print("User has entered area: \(area)")
    }
}
