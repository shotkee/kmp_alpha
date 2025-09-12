//
//  LocationPickerViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 20/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import YandexMapsMobile
import CoreLocation

/// View Controller to pick point on the map.
class LocationPickerViewController: ViewController,
                                    YMKLocationDelegate,
                                    YMKMapCameraListener {
    struct Input {
        var point: Coordinate?
    }

    struct Output {
        var selectedPoint: (Coordinate) -> Void
        var requestAvailability: () -> Void
    }

    var input: Input!
    var output: Output!

    private let mapView = YMKMapView()
    private let zoomInButton: UIButton = UIButton()
    private let zoomOutButton: UIButton = UIButton()
    private let myLocationButton: UIButton = UIButton()
    private let doneButton: RoundEdgeButton = .init()
    private let markerImageView: UIImageView = UIImageView(image: UIImage(named: "pin_user"))
    private var zoom: Float = 12
    private let zoomStep: Float = 1
    
    private var userLocationLayer: YMKUserLocationLayer?
    private var userLocation: YMKPoint?
    private var userLocationManager: YMKLocationManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("auto_event_report_event_location_title", comment: "")

        // Map

        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)

        // Marker

        markerImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(markerImageView)

        // Map controls

        zoomInButton.translatesAutoresizingMaskIntoConstraints = false
        zoomInButton.setImage(UIImage(named: "ico-map-plus"), for: .normal)
        zoomInButton.addTarget(self, action: #selector(zoomInTap), for: .touchUpInside)
        view.addSubview(zoomInButton)

        zoomOutButton.translatesAutoresizingMaskIntoConstraints = false
        zoomOutButton.setImage(UIImage(named: "ico-map-minus"), for: .normal)
        zoomOutButton.addTarget(self, action: #selector(zoomOutTap), for: .touchUpInside)
        view.addSubview(zoomOutButton)

        myLocationButton.translatesAutoresizingMaskIntoConstraints = false
        myLocationButton.setImage(UIImage(named: "ico-map-navigation"), for: .normal)
        myLocationButton.addTarget(self, action: #selector(myLocationTap), for: .touchUpInside)
        view.addSubview(myLocationButton)

        // Done button

        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        doneButton.setTitle(NSLocalizedString("common_save", comment: ""), for: .normal)
        doneButton.addTarget(self, action: #selector(doneTap), for: .touchUpInside)
        view.addSubview(doneButton)

        // Constraints

        var donebuttonBottomConstraint = doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        donebuttonBottomConstraint = doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)

        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            markerImageView.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            markerImageView.centerYAnchor.constraint(equalTo: mapView.centerYAnchor),

            zoomInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            zoomInButton.bottomAnchor.constraint(equalTo: mapView.centerYAnchor, constant: -10),
            zoomInButton.widthAnchor.constraint(equalToConstant: 48),
            zoomInButton.heightAnchor.constraint(equalToConstant: 48),

            zoomOutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            zoomOutButton.topAnchor.constraint(equalTo: mapView.centerYAnchor, constant: 10),
            zoomOutButton.widthAnchor.constraint(equalToConstant: 48),
            zoomOutButton.heightAnchor.constraint(equalToConstant: 48),

            myLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            myLocationButton.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -10),
            myLocationButton.widthAnchor.constraint(equalToConstant: 48),
            myLocationButton.heightAnchor.constraint(equalToConstant: 48),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            donebuttonBottomConstraint,
            doneButton.heightAnchor.constraint(equalToConstant: 48),
        ])

        setupMapView()
        updateLocation()
        updateDoneButtonDisplay()
    }
    
    private func setupMapView() {
        let map = mapView.mapWindow.map
        
        map.mapType = .vectorMap
        map.isRotateGesturesEnabled = false
        
        let mapKit = YMKMapKit.sharedInstance()
        
        userLocationManager = mapKit.createLocationManager()
        userLocationManager?.subscribeForLocationUpdates(
            withDesiredAccuracy: 0, minTime: 10,
            minDistance: 0,
            allowUseInBackground: false,
            filteringMode: .on,
            locationListener: self
        )
        
        userLocationLayer = mapKit.createUserLocationLayer(with: mapView.mapWindow)
        userLocationLayer?.setVisibleWithOn(true)
        
        map.addCameraListener(with: self)
    }

    /// Updates map camera and marker for location.
    private func updateLocation() {
        guard let point = input.point
        else { return }

        let coordinate = point.clLocationCoordinate
        animate(toLocation: coordinate, with: zoom)
    }

    private func updateDoneButtonDisplay() {
        guard let selectedLocation = input.point
        else {
            doneButton.isEnabled = true
            return
        }

        let currentMapLocation = mapView.mapWindow.map.cameraPosition.target
        let isCoordinatesEqual = Coordinate.areEqual(
            selectedLocation,
            Coordinate(latitude: currentMapLocation.latitude, longitude: currentMapLocation.longitude)
        )

        doneButton.isEnabled = !isCoordinatesEqual
    }
    
    private func animate(toLocation: CLLocationCoordinate2D, with zoomLevel: Float? = nil) {
        mapView.mapWindow.map.move(
            with: YMKCameraPosition(
                target: YMKPoint(latitude: toLocation.latitude, longitude: toLocation.longitude),
                zoom: zoomLevel ?? mapView.mapWindow.map.cameraPosition.zoom,
                azimuth: 0,
                tilt: 0
            )
        )
    }
    
    private func animate(toLocation: YMKPoint, with zoomLevel: Float? = nil) {
        mapView.mapWindow.map.move(
            with: YMKCameraPosition(
                target: toLocation,
                zoom: zoomLevel ?? mapView.mapWindow.map.cameraPosition.zoom,
                azimuth: 0,
                tilt: 0
            ),
            animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 1)
        )
    }

    // MARK: - Actions
    @objc private func zoomInTap() {
        let position = mapView.mapWindow.map.cameraPosition
        
        animate(toLocation: position.target, with: position.zoom + zoomStep)
    }
    
    @objc private func zoomOutTap() {
        let position = mapView.mapWindow.map.cameraPosition
        
        animate(toLocation: position.target, with: position.zoom - zoomStep)
    }

    @objc private func myLocationTap() {
        if let userLocation = userLocation {
            animate(toLocation: userLocation)
        } else {
            output.requestAvailability()
        }
    }

    @objc private func doneTap() {
        let location = mapView.mapWindow.map.cameraPosition.target
        output.selectedPoint(Coordinate(latitude: location.latitude, longitude: location.longitude))
    }
    
    // MARK: - YMKMapCameraListener
    func onCameraPositionChanged(
        with map: YMKMap,
        cameraPosition: YMKCameraPosition,
        cameraUpdateReason: YMKCameraUpdateReason,
        finished: Bool
    ) {
        if finished {
            updateDoneButtonDisplay()
        }
    }
    
    // MARK: - YMKLocationDelegate
    func onLocationUpdated(with location: YMKLocation) {
        let position = location.position
        userLocation = YMKPoint(latitude: position.latitude, longitude: position.longitude)
    }
    
    func onLocationStatusUpdated(with status: YMKLocationStatus) {}
}
