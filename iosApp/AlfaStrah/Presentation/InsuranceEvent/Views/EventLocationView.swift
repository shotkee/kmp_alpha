//
//  EventLocationView
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 29/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import YandexMapsMobile
import CoreLocation

class EventLocationView: UIView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var mapView: YMKMapView!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var addressStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
		updateTheme()
    }

    private func setup() {
		backgroundColor = .Background.backgroundSecondary
		
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = Style.Margins.defaultInsets
        titleLabel <~ Style.Label.secondaryText
        subtitleLabel <~ Style.Label.primaryText
        titleLabel.text = NSLocalizedString("common_I_am_here", comment: "")
        mapView.layer.cornerRadius = kRMRMapMapCornerRadius
        mapView.isUserInteractionEnabled = false
    }

    func configure(coordinate: CLLocationCoordinate2D?, address: String?) {
        let isAddressEmpty = (address ?? "").isEmpty
        addressStackView.isHidden = isAddressEmpty
        subtitleLabel.text = address
        mapView.isHidden = coordinate == nil
        if let coordinate = coordinate {
            let mapObjects = mapView.mapWindow.map.mapObjects
            mapObjects.clear()
            
            let placemarkIcon = UIImage(
                named: "pin_user"
            ) ?? UIImage()
                        
            mapObjects.addPlacemark(
                with: YMKPoint(latitude: coordinate.latitude, longitude: coordinate.longitude),
                image: placemarkIcon,
                style: Constants.placeMarkStyle
            )
            
            animate(toLocation: coordinate, with: Constants.defaultZoomLevel)
        }

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
            scale: 1,
            tappableArea: nil
        )
    }
}
