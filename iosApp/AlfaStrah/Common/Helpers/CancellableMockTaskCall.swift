//
//  CancellableMockTaskCall.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 04.03.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import Legacy

class CancellableMockTask<ResultType>: NetworkTask {
    typealias CompletionType = (ResultType) -> Void

    private(set) var isCancelled = false
    var delay: TimeInterval = 0.5
    private let result: ResultType
    private let completion: CompletionType

    init(result: ResultType, completion: @escaping CompletionType) {
        self.result = result
        self.completion = completion
    }

    func start() {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if !self.isCancelled {
                self.completion(self.result)
            }
        }
    }

    func cancel() {
        isCancelled = true
    }

    private class HttpMockProgress: HttpProgress {
        let bytes: Int64? = nil
        let totalBytes: Int64? = nil
        var callback: Legacy.HttpProgressCallback?
        func setCallback(_ callback: HttpProgressCallback?) {
            self.callback = callback
        }
    }

    var uploadProgress: HttpProgress {
        HttpMockProgress()
    }

    var downloadProgress: HttpProgress {
        HttpMockProgress()
    }
}
