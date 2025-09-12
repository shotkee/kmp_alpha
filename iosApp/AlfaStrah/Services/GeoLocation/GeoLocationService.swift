//
//  GeoLocationService.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 03/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import Legacy

enum GeoLocationServiceAvailability {
    case notDetermined
    case allowedWhenInUse
    case allowedAlways
    case denied
    case restricted
}

enum GeoLocationServiceAccuracy {
    case fullAccuracy
    case reducedAccuracy
}

/// Geo location service protocol.
protocol GeoLocationService {
    typealias SubscriptionCallback = (_ location: Coordinate) -> Void
    typealias AvailabilityCallback = (_ availability: GeoLocationServiceAvailability) -> Void

    var lastLocation: Coordinate? { get }
    var defaultLocation: Coordinate { get }
    var extremeRussiaLocations: [Coordinate] { get }
    var availability: GeoLocationServiceAvailability { get }
    var accuracy: GeoLocationServiceAccuracy { get }

    /// Subscribes for location service availability.
    /// - parameter callback: is being called when availability changed.
    /// - returns: subscription. When it deallocates, callback is deallocated automatically.
    func subscribeForAvailability(_ callback: @escaping AvailabilityCallback) -> Subscription
    /// Requests availability update. Result is distributed via subscriptions.
    func requestAvailability(always: Bool)

    /// Subscribes for location changes.
    /// - parameter callback: is being called when location changes.
    /// - returns: subscription. When it deallocates, callback is deallocated automatically.
    func subscribeForLocation(_ callback: @escaping SubscriptionCallback) -> Subscription

    /// Requests single device location update. Result will be in the subscription.
    func requestCurrentLocation()

    /// Returns addresses for the geopoint.
    func reverseGeocode(location: Coordinate, completion: @escaping (Result<String, Error>) -> Void)
}
