//
//  PhotoPickerViewController.swift
//  AlfaStrah
//
//  Created by Elizaveta Prokudina on 07.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//
import UIKit

class PhotoPickerViewController: ViewController, AttachmentServiceDependency {
    private var scrollView: UIScrollView = .init()
    private var scrollContentView: UIView = .init()

    private var photoSelectionBehaviour = DocumentPickerBehavior()
    var attachmentService: AttachmentService!

    struct Input {
        let title: String
    }

    var input: Input!

    private lazy var rootStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 10
        return stack
    }()

    private struct PhotoPickerDataSource {
        let cellAmount: Int
        let type: PhotoPickerView.PhotoCardType
        let size: PhotoPickerView.PhotoCardSize
        let shouldShowInfoString: Bool
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        commonSetup()
    }

    private func commonSetup() {
        setupUI()
        title = input.title
        view.backgroundColor = Style.Color.background

        scrollView.backgroundColor = .clear
        scrollContentView.backgroundColor = .clear
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(rootStackView)
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: scrollView, in: view) +
                NSLayoutConstraint.fill(view: scrollContentView, in: scrollView) +
                NSLayoutConstraint.fill(view: rootStackView, in: scrollContentView, margins: Style.Margins.defaultInsets) +
                [ scrollContentView.widthAnchor.constraint(equalToConstant: view.bounds.width) ]
        )
    }

    private func setupUI() {
        [
            PhotoPickerDataSource(
                cellAmount: 3,
                type: .camera,
                size: .big,
                shouldShowInfoString: false
            ),
            PhotoPickerDataSource(
                cellAmount: 2,
                type: .camera,
                size: .small,
                shouldShowInfoString: false
            ),
            PhotoPickerDataSource(
                cellAmount: 2,
                type: .file,
                size: .big,
                shouldShowInfoString: true),
            PhotoPickerDataSource(
                cellAmount: 4,
                type: .file,
                size: .small,
                shouldShowInfoString: true
            ),
            PhotoPickerDataSource(
                cellAmount: 2,
                type: .plus,
                size: .big,
                shouldShowInfoString: false
            ),
            PhotoPickerDataSource(
                cellAmount: 2,
                type: .plus,
                size: .small,
                shouldShowInfoString: false
            ),
        ].forEach {
            let photoPickerView = PhotoPickerView()
            let pickerCellAmount = $0.cellAmount

            photoPickerView.output = .init(
                selected: { [unowned self] index in
                    self.pickPhotos(at: index, pickerView: photoPickerView)
                },
                delete: { _, completion in completion(true) },
                photosPicked: { amount in
                    let message = amount == pickerCellAmount
                        ? "Enough photos added"
                        : "Not enough photos added"
                    self.logger?.debug(message)
                }
            )
            photoPickerView.configure(
                type: $0.type,
                size: $0.size,
                numberOfCards: $0.cellAmount,
                shouldShowInfoString: $0.shouldShowInfoString
            )

            photoPickerView.set(UIImage(named: "image-points-alfa"), at: 1)

            photoPickerView.layer.borderColor = Style.Color.Palette.lightGray.cgColor
            photoPickerView.layer.borderWidth = 1
            rootStackView.addArrangedSubview(photoPickerView)
        }
    }

    func pickPhotos(at index: Int, pickerView: PhotoPickerView) {
        photoSelectionBehaviour.pickDocuments(
            self,
            attachmentService: attachmentService,
            sources: pickerView.photoCardType.cardSource,
            maxDocuments: 1
        ) {
            let myUrl = $0[0].url
            let myData = try? Data(contentsOf: myUrl)
            if let myData = myData {
                pickerView.set(UIImage(data: myData), at: index)
            }
        }
    }
}
