//
//  ClinicsMapViewController.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 28/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy
import YandexMapsMobile
import CoreLocation

// swiftlint:disable line_length file_length
final class ClinicsMapViewController: ViewController,
                                      YMKClusterListener,
                                      YMKClusterTapListener,
                                      YMKMapObjectTapListener {
    @IBOutlet private var userLocationButton: UIButton!
    @IBOutlet private var mapView: YMKMapView!
    @IBOutlet private var clinicInfoViewContainer: UIView!
    @IBOutlet private var clinicInfoTopConstraint: NSLayoutConstraint!
    @IBOutlet private var zoomInButton: UIButton!
    @IBOutlet private var zoomOutButton: UIButton!
	
	private var clinicSheetView: ClinicSheetView?
    
    private var clusteredCollection: YMKClusterizedPlacemarkCollection?
    private var userLocationLayer: YMKUserLocationLayer?
    
    private lazy var panGesture = UIPanGestureRecognizer(
        target: self,
        action: #selector(handleDrag(_:))
    )
    
    struct Input {
        var userLocation: () -> Coordinate?
        var cityLocation: () -> Coordinate?
        var defaultLocation: Coordinate
        var data: () -> NetworkData<ClinicResponse>
    }

    struct Output {
        var clinic: (Clinic) -> Void
        var confirmAppointment: (Clinic) -> Void
    }

    struct Notify {
        var changed: () -> Void
		var updateFilter: (SelectClinicFilter?) -> Void
    }

    var input: Input!
    var output: Output!
    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        changed: { [weak self] in
            guard let self,
				  self.isViewLoaded
			else { return }

            self.updateDisplayedData()
        },
		updateFilter: { [ weak self] selectClinicFilter in
			guard let self,
				  self.isViewLoaded
			else { return }
			
			if let selectClinicFilter = selectClinicFilter
			{
				self.selectClinicFilter = selectClinicFilter
			}
			else
			{
				self.selectClinicFilter = .init()
			}
			
			self.filterClinics()
		}
    )
	
	private var selectClinicFilter: SelectClinicFilter = .init()
    private var clinics: [Clinic] = []
	private var filters: [ClinicFilter] = []

    private var foundClinics: [Clinic] = []
    
    private var selectedPlacemark: YMKPlacemarkMapObject?
    
    private var initialClinicInfoViewContainerHeight: CGFloat = 0
    private var initialClinicInfoViewContainerConstraintConstant: CGFloat = 0
    private var originalTouchPoint: CGPoint = .zero

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        updateDisplayedData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
		
		self.clinicSheetView = nil
        hideClinicView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateButtons()
    }

    private func setup() {
        let map = mapView.mapWindow.map
        
        map.logo.setAlignmentWith(
            YMKLogoAlignment(
                horizontalAlignment: .right,
                verticalAlignment: .top
            )
        )
        
		updateTheme()
        
        setupButtons()
        setupMapView()
        setupClusteredCollection()
    }
    
    private func setupButton(
        _ button: UIButton,
        image: UIImage?
    ) {
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = insets(9)
        button.height(48)
        button.widthToHeight(of: button)
        
        button.clipsToBounds = false
        button.layer.shadowRadius = 20
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowOpacity = 1
        
        updateButton(button)
    }
    
    private func updateButton(
        _ button: UIButton
    ) {
        let image = button.imageView?.image
        let buttonWidth = button.bounds.width
        
        button.setImage(image?.tintedImage(withColor: .Icons.iconPrimary), for: .normal)
        
        button.setBackgroundImage(
            UIImage.backgroundImage(
                withColor: .Background.backgroundSecondary,
                size: CGSize(width: buttonWidth, height: buttonWidth)
            ).roundedImage,
            for: .normal
        )
        
        button.layer.shadowColor = UIColor.Shadow.buttonShadow.cgColor
        button.layer.shadowPath = UIBezierPath(roundedRect: button.bounds, cornerRadius: buttonWidth / 2).cgPath
    }
    
    private func setupButtons() {
        setupButton(userLocationButton, image: .Icons.geoposition)
        setupButton(zoomInButton, image: .Icons.plus)
        setupButton(zoomOutButton, image: .Icons.minus)
    }
    
    private func updateButtons() {
        updateButton(userLocationButton)
        updateButton(zoomInButton)
        updateButton(zoomOutButton)
    }
    
    private func setupMapView() {
        let map = mapView.mapWindow.map
        
        map.mapType = .vectorMap
        map.isRotateGesturesEnabled = false
        
        let mapKit = YMKMapKit.sharedInstance()
        userLocationLayer = mapKit.createUserLocationLayer(with: mapView.mapWindow)

        userLocationLayer?.setVisibleWithOn(input.userLocation()?.clLocationCoordinate != nil)
        
        map.mapObjects.addTapListener(with: self)
    }

    private func updateDisplayedData() {
        switch input.data() {
            case .loading, .error:
                self.clinics = []
				self.filters = []
			
            case .data(let clinicResponse):
				self.clinics = clinicResponse.clinicList
				self.filters = clinicResponse.filterList
        }

		filterClinics()

        userLocationButton.isHidden = input.userLocation() == nil
    }
    
    private func updateMapCamera() {
        let userLocation = input.userLocation()?.clLocationCoordinate
        userLocationLayer?.setVisibleWithOn(userLocation != nil)

        let coordinates = (input.cityLocation() ?? input.userLocation() ?? input.defaultLocation).clLocationCoordinate

        animate(toLocation: coordinates, with: Constants.defaultZoomLevel)
    }
    
    private func setupClusteredCollection() {
        clusteredCollection = mapView.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    }
    
    private func updateMapObjects() {
        guard let clusteredCollection = clusteredCollection
        else { return }
        
		let overlayImage = UIImage.Icons.pin.tintedImage(withColor: .Icons.iconContrast)
		
		/// to avoid blur on scaling image , we have to apply .resized method first
        let pinImage = .Icons.pinAlfa
			.resized(scale: 1.5)
			.tintedImage(withColor: .Icons.iconAccent)
			.overlay(with: overlayImage)
			?? UIImage()
		
        let franchiseImage = .Icons.pinPercent
			.resized(scale: 1.5)
			.tintedImage(withColor: .Icons.iconSecondary)
			.overlay(with: overlayImage)
			?? UIImage()
		
        let selectedClinic = selectedPlacemark?.clinic

        clusteredCollection.clear()
        
        for clinic in foundClinics {
            let clinicCoordinate = clinic.coordinate.clLocationCoordinate
            
            let placemarkIcon: UIImage = (clinic.franchise ?? false)
				? franchiseImage
                : pinImage
            
            let clinicPoint = YMKPoint(
                latitude: clinicCoordinate.latitude,
                longitude: clinicCoordinate.longitude
            )

            let viewPlacemark = clusteredCollection.addPlacemark(with: clinicPoint, image: placemarkIcon, style: Constants.placeMarkStyle)
            viewPlacemark.userData = clinic
            
            if let selectedClinic,
                selectedClinic == clinic {
                selectedPlacemark = viewPlacemark
                viewPlacemark.setSelected(true)
            }
        }

        clusteredCollection.clusterPlacemarks(withClusterRadius: Constants.clusterRadius, minZoom: UInt(Constants.defaultZoomLevel))
    }
    
    private func animate(toLocation: CLLocationCoordinate2D, with zoomLevel: Float? = nil) {
        let map = mapView.mapWindow.map
        map.move(
            with: YMKCameraPosition(
                target: YMKPoint(latitude: toLocation.latitude, longitude: toLocation.longitude),
                zoom: getZoomLevel(
					zoomLevel: zoomLevel,
					mapZoom: map.cameraPosition.zoom
				),
                azimuth: 0,
                tilt: 0
            ),
            animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 1)
        )
    }
	
	private func getZoomLevel(
		zoomLevel: Float? = nil,
		mapZoom: Float
	) -> Float
	{
		guard let zoomLevel = zoomLevel
		else { return mapZoom }
		
		return zoomLevel > mapZoom ? zoomLevel : mapZoom
	}
    
    private func animate(toLocation: YMKPoint, with zoomLevel: Float? = nil) {
        let map = mapView.mapWindow.map
        
        map.move(
            with: YMKCameraPosition(
                target: toLocation,
                zoom: zoomLevel ?? map.cameraPosition.zoom,
                azimuth: 0,
                tilt: 0
            ),
            animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 1)
        )
    }

    private func showBoundBox(_ list: [CLLocationCoordinate2D], zoomFactor: Float = 1) {
        let points = list.map { YMKPoint(latitude: $0.latitude, longitude: $0.longitude) }
        let polyline = YMKPolyline(points: points)
        if let bounds = YMKGetPolylineBounds(polyline) {
            let map = mapView.mapWindow.map
            var cameraPosition = map.cameraPosition(with: bounds)
            cameraPosition = YMKCameraPosition(
                target: cameraPosition.target,
                zoom: cameraPosition.zoom * zoomFactor,
                azimuth: cameraPosition.azimuth,
                tilt: cameraPosition.tilt
            )
            map.move(
                with: cameraPosition,
                animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 1)
            )
        }
    }
    
    // MARK: - Actions
    @IBAction func userLocationTap(_ sender: UIButton) {
        guard let userCoordinate = input.userLocation()?.clLocationCoordinate
        else { return }

        animate(toLocation: userCoordinate, with: Constants.defaultZoomLevel)
    }

    @IBAction func zoomInButtonTap(_ sender: UIButton) {
        let position = mapView.mapWindow.map.cameraPosition
        
        animate(toLocation: position.target, with: position.zoom + 1)
    }

    @IBAction func zoomOutButtonTap(_ sender: UIButton) {
        let position = mapView.mapWindow.map.cameraPosition
        
        animate(toLocation: position.target, with: position.zoom - 1)
    }
    
    // MARK: - Search

    private func filterClinics() {
        foundClinics = ClinicAppointmentFlow.getClinicsWithFilter(
			selectClinicFilter: self.selectClinicFilter,
			clinics: self.clinics,
			filters: self.filters
		)
		updateMapCamera()
		updateMapObjects()
    }
    
    private func needChangeColor(for cluster: YMKCluster) -> Bool {
        for placemark in cluster.placemarks {
            guard let clinic = placemark.userData as? Clinic
            else { continue }
            
            if clinic.franchise ?? false {
                return true
            }
        }
        return false
    }

    // MARK: - YMKClusterTapListener
    func onClusterTap(with cluster: YMKCluster) -> Bool {
        let userDatas = cluster.placemarks.map { $0.userData }
        guard let сlinics = userDatas as? [Clinic] else {
            return false
        }

        showBoundBox(сlinics.map { $0.coordinate.clLocationCoordinate }, zoomFactor: 0.9)
        return true
    }
    
    // MARK: - YMKClusterListener
    func onClusterAdded(with cluster: YMKCluster) {
        var pinBackgroundColor = UIColor.Icons.iconAccent
        var franchiseBackgroundColor = UIColor.Icons.iconSecondary
        var textColor = UIColor.Text.textContrast

        if #available(iOS 13.0, *) {
            let isNightModeEnabled = mapView.mapWindow.map.isNightModeEnabled

            pinBackgroundColor = isNightModeEnabled
                ? .Icons.iconAccent.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
                : .Icons.iconAccent.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
            
            franchiseBackgroundColor = isNightModeEnabled
                ? .Icons.iconSecondary.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
                : .Icons.iconSecondary.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))

            textColor = isNightModeEnabled
                ? .Text.textContrast.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
                : .Text.textContrast.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        }
        
        cluster.appearance.setIconWith(MapClusterIconGenerator.clusterImage(
            cluster.size,
            color: needChangeColor(for: cluster)
                ? franchiseBackgroundColor
                : pinBackgroundColor,
            textColor: textColor
        ) ?? UIImage())
        cluster.addClusterTapListener(with: self)
    }
    
    // MARK: - YMKMapObjectTapListener
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        selectedPlacemark?.setSelected(false)
        
        guard let placemark = mapObject as? YMKPlacemarkMapObject
        else { return true }
                
        // prevent show bottom sheet twice
        if selectedPlacemark == placemark {
            selectedPlacemark?.setSelected(true)
            return true
        }
        
        guard let clinic = mapObject.userData as? Clinic
        else { return true }
                
        animate(toLocation: clinic.coordinate.clLocationCoordinate, with: Constants.defaultZoomLevel)
        
		if clinicInfoTopConstraint.constant != .zero {
            hideClinicView()
        }
        
        placemark.setSelected(true)
        selectedPlacemark = placemark
        showClinicView(with: clinic)
        
        return true
    }
    
    private func showClinicView(with clinic: Clinic) {
		if let clinicSheetView = clinicSheetView
		{
			clinicSheetView.display(clinic)
		}
		else
		{
			let clinicInfoView = ClinicSheetView()
			self.clinicSheetView = clinicInfoView
			
			clinicInfoView.onClose = { [weak self] in
				self?.clinicSheetView = nil
				self?.hideClinicView()
			}
			
			clinicInfoView.onDetails = { [weak self] in
				self?.openClinic()
			}
			
			clinicInfoView.onConfirmAppointment = { [weak self] in
				self?.output.confirmAppointment(clinic)
			}
			
			clinicInfoView.alpha = 0
			
			let bottom: CGFloat = 28
			
			let cardView = clinicInfoView.embedded(
				margins: UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0),
				hasShadow: true,
				cornerSide: .top,
				shadowStyle: .elevation1
			)
			clinicInfoViewContainer.addSubview(cardView)
					
			cardView.width(to: view)
			cardView.topToSuperview(offset: -16)
			cardView.edgesToSuperview(excluding: .top)
			
			clinicInfoView.display(clinic)
			clinicInfoView.layoutIfNeeded()
			
			let showHeightValue = clinicInfoView.bounds.size.height + bottom
			clinicInfoTopConstraint.constant = showHeightValue
			
			UIView.animate(withDuration: 0.3) { [weak self] in
				self?.view.layoutIfNeeded()
				clinicInfoView.alpha = 1
			}
			
			clinicInfoViewContainer.addGestureRecognizer(panGesture)
		}
    }
    
	private func hideClinicView() {
        selectedPlacemark?.setSelected(false)
        selectedPlacemark = nil
		
		if clinicSheetView == nil
		{
			clinicInfoTopConstraint.constant = .zero
			
			UIView.animate(withDuration: 0.3) { [weak self] in
				self?.view.layoutIfNeeded()
			} completion: { [weak self] _ in
				guard let self
				else { return }
				
				self.clinicInfoViewContainer.removeGestureRecognizer(self.panGesture)
				
				for view in self.clinicInfoViewContainer.subviews{
					view.removeFromSuperview()
				}
			}
		}
    }
    
    private func openClinic() {
        guard let clinic = selectedPlacemark?.clinic
        else { return }
        
        output.clinic(clinic)
    }
    
    @objc private func handleDrag(_ recognizer: UIPanGestureRecognizer) {
        let touchPoint = recognizer.location(in: view)
        let velocity = recognizer.velocity(in: view)
        switch recognizer.state {
            case .began:
                initialClinicInfoViewContainerConstraintConstant = clinicInfoTopConstraint.constant
                initialClinicInfoViewContainerHeight = clinicInfoViewContainer.frame.height
                originalTouchPoint = touchPoint
                
            case .changed:
                let offset = touchPoint.y - originalTouchPoint.y
                if offset > 0 {
                    clinicInfoTopConstraint.constant = initialClinicInfoViewContainerConstraintConstant - offset
                }
                
            case .ended, .cancelled:
                if (clinicInfoTopConstraint.constant < initialClinicInfoViewContainerHeight / 2 && velocity.y > -100)
                    || velocity.y > 1000 {
					self.clinicSheetView = nil
                    hideClinicView()
                } else {
                    animateReversion()
                }
                
            default:
                break
        }
    }
    
    private func animateReversion() {
        let duration = abs(Double(clinicInfoTopConstraint.constant)) * 0.001
        clinicInfoTopConstraint.constant = initialClinicInfoViewContainerConstraintConstant
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [ .allowUserInteraction ]
        ) {
            self.view.layoutIfNeeded()
        }
    }
            
    struct Constants {
        static let clusterRadius: CGFloat = 60
        static let defaultZoomLevel: Float = 14
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
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		updateButtons()
		updateTheme()
		updateMapObjects()
	}
	
	private func updateTheme() {
		mapView.mapWindow.map.isNightModeEnabled = traitCollection.userInterfaceStyle == .dark
	}
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

