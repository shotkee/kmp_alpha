//
//  PhotoPickerBottomViewController.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 21.07.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class PhotoPickerBottomViewController: BaseBottomSheetViewController {
    struct Input {
        let title: () -> String
        let infoText: () -> String
        let numberOfCards: Int
        let photo: (_ atIndex: Int) -> UIImage?
    }

    struct Output {
        let selected: (_ atIndex: Int) -> Void
        let delete: (_ atIndex: Int) -> Void
        let close: () -> Void
        let done: () -> Void
    }

    struct Notify {
        let infoUpdated: () -> Void
    }

    var input: Input!
    var output: Output!

    private(set) lazy var notify: Notify = .init(
        infoUpdated: { [weak self] in
            self?.updateUI()
        }
    )

    private lazy var photoPickerView: PhotoPickerView = .init()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func setupUI() {
        super.setupUI()

        set(title: input.title())
        set(style: .actions(
                        primaryButtonTitle: NSLocalizedString("common_save", comment: ""),
                        secondaryButtonTitle: nil
                    )
        )
        set(infoText: input.infoText())
        set(doneButtonEnabled: true)
        set(views: [ photoPickerView ])

        closeTapHandler = output.close
        primaryTapHandler = output.done

        photoPickerView.output = .init(
            selected: { [unowned self] index in
                self.output.selected(index)
            },
            delete: { [unowned self] index, _ in
                self.output.delete(index)
            },
            photosPicked: { _ in }
        )

        photoPickerView.configure(
            type: .camera,
            size: .small,
            numberOfCards: input.numberOfCards,
            shouldShowInfoString: true
        )

        updateUI()
    }

    private func updateUI() {
        for index in 0..<input.numberOfCards {
            photoPickerView.set(input.photo(index), at: index)
        }
    }
}
