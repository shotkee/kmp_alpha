//
//  OfficesMapViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16/11/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy
import YandexMapsMobile
import CoreLocation

final class OfficesMapViewController: ViewController,
                                      YMKClusterListener,
                                      YMKMapObjectTapListener,
                                      YMKClusterTapListener {
    @IBOutlet private var searchInfoView: UIView!
    @IBOutlet private var searchInfoLabel: UILabel!
    @IBOutlet private var officeInfoViewContainer: UIView!
    @IBOutlet private var officeInfoTopConstraint: NSLayoutConstraint!
    @IBOutlet private var buttonsStack: UIStackView!
    @IBOutlet private var buttonsStackBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var userLocationButton: UIButton!
    @IBOutlet private var mapView: YMKMapView!
    
    private var clusteredCollection: YMKClusterizedPlacemarkCollection?
    private var userLocationLayer: YMKUserLocationLayer?
    
    private lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
        
    struct Input {
        let userLocation: () -> Coordinate?
        let defaultLocation: Coordinate
        let extremeLocations: [Coordinate]
        let data: () -> NetworkData<[Office]>
        let searchStringIsEmpty: () -> Bool
    }

    struct Output {
        let office: (Office) -> Void
        let routeInAnotherApp: (CLLocationCoordinate2D) -> Void
    }

    struct Notify {
        let changed: (Insurance.Kind?) -> Void
    }

    var input: Input!
    var output: Output!

    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        changed: { [weak self] insuranceKind in
            guard let self = self,
                  self.isViewLoaded
            else { return }

            self.update(insuranceKind)
        }
    )
    
    private var filteredOffices: [Office] = [] {
        didSet {
			selectedPlacemark?.setSelected(false)
			selectedPlacemark = nil
            updateMapObjects()
        }
    }
    
    private var selectedPlacemark: YMKPlacemarkMapObject?
    private var initialOfficeInfoViewContainerHeight: CGFloat = 0
    // swiftlint:disable:next identifier_name
    private var initialOfficeInfoViewContainerConstraintConstant: CGFloat = 0
    private var originalTouchPoint: CGPoint = .zero
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        update(nil)
    }

    private func setup() {
        setupSearchInfoView()
        setupOfficeInfoView()
        setupButtons()
        setupMapView()
        setupClusteredCollection()
    }
    
    private func setupMapView() {
        let map = mapView.mapWindow.map
        
        map.logo.setAlignmentWith(
            YMKLogoAlignment(
                horizontalAlignment: .right,
                verticalAlignment: .top
            )
        )
        
        if #available(iOS 13.0, *) {
            switch UITraitCollection.current.userInterfaceStyle {
                case .dark:
                    map.isNightModeEnabled = true
                case .light:
                    map.isNightModeEnabled = false
                default:
                    map.isNightModeEnabled = false
            }
        }
        
        map.mapType = .vectorMap
        map.isRotateGesturesEnabled = false
        
        let mapKit = YMKMapKit.sharedInstance()
        userLocationLayer = mapKit.createUserLocationLayer(with: mapView.mapWindow)

        userLocationLayer?.setVisibleWithOn(input.userLocation()?.clLocationCoordinate != nil)
        
        map.mapObjects.addTapListener(with: self)
    }
    
    private func setupUserLocationButton() {
        userLocationButton.setImage(UIImage.Icons.mapLocation.tintedImage(withColor: .Icons.iconPrimary), for: .normal)
        
        userLocationButton.backgroundColor = .Background.backgroundSecondary
        userLocationButton.roundCorners(radius: 21)
    }
    
    private func setupClusteredCollection() {
        clusteredCollection = mapView.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    }
    
    private func updateMapObjects() {
        guard let clusteredCollection = clusteredCollection
        else { return }
        
        let selectedOffice = selectedPlacemark?.office
                
        clusteredCollection.clear()
        
        for office in filteredOffices {
            let officeCoordinate = office.coordinate.clLocationCoordinate
            
            let officePoint = YMKPoint(
                latitude: officeCoordinate.latitude,
                longitude: officeCoordinate.longitude
            )
                        
            let viewPlacemark = clusteredCollection.addPlacemark(
                with: officePoint,
                image: .Icons.pinAlfa
					.resized(scale: 1.5)
                    .tintedImage(withColor: .Icons.iconAccent)
					.overlay(with: .Icons.pin.tintedImage(withColor: .Icons.iconContrast))
                    ?? UIImage(),
                style: Constants.placeMarkStyle
            )
            viewPlacemark.userData = office
            
            if let selectedOffice,
               selectedOffice == office {
                selectedPlacemark = viewPlacemark
                viewPlacemark.setSelected(true)
            }
        }

        clusteredCollection.clusterPlacemarks(withClusterRadius: Constants.clusterRadius, minZoom: UInt(Constants.defaultZoomLevel))
    }

    private func setupSearchInfoView() {
        searchInfoView.isHidden = true
        searchInfoView.layer.cornerRadius = 3
        searchInfoLabel <~ Style.Label.primaryText
        searchInfoLabel.text = NSLocalizedString("office_map_info_view_text", comment: "")
    }

    private func setupOfficeInfoView() {
        officeInfoTopConstraint.constant = .zero
        officeInfoViewContainer.backgroundColor = .clear
    }

    private func setupButtons() {
        buttonsStack.spacing = 15
        buttonsStackBottomConstraint.constant = 27

        setupUserLocationButton()
    }

    private func update(_ insuranceKind: Insurance.Kind?) {
        switch input.data() {
            case .loading, .error:
                self.filteredOffices = []
            case .data(let offices):
                switch insuranceKind {
                    case .kasko?:
                        self.filteredOffices = offices.filter { $0.damageClaimAvailable }
                    case .osago?:
                        self.filteredOffices = offices.filter { $0.osagoClaimAvailable }
                    case .unknown?, .dms?, .vzr?, .property?, .passengers?, .life?, .accident?, .vzrOnOff?, .flatOnOff?, .none:
                        self.filteredOffices = offices
                }
        }

        userLocationButton.isHidden = input.userLocation() == nil
        searchInfoView.isHidden = !filteredOffices.isEmpty
        updateMapCamera()
        updateMapObjects()
    }

    private func updateMapCamera() {
        let userLocation = input.userLocation()?.clLocationCoordinate
        let searchStringIsEmpty = input.searchStringIsEmpty()
        
        userLocationLayer?.setVisibleWithOn(userLocation != nil)

        if filteredOffices.isEmpty {
            showBoundBox(input.extremeLocations.map { $0.clLocationCoordinate })
        } else if userLocation == nil && searchStringIsEmpty {
            showDefaultLocation()
        } else {
            showBoundBox(filteredOffices.map { $0.coordinate.clLocationCoordinate })
        }
    }
    
    private func animate(toLocation: CLLocationCoordinate2D) {
        mapView.mapWindow.map.move(
            with: YMKCameraPosition(
                target: YMKPoint(latitude: toLocation.latitude, longitude: toLocation.longitude),
                zoom: Constants.defaultZoomLevel,
                azimuth: 0,
                tilt: 0
            ),
            animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 1)
        )
    }
    
    private func showDefaultLocation() {
        let coordinates = input.defaultLocation.clLocationCoordinate
        animate(toLocation: coordinates)
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
        guard let userCoordinate = input.userLocation()?.clLocationCoordinate else { return }

        animate(toLocation: userCoordinate)
    }

    @IBAction func showRouteToVariants(_ sender: UIButton) {
        routeInAnotherApp()
    }
    
    private func routeInAnotherApp() {
        guard let coordinate = selectedPlacemark?.office?.coordinate.clLocationCoordinate
        else { return }
        
        output.routeInAnotherApp(coordinate)
    }

    private func showOfficeView(with office: Office) {
        let officeInfoView = OfficeSheetView(frame: .zero)
        officeInfoView.onClose = { [weak self] in
            self?.hideOfficeView()
        }
        officeInfoView.onRoute = { [weak self] in
            self?.routeInAnotherApp()
        }
        officeInfoView.onDetails = { [weak self] in
            self?.openOffice()
        }
        officeInfoView.alpha = 0
        
        let cardView = officeInfoView.embedded(hasShadow: true, cornerSide: .top, shadowStyle: .elevation1)
        officeInfoViewContainer.addSubview(cardView)
        let bottom: CGFloat = 8

        cardView.width(to: view)
        cardView.topToSuperview(offset: -16)
        cardView.edgesToSuperview(excluding: .top, insets: UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0))
        
        officeInfoView.set(office: office)
        let showHeightValue = officeInfoView.bounds.size.height + bottom
        officeInfoTopConstraint.constant = showHeightValue
        buttonsStackBottomConstraint.constant = showHeightValue + 25
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
            officeInfoView.alpha = 1
        }
        officeInfoViewContainer.addGestureRecognizer(panGesture)
    }

	// parameter closeButtonTapped fix white bottom office info view
	private func hideOfficeView(closeButtonTapped: Bool = true) {
        selectedPlacemark?.setSelected(false)
        selectedPlacemark = nil
        officeInfoTopConstraint.constant = .zero
        buttonsStackBottomConstraint.constant = 40
        
		UIView.animate(withDuration: 0.3) { [weak self] in
			if closeButtonTapped{
				self?.view.layoutIfNeeded()
			} else {
				guard let self
				else { return }
				
				self.officeInfoViewContainer.removeGestureRecognizer(self.panGesture)
				for view in self.officeInfoViewContainer.subviews{
					view.removeFromSuperview()
				}
			}
		} completion: { [weak self] _ in
			if closeButtonTapped{
				guard let self
				else { return }
				
				self.officeInfoViewContainer.removeGestureRecognizer(self.panGesture)
				for view in self.officeInfoViewContainer.subviews{
					view.removeFromSuperview()
				}
			}
		}
    }

    private func resignFirstResponderOnParentView() {
        UIApplication.shared.sendAction(#selector(UIView.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func openOffice() {
        guard let office = selectedPlacemark?.office
        else { return }
        
        output.office(office)
    }

    @objc private func handleDrag(_ recognizer: UIPanGestureRecognizer) {
        let touchPoint = recognizer.location(in: view)
        let velocity = recognizer.velocity(in: view)
        switch recognizer.state {
            case .began:
                initialOfficeInfoViewContainerConstraintConstant = officeInfoTopConstraint.constant
                initialOfficeInfoViewContainerHeight = officeInfoViewContainer.frame.height
                originalTouchPoint = touchPoint
            case .changed:
                let offset = touchPoint.y - originalTouchPoint.y
                if offset > 0 {
                    officeInfoTopConstraint.constant = initialOfficeInfoViewContainerConstraintConstant - offset
                }
            case .ended, .cancelled:
                if (officeInfoTopConstraint.constant < initialOfficeInfoViewContainerHeight / 2 && velocity.y > -100)
                    || velocity.y > 1000 {
                    hideOfficeView()
                } else {
                    animateReversion()
                }
            default:
                break
        }
    }

    private func animateReversion() {
        let duration = abs(Double(officeInfoTopConstraint.constant)) * 0.001
        officeInfoTopConstraint.constant = initialOfficeInfoViewContainerConstraintConstant
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [ .allowUserInteraction ]
        ) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - YMKClusterTapListener
    func onClusterTap(with cluster: YMKCluster) -> Bool {
        let userDatas = cluster.placemarks.map { $0.userData }
        guard let offices = userDatas as? [Office] else {
            return false
        }

        showBoundBox(offices.map { $0.coordinate.clLocationCoordinate }, zoomFactor: 0.9)
        return true
    }
    
    // MARK: - YMKClusterListener
    func onClusterAdded(with cluster: YMKCluster) {
        cluster.appearance.setIconWith(clusterImage(cluster.size))
        cluster.addClusterTapListener(with: self)
    }
        
    func clusterImage(_ clusterSize: UInt) -> UIImage {
        let scale = UIScreen.main.scale
        let text = String(clusterSize)
        let font = UIFont.systemFont(ofSize: Constants.fontSize * scale)
        let size = text.size(withAttributes: [NSAttributedString.Key.font: font])
        let textRadius = sqrt(size.height * size.height + size.width * size.width) / 2
        let radius = textRadius + Constants.marginSize * scale
        let iconSide = radius * 2
        let iconSize = CGSize(width: iconSide, height: iconSide)

        UIGraphicsBeginImageContext(iconSize)
        
        if let ctx = UIGraphicsGetCurrentContext() {
            var backgoundColor = UIColor.Background.backgroundAccent
            var textColor = UIColor.Text.textContrast
            
            if #available(iOS 13.0, *) {
                let isNightModeEnabled = mapView.mapWindow.map.isNightModeEnabled
                
                backgoundColor = isNightModeEnabled
                    ? .Background.backgroundAccent.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
                    : .Background.backgroundAccent.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
                
                textColor = isNightModeEnabled
                    ? .Text.textContrast.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
                    : .Text.textContrast.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
            }
            
            ctx.setFillColor(backgoundColor.cgColor)
            
            ctx.fillEllipse(in:
                CGRect(
                    origin: .zero,
                    size: iconSize
                )
            )

            text.draw(
                in: CGRect(
                    origin: CGPoint(x: radius - size.width / 2, y: radius - size.height / 2),
                    size: size
                ),
                withAttributes: [
                    NSAttributedString.Key.font: font,
                    NSAttributedString.Key.foregroundColor: textColor
                ]
            )
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
    
    // MARK: - YMKMapObjectTapListener
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        selectedPlacemark?.setSelected(false)
        resignFirstResponderOnParentView()
        
        guard let placemark = mapObject as? YMKPlacemarkMapObject
        else { return false }
        
        // prevent show bottom sheet twice
        if selectedPlacemark == placemark {
            selectedPlacemark?.setSelected(true)
            return true
        }
        
        guard let office = placemark.office
        else { return false }
                
        animate(toLocation: office.coordinate.clLocationCoordinate)
        
        officeInfoViewContainer.subviews.forEach { $0.removeFromSuperview() }
        
        if officeInfoTopConstraint.constant != .zero {
            hideOfficeView(closeButtonTapped: false)
        }
        
        placemark.setSelected(true)
        selectedPlacemark = placemark
        showOfficeView(with: office)
        
        return true
    }
    
    // MARK: - Dark Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    
        setupUserLocationButton()
        
        guard let previousStyle = previousTraitCollection?.userInterfaceStyle
        else { return }
        
        mapView.mapWindow.map.isNightModeEnabled = previousStyle == .light ? true : false
        
        updateMapObjects()
    }
    
    struct Constants {
        static let fontSize: CGFloat = 15
        static let marginSize: CGFloat = 6
        static let clusterRadius: CGFloat = 60
        static let defaultZoomLevel: Float = 14
        static let selectedPlacemarkScale: NSNumber = 4
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

private extension YMKPlacemarkMapObject {
    var office: Office? {
        return userData as? Office
    }
    
    func setSelected(_ selected: Bool) {
        guard isValid
        else { return }
		
		let image = selected
			? UIImage.Icons.pinAlfa
				.resized(scale: 4)
				.tintedImage(withColor: .Icons.iconAccent)
				.overlay(with: .Icons.pin.tintedImage(withColor: .Icons.iconContrast))
				
			: UIImage.Icons.pinAlfa
				.resized(scale: 1.5)
				.tintedImage(withColor: .Icons.iconAccent)
				.overlay(with: .Icons.pin.tintedImage(withColor: .Icons.iconContrast))
		
			setIconWith(image)
    }
}
