//
//  LocationInfoView
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 15/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import YandexMapsMobile
import CoreLocation

class LocationInfoView: UIView {
    @IBOutlet private var addressInput: CommonNoteLabelView!
    @IBOutlet private var mapViewContainer: UIView!
    @IBOutlet private var mapView: YMKMapView!
    @IBOutlet private var stackView: UIStackView!
    
    var mapTapAction: (() -> Void)?
    var addressInputTapAction: ((String?) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    private func setup() {
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = Style.Margins.defaultInsets

        addressInput.tapHandler = { [unowned self] in
            self.addressInputTapAction?(self.addressInput.currentText)
        }

        mapView.layer.cornerRadius = kRMRMapMapCornerRadius
        mapView.isUserInteractionEnabled = false
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapViewTap))
        mapViewContainer.addGestureRecognizer(tapGestureRecognizer)
		
		updateTheme()
    }

    func configure(coordinate: CLLocationCoordinate2D?, address: String?, isInsuranceEvent: Bool) {
        if isInsuranceEvent {
            addressInput.set(
                title: NSLocalizedString("location_view_travel_title", comment: ""),
                note: "",
                placeholder: NSLocalizedString("common_enter_address", comment: ""),
                style: .center(nil),
                margins: UIEdgeInsets(top: 0, left: 0, bottom: 9, right: 0),
                showSeparator: false
            )
        } else {
            addressInput.set(
                title: NSLocalizedString("auto_event_report_event_location_title", comment: ""),
                note: "",
                placeholder: NSLocalizedString("common_enter_address", comment: ""),
                style: .center(UIImage(named: "right_arrow_icon_gray")),
                margins: UIEdgeInsets(top: 0, left: 0, bottom: 9, right: 0),
                showSeparator: false
            )
        }
        addressInput.updateText(address ?? "")
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
	
	func updateTextInput(text: String)
	{
		addressInput.updateText(text)
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

    @objc private func mapViewTap() {
        mapTapAction?()
    }

    @objc private func addressInputTap() {
        addressInputTapAction?(addressInput.currentText)
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
