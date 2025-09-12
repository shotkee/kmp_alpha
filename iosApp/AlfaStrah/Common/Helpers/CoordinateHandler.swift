//
// Created by Roman Churkin on 20/10/15.
// Copyright (c) 2015 RedMadRobot. All rights reserved.
//

import UIKit
import MapKit
import Legacy

final class CoordinateHandler: LoggerDependency {
    var logger: TaggedLogger?

    static func handleCoordinate(_ coordinate: CLLocationCoordinate2D, title: String?) {
        guard let topViewController = UIHelper.topViewController() else { return }

        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: NSLocalizedString("info_proceed_to_map", comment: ""), style: .default) { _ in
            let placeMark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placeMark)
            mapItem.name = title
            mapItem.openInMaps(launchOptions: [ MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving ])
        }
        actionSheet.addAction(action)
        let cancelAction = UIAlertAction(title: NSLocalizedString("common_close_button", comment: ""), style: .cancel)
        actionSheet.addAction(cancelAction)
        topViewController.present(actionSheet, animated: true)
    }

    /// Open route in current apps
    func handleCoordinateToOpenApps(
        _ coordinate: CLLocationCoordinate2D,
        title: String?,
        current: Coordinate?
    ) {
        guard let topViewController = UIHelper.topViewController() else { return }

        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let currentLongitude = current?.clLocationCoordinate.longitude ?? 0
        let currentLatitude = current?.clLocationCoordinate.latitude ?? 0

        let currentYandex = "\(currentLatitude),\(currentLongitude)"
        let toYandex = "\(coordinate.latitude),\(coordinate.longitude)"

        let currentGis = "from/\(currentLongitude),\(currentLatitude)"
        let toGis = "to/\(coordinate.longitude),\(coordinate.latitude)"

        // https://yandex.ru/dev/yandex-apps-launch/maps/doc/concepts/yandexmaps-ios-app.html
        let yandexAction = UIAlertAction(
            title: NSLocalizedString("info_proceed_to_yandex_map", comment: ""),
            style: .default
        ) { [weak self] _ in
            let baseURL: String
            if let url = URL(string: "yandexmaps://"), UIApplication.shared.canOpenURL(url) {
                baseURL = "yandexmaps://maps.yandex.ru"
            } else {
                baseURL = "https://yandex.ru/maps"
            }

            let urlString: String
            if current != nil {
                urlString = "\(baseURL)/?rtext=\(currentYandex)~\(toYandex)&rtt=pd"
            } else {
                let toYandexPoint = "\(coordinate.longitude),\(coordinate.latitude)"
                urlString = "\(baseURL)/?pt=\(toYandexPoint)&z=18&l=map"
            }

            guard let url = URL(string: urlString) else { return }

            self?.logger?.debug("Want to open Yandex")
            UIApplication.shared.open(url, completionHandler: nil)
        }
        actionSheet.addAction(yandexAction)

        // https://help.2gis.ru/question/razrabotchikam-zapusk-mobilnogo-prilozheniya-2gis
        let gisAction = UIAlertAction(
            title: NSLocalizedString("info_proceed_to_2gis_map", comment: ""),
            style: .default
        ) { [weak self] _ in

            let baseURL: String
            if let url = URL(string: "dgis://"), UIApplication.shared.canOpenURL(url) {
                baseURL = "dgis://2gis.ru"
            } else {
                baseURL = "https://2gis.ru"
            }

            let urlString: String
            if current != nil {
                urlString = "\(baseURL)/routeSearch/rsType/pedestrian/\(currentGis)/\(toGis)"
            } else {
                let to2GisPoint = "\(coordinate.longitude)%2C\(coordinate.latitude)"
                urlString = "\(baseURL)/firm/\(to2GisPoint)?m=\(to2GisPoint)%2F18"
            }

            guard let url = URL(string: urlString) else { return }

            self?.logger?.debug("Want to open 2GIS")
            UIApplication.shared.open(url, completionHandler: nil)
        }
        actionSheet.addAction(gisAction)

		actionSheet.actions.forEach { $0.setValue(UIColor.Text.textPrimary, forKey: "titleTextColor") }

        let cancelAction = UIAlertAction(title: NSLocalizedString("common_close_button", comment: ""), style: .cancel)
        actionSheet.addAction(cancelAction)
        topViewController.present(actionSheet, animated: true)
    }
}