private extension YMKPlacemarkMapObject {
    var clinic: Clinic? {
        return userData as? Clinic
    }
    
    func setSelected(_ selected: Bool) {
        guard isValid
        else { return }
		
		if let clinic {
			let image: UIImage = clinic.franchise ?? false
				? selected
					? Constants.franchiseImageLarge
					: Constants.franchiseImageSmall
				: selected
					? Constants.alfaPinImageLarge
					: Constants.alfaPinImageSmall
			
			setIconWith(image)
		}
    }
	
	struct Constants {
		static let alfaPinImageSmall: UIImage = {
			return .Icons.pinAlfa
				.resized(scale: 1.5)
				.tintedImage(withColor: .Icons.iconAccent)
				.overlay(with: overlayImage)
		}()
			
		static let alfaPinImageLarge: UIImage = {
			return .Icons.pinAlfa
				.resized(scale: 4)
				.tintedImage(withColor: .Icons.iconAccent)
				.overlay(with: overlayImage)
		}()

		static let franchiseImageSmall: UIImage = {
			return .Icons.pinPercent
			.resized(scale: 1.5)
			.tintedImage(withColor: .Icons.iconSecondary)
			.overlay(with: overlayImage)
		}()
		
		static let franchiseImageLarge: UIImage = {
			return .Icons.pinPercent
				.resized(scale: 4)
				.tintedImage(withColor: .Icons.iconSecondary)
				.overlay(with: overlayImage)
		}()
		
		static let overlayImage = UIImage.Icons.pin.tintedImage(withColor: .Icons.iconContrast)
	}
}
