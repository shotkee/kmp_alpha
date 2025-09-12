//
// NotificationInfoAddressView
// AlfaStrah
//
// Created by Eugene Egorov on 22 November 2018.
// Copyright (c) 2018 Redmadrobot. All rights reserved.
//

import UIKit
import YandexMapsMobile
import CoreLocation

class NotificationInfoAddressView: UIView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel!
    @IBOutlet private var mapView: YMKMapView!
    @IBOutlet private var serviceHoursLabel: UILabel!
    @IBOutlet private var serviceHoursTitleLabel: UILabel!

    func set(name: String?, address: String?, serviceHours: String?, location: CLLocation?) {
        titleLabel.text = name
        addressLabel.text = address

        if let serviceHours = serviceHours {
            serviceHoursTitleLabel.text = NSLocalizedString("notifications_info_service_hours", comment: "")
            serviceHoursLabel.text = serviceHours
        } else {
            serviceHoursTitleLabel.text = ""
            serviceHoursLabel.text = ""
        }

        if let location = location {
            animate(toLocation: location.coordinate, with: Constants.defaultZoomLevel)
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
    
    struct Constants {
        static let defaultZoomLevel: Float = 16
    }
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		setupUI()
	}
	
	private func setupUI() {
		if let titleLabel {
			titleLabel <~ Style.Label.secondaryText
		}
		
		if let addressLabel {
			addressLabel <~ Style.Label.primaryText
		}
		
		if let serviceHoursLabel {
			serviceHoursLabel <~ Style.Label.primaryText
		}
		
		if let serviceHoursTitleLabel {
			serviceHoursTitleLabel <~ Style.Label.secondaryText
		}
	}
}
