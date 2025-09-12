//
// Permissions
// AlfaStrah
//
// Created by Eugene Egorov on 07 December 2018.
// Copyright (c) 2018 Redmadrobot. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

enum Permission {
    case notDetermined
    case restricted
    case denied
    case authorized
}

class Permissions: NSObject {
    static var camera: Permission {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .notDetermined:
                return .notDetermined
            case .restricted:
                return .restricted
            case .denied:
                return .denied
            case .authorized:
                return .authorized
            @unknown default:
                return .notDetermined
        }
    }

    static func camera(completion: @escaping (_ granted: Bool) -> Void) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            let title = NSLocalizedString("common_camera_unavailable_title", comment: "")
            let message = NSLocalizedString("common_camera_unavailable_message", comment: "")
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            let cancelAction = UIAlertAction(title: NSLocalizedString("common_close_button", comment: ""), style: .cancel) { _ in
                completion(false)
            }
            alert.addAction(cancelAction)
            UIHelper.topViewController()?.present(alert, animated: true)
            return
        }

        let localCompletion = { (granted: Bool) in
            DispatchQueue.main.async {
                if granted {
                    completion(granted)
                } else {
                    let title = NSLocalizedString("permission_camera_denied_title", comment: "")
                    let message = NSLocalizedString("permission_camera_denied_text", comment: "")
                    let alert = UIAlertController(
                        title: title,
                        message: message,
                        preferredStyle: .alert
                    )
                    let cancelAction = UIAlertAction(title: NSLocalizedString("common_close_button", comment: ""), style: .default) { _ in
                        completion(granted)
                    }
                    alert.addAction(cancelAction)
                    UIHelper.topViewController()?.present(alert, animated: true)
                }
            }
        }

        switch camera {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video, completionHandler: localCompletion)
            case .restricted:
                localCompletion(false)
            case .denied:
                localCompletion(false)
            case .authorized:
                localCompletion(true)
        }
    }

    static var photoLibrary: Permission {
        switch PHPhotoLibrary.authorizationStatus() {
            case .notDetermined:
                return .notDetermined
            case .restricted:
                return .restricted
            case .denied:
                return .denied
            case .authorized:
                return .authorized
            case .limited:
                return .authorized
            @unknown default:
                return .notDetermined
        }
    }

    enum PhotoLibraryAccessLevel {
        case addOnly
        case readWrite
    }

    static func photoLibrary(for level: PhotoLibraryAccessLevel, completion: @escaping (_ granted: Bool) -> Void) {
        let localCompletion = { (granted: Bool) in
            DispatchQueue.main.async {
                if granted {
                    completion(granted)
                } else {
                    let title = NSLocalizedString("permission_photo_library_denied_title", comment: "")
                    let message = NSLocalizedString("permission_photo_library_denied_text", comment: "")
                    let alert = UIAlertController(
                        title: title,
                        message: message,
                        preferredStyle: .alert
                    )
                    let cancelAction = UIAlertAction(title: NSLocalizedString("common_close_button", comment: ""), style: .default) { _ in
                        completion(granted)
                    }
                    alert.addAction(cancelAction)
                    UIHelper.topViewController()?.present(alert, animated: true)
                }
            }
        }

        switch photoLibrary {
            case .notDetermined:
                if #available(iOS 14, *) {
                    let accessLevel: PHAccessLevel
                    switch level {
                        case .addOnly:
                            accessLevel = .addOnly
                        case .readWrite:
                            accessLevel = .readWrite
                    }

                    PHPhotoLibrary.requestAuthorization(for: accessLevel) { status in
                        localCompletion(status == .authorized)
                    }
                } else {
                    PHPhotoLibrary.requestAuthorization { status in
                        localCompletion(status == .authorized)
                    }
                }
            case .authorized:
                localCompletion(true)
            case .denied:
                localCompletion(false)
            case .restricted:
                localCompletion(false)
        }
    }
}
