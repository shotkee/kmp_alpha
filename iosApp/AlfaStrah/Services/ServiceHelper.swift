//
// ServiceHelper
// AlfaStrah
//
// Created by Eugene Egorov on 23 November 2018.
// Copyright (c) 2018 Redmadrobot. All rights reserved.
//

import Legacy

func mapCompletion<T>(_ completion: @escaping (Result<T, AlfastrahError>) -> Void) -> (Result<T, NetworkError>) -> Void {
    let result: (Result<T, NetworkError>) -> Void = { networkResult in
        completion(networkResult.mapError {
            switch $0 {
                case .error(_, _, let data), .http(_, _, _, let data):
					let infoMessageTransformer = SingleParameterTransformer(key: "info_message", transformer: InfoMessageTransformer())
					let errorInfoTransformer = SingleParameterTransformer(key: "error", transformer: infoMessageTransformer)
					
					if let infoMessage = JsonModelTransformerHttpSerializer(transformer: errorInfoTransformer).deserialize(data).value {
						return .infoMessage(infoMessage)
					}
					
                    let errorTransformer = SingleParameterTransformer(key: "error", transformer: APIErrorTransformer())
                    let apiErrorResult = JsonModelTransformerHttpSerializer(transformer: errorTransformer).deserialize(data)
                    guard let apiError = apiErrorResult.value else { return .network($0) }

                    return .api(apiError)
                default:
                    return .network($0)
            }
        })
    }
	
    return result
}

func mapUpdateCompletion<T>(_ completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) -> (Result<T, AlfastrahError>) -> Void {
    let result: (Result<T, AlfastrahError>) -> Void = {
        switch $0 {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(.error(error)))
        }
    }
	
    return result
}

/// Executes a closure with a background task synchronously.
func withBackgroundTask(closure: () -> Void) {
    let taskId = UIApplication.shared.beginBackgroundTask()
    closure()
    UIApplication.shared.endBackgroundTask(taskId)
}

/// Executes a closure with a background task asynchronously.
func withBackgroundTask<T>(closure: (_ endTask: @escaping () -> Void) -> T) -> T {
    let taskId = UIApplication.shared.beginBackgroundTask()
    return closure {
        UIApplication.shared.endBackgroundTask(taskId)
    }
}

class BackgroundTask {
    private var backgroundTaskId: UIBackgroundTaskIdentifier?
    var rawId: Int? { backgroundTaskId == .invalid ? nil : backgroundTaskId?.rawValue }

    init(name: String, expirationHandler: (() -> Void)? = nil) {
        backgroundTaskId = UIApplication.shared.beginBackgroundTask(withName: name) {
            expirationHandler?()
            self.endTask()
        }
    }

    func endTask() {
        backgroundTaskId.map { UIApplication.shared.endBackgroundTask($0) }
    }
	
    static func endTask(rawId: Int?) {
        if let backgroundId = rawId.map({ UIBackgroundTaskIdentifier(rawValue: $0) }) {
            UIApplication.shared.endBackgroundTask(backgroundId)
        }
    }
}
