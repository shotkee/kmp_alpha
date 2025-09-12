//
//  CoreLocationService.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 03/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import Foundation
import CoreLocation
import Legacy

/// GeoLocationService implementation using CoreLocation API.
@objc class CoreLocationService: NSObject, CLLocationManagerDelegate, GeoLocationService {
    var applicationSettingsService: ApplicationSettingsService!
    var lastLocation: Coordinate? {
        currentLocation.map(coordinate(for:))
    }

    var defaultLocation: Coordinate {
        Coordinate(latitude: Double(kRMRMoscowCenterLatitude), longitude: Double(kRMRMoscowCenterLongitude))
    }
    var extremeRussiaLocations: [Coordinate] {[
        Coordinate(latitude: 54.2745, longitude: 19.3819),
        Coordinate(latitude: 65.47, longitude: 169.01)
    ]}

    private var authorizationStatus: CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return manager.authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }
    }

    var availability: GeoLocationServiceAvailability {
        switch authorizationStatus {
            case .notDetermined:
                return .notDetermined
            case .restricted:
                return .restricted
            case .denied:
                return .denied
            case .authorizedWhenInUse:
                return .allowedWhenInUse
            case .authorizedAlways:
                return .allowedAlways
            @unknown default:
                return .notDetermined
        }
    }

    var accuracy: GeoLocationServiceAccuracy {
        if #available(iOS 14.0, *) {
            switch manager.accuracyAuthorization {
                case .fullAccuracy:
                    return .fullAccuracy
                case .reducedAccuracy:
                    return .reducedAccuracy
                @unknown default:
                    return .reducedAccuracy
            }
        } else {
            return .fullAccuracy
        }
    }

    private var isLocationServiceEnabled: Bool {
        CLLocationManager.locationServicesEnabled()
    }

    private let manager: CLLocationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    private let locationSubscriptions: Subscriptions<Coordinate> = Subscriptions()
    private let availabilitySubscriptions: Subscriptions<GeoLocationServiceAvailability> = Subscriptions()

    init(applicationSettingsService: ApplicationSettingsService!) {
        self.applicationSettingsService = applicationSettingsService
        super.init()

        manager.delegate = self
        manager.distanceFilter = 100
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.headingFilter = 1

        manager.pausesLocationUpdatesAutomatically = false

        currentLocation = manager.location
    }

    /// Requaests geolocation availability and notify availability subscribers
    func requestAvailability(always: Bool) {
        if isLocationServiceEnabled {
            switch authorizationStatus {
                case .notDetermined:
                    if always {
                        requestAlwaysAuthorization()
                    } else {
                        manager.requestWhenInUseAuthorization()
                    }
                case .authorizedWhenInUse:
                    if always && !applicationSettingsService.haveAskedLocationAlwaysAuthorisation {
                        requestAlwaysAuthorization()
                    } else {
                        notifyAvailabilitySubscribers()
                    }
                case .restricted, .denied, .authorizedAlways:
                    notifyAvailabilitySubscribers()
                @unknown default:
                    notifyAvailabilitySubscribers()
            }
        }
    }

    private func requestAlwaysAuthorization() {
        manager.requestAlwaysAuthorization()
        applicationSettingsService.haveAskedLocationAlwaysAuthorisation = true
    }

    func requestCurrentLocation() {
        manager.requestLocation()
    }

    // MARK: - Subscriptions

    func subscribeForAvailability(_ callback: @escaping AvailabilityCallback) -> Subscription {
        availabilitySubscriptions.add(callback)
    }

    func subscribeForLocation(_ callback: @escaping SubscriptionCallback) -> Subscription {
        let subscription = locationSubscriptions.add(callback)
        locationSubscriptions.onChange = { [weak self] in
            self?.checkLocationSubscribers()
        }

        if let currentLocation = currentLocation {
            callback(coordinate(for: currentLocation))
        }

        checkLocationSubscribers()

        return subscription
    }

    /// Checks location subscribers.
    private func checkLocationSubscribers() {
        if locationSubscriptions.isEmpty {
            manager.stopUpdatingLocation()
        } else {
            manager.startUpdatingLocation()
        }
    }

    /// Notifies subscribers about availability status changes.
    private func notifyAvailabilitySubscribers() {
        availabilitySubscriptions.fire(availability)
    }

    /// Notifies subscribers about device location changes.
    private func notifyLocationSubscribers() {
        guard let currentLocation = currentLocation else { return }

        let point = coordinate(for: currentLocation)
        locationSubscriptions.fire(point)
    }

    /// Converts CLLocation object to Coordinate struct.
    private func coordinate(for location: CLLocation) -> Coordinate {
        Coordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }

    // MARK: CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard authorizationStatus != .notDetermined else { return }

        notifyAvailabilitySubscribers()

        if let location = manager.location {
            locationManager(manager, didUpdateLocations: [ location ])
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        currentLocation = location
        notifyLocationSubscribers()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}

    func reverseGeocode(location: Coordinate, completion: @escaping (Result<String, Error>) -> Void) {}
}
