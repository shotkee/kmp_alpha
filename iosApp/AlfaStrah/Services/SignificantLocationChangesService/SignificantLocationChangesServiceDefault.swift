//
//  SignificantLocationChangesServiceDefault.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 27.02.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import Foundation
import CoreLocation
import Legacy

class SignificantLocationChangesServiceDefault: NSObject, CLLocationManagerDelegate, SignificantLocationChangesService {
    private let manager: CLLocationManager = CLLocationManager()
    private let locationSubscriptions: Subscriptions<Coordinate> = Subscriptions()

    override init() {
        super.init()

        manager.delegate = self
        manager.distanceFilter = 10000
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers

        manager.pausesLocationUpdatesAutomatically = false
    }

    func start() {
        manager.startMonitoringSignificantLocationChanges()
    }

    func stop() {
        manager.stopMonitoringSignificantLocationChanges()
    }

    func subscribeForLocation(_ callback: @escaping SubscriptionCallback) -> Subscription {
        let subscription = locationSubscriptions.add(callback)
        locationSubscriptions.onChange = { [weak self] in
            self?.checkLocationSubscribers()
        }

        checkLocationSubscribers()

        return subscription
    }

    private func checkLocationSubscribers() {
        if locationSubscriptions.isEmpty {
            manager.stopUpdatingLocation()
        } else {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        locationSubscriptions.fire(Coordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
    }
}
