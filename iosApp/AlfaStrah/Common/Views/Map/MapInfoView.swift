//
// Created by Roman Churkin on 20/10/15.
// Copyright (c) 2015 RedMadRobot. All rights reserved.
//

import UIKit
import YandexMapsMobile
import CoreLocation

class MapInfoView: UIView {
    @IBOutlet private var mapView: YMKMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        mapView.isUserInteractionEnabled = false
        
        let map = mapView.mapWindow.map
        
        map.logo.setAlignmentWith(
            YMKLogoAlignment(
                horizontalAlignment: .right,
                verticalAlignment: .top
            )
        )
        		
		updateTheme()
    }
    
    @objc func configureForCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let mapObjects = mapView.mapWindow.map.mapObjects
        mapObjects.clear()
                            
        mapObjects.addPlacemark(
            with: YMKPoint(latitude: coordinate.latitude, longitude: coordinate.longitude),
			image: .Icons.pinAlfa
				.tintedImage(withColor: .Icons.iconAccent)
				.overlay(with: .Icons.pin.tintedImage(withColor: .Icons.iconContrast)),
            style: Constants.placeMarkStyle
        )
        
        animate(toLocation: coordinate, with: Constants.defaultZoomLevel)
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
    
    // MARK: - Dark Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
                
		updateTheme()
    }
	
	private func updateTheme() {
		mapView.mapWindow.map.isNightModeEnabled = traitCollection.userInterfaceStyle == .dark
	}
        
    struct Constants {
        static let defaultZoomLevel: Float = 16
        static let placeMarkStyle = YMKIconStyle(
            anchor: NSValue(cgPoint: CGPoint(x: 0.5, y: 1)),
            rotationType: nil,
            zIndex: 1,
            flat: true,
            visible: true,
            scale: 2,
            tappableArea: nil
        )
    }
}
