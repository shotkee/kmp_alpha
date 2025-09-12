//
//  CompletionNetworkImageView.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 08.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class CompletionNetworkImageView: UIImageView {
    private var resizeMode: ResizeMode = .fill
    private var placeholder: UIImage?
    private var imageContentMode: UIView.ContentMode = .scaleAspectFill
    private var placeholderContentMode: UIView.ContentMode = .scaleAspectFill
    private var completion: ((UIImage) -> Void)?
    private var task: ImageLoaderTask?
    var imageLoader: ImageLoader?

    var imageUrl: URL? {
        didSet {
            update()
        }
    }

    func configure(
        placeholder: UIImage? = nil,
        contentMode: UIView.ContentMode?,
        placeholderContentMode: UIView.ContentMode?,
        completion: ((UIImage) -> Void)?
    ) {
        backgroundColor = .Background.backgroundTertiary
        self.placeholder = placeholder
        self.completion = completion
        contentMode.map { imageContentMode = $0 }
        placeholderContentMode.map { self.placeholderContentMode = $0 }
    }

    func stopLoading() {
        task?.cancel()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        if !loading && image == nil {
            update()
        }
    }

    private var loading: Bool = false

    private func update() {
        contentMode = placeholderContentMode
        image = placeholder

        guard let imageLoader = imageLoader,
			  let imageUrl = imageUrl
        else { return }

        loading = true

        task = imageLoader.load(url: imageUrl, size: frame.size, mode: resizeMode) { [weak self] result in
            guard let self,
                  imageUrl == self.imageUrl
                else { return }

            self.loading = false
            
            guard let image = result.value?.1
            else { return }

            self.addFadeTransition()
            self.contentMode = self.imageContentMode
            self.image = image
            self.completion?(image)
        }
    }
}
