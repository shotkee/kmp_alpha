//
//  CommonPhotoPickerViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 03.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import LegacyGallery

class FilePickerView: UIView,
                      UICollectionViewDelegate,
                      UICollectionViewDataSource,
                      UIDocumentInteractionControllerDelegate,
                      UICollectionViewDelegateFlowLayout {
	struct Output {
		let openDocument: (Attachment) -> Void
        let pickFile: () -> Void
        let delete: (Attachment) -> Void
        let deleteFromGalleryMedia: (Attachment) -> Void
        let showPhoto: (UIViewController, Bool, (() -> Void)?) -> Void
		let entryStateChanged: (FilePickerFileEntry) -> Void
    }

    var output: Output!

	private var data: [FilePickerFileEntry] = [] {
		didSet {
			if data.isEmpty {
				previewsEntries.removeAll()
			}
			
			for entry in data {
				previewImage(from: entry.attachment?.url)
				
				entry.setStateObserver { _ in
					DispatchQueue.main.async { [weak self] in
						self?.output.entryStateChanged(entry)
					}
				}
			}
			
			documentCollectionView.reloadData()
		}
	}
	
	@discardableResult private func previewImage(from: URL?) -> UIImage? {
		guard let from
		else { return nil }
		
		if let preview = previewsEntries.first(where: {
			$0.0 == from.absoluteString
		}) {
			return preview.1
		} else {
			if let previewImage = image(from: from) {
				previewsEntries.append((from.absoluteString, previewImage))
				
				return previewImage
			} else {
				if from.isImageFile {
					print("resource not exist for \(from)")
				}
			}
		}
		
		return nil
	}
	
	private func image(from: URL?) -> UIImage? {
		guard let from
		else { return nil }
		
		let image: UIImage?
		
		/// fix crashing when system UIImage container CMPhotoCreateImageSurface/CMPhotoSurface is too large - mem overflow
		if let imageData = try? Data(contentsOf: from, options: [.mappedIfSafe, .uncached]) {
			if let imageFromData = UIImage(data: imageData),
			   imageFromData.size.width > 100 {
				image = imageFromData.resized(newWidth: 97)
			} else {
				image = UIImage(data: imageData)
			}
		} else {
			image = nil
		}
		
		return image
	}
	
	private var previewsEntries: [(String, UIImage?)] = []

    private let documentCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()

    private var currentViewIndex: Int = 0
    private var countCollectionCells: Int {
        data.count + (addFileButtonIsHidden ? 0 : 1)
    }

    private let addFileIndex: Int = 0

    // MARK: Init

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    private func commonSetup() {
        setup()
    }

    private func setup() {
        self.addSubview(documentCollectionView)
        
        documentCollectionView.delegate = self
        documentCollectionView.dataSource = self

        documentCollectionView.registerReusableCell(AddDocumentCollectionViewCell.id)
        documentCollectionView.registerReusableCell(DocumentCollectionViewCell.id)
		
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: documentCollectionView, in: self) +
            [
                documentCollectionView.heightAnchor.constraint(equalToConstant: 97)
            ]
        )
    }

    func set(data: [FilePickerFileEntry]) {
        self.data = data
    }
	
	var addFileButtonIsHidden = false {
		didSet {
			documentCollectionView.reloadData()
		}
	}

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        countCollectionCells
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !addFileButtonIsHidden,
		   indexPath.item == addFileIndex {
            let cell = collectionView.dequeueReusableCell(AddDocumentCollectionViewCell.id, indexPath: indexPath)
            return cell
        }

        let cell = collectionView.dequeueReusableCell(DocumentCollectionViewCell.id, indexPath: indexPath)
		
		let entry = data[indexPath.item - (addFileButtonIsHidden ? 0 : 1)]
		
		let previewImage = previewImage(from: entry.attachment?.url)
		
		entry.setStateObserver { state in
			DispatchQueue.main.async {
				let previewImage: UIImage?
				
				switch state {
					case .ready(previewUrl: let url, attachment: _):
						previewImage = self.previewImage(from: url)
						
					case
						.error(previewUrl: let url, attachment: _, _),
						.processing(previewUrl: let url, _, _):
						previewImage = self.previewImage(from: url)
						
				}
				
				cell.configure(
					with: previewImage,
					originalName: entry.attachment?.originalName,
					pathExtension: entry.attachment?.url.pathExtension ?? "",
					for: self.cellState(entryState: state)
				)
				
				self.output.entryStateChanged(entry)
			}
		}
		
		cell.prepareForReuseCallback = {
			entry.deleteStateObserver()
		}
				        		
        cell.deleteHandler = { [unowned self] in
			self.deleteSelected(index: indexPath.item - (self.addFileButtonIsHidden ? 0 : 1))
        }
		
		cell.configure(
			with: previewImage,
			originalName: entry.attachment?.originalName,
			pathExtension: entry.attachment?.url.pathExtension ?? "",
			for: cellState(entryState: entry.state)
		)
		
        return cell
    }
	
	private func cellState(entryState: FilePickerEntryState) -> DocumentCollectionViewCell.State {
		switch entryState {
			 case .ready:
				 return .ready
			 case .processing:
				 return .processing
			 case .error:
				 return .error
		}
	}
	
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !addFileButtonIsHidden,
		   indexPath.item == addFileIndex {
            output.pickFile()
        } else {
			if let fileEntry = data[safe: indexPath.item - (addFileButtonIsHidden ? 0 : 1)],
			   case .ready = fileEntry.state,
			   let document = fileEntry.attachment {
				switch document.type {
					case .photo:
						showPhoto(attachment: document)
					case .file:
						output.openDocument(document)
				}
			}
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if indexPath.item == addFileIndex {
			return Constants.firstCollectionCellSize
        }
        return Constants.collectionViewCellSize
    }

    private func deleteSelected(index: Int) {
		if let attachment = data[safe: index]?.attachment {
			output.delete(attachment)
		}
    }

    private func showPhoto(attachment: Attachment) {
		let entries = data.filter { $0.attachment?.type == .photo }
        let items: [GalleryMedia] = entries
            .compactMap {
				if let image = UIImage(contentsOfFile: $0.attachment?.url.path ?? "") {
					return image
				} else {
					return nil
				}
            }
            .map { .image(GalleryMedia.Image(previewImage: $0, previewImageLoader: nil, fullImage: $0, fullImageLoader: nil)) }

		guard let index = entries.firstIndex(where: { $0.attachment?.id == attachment.id })
		else { return }

        currentViewIndex = index

        let deleteButton = UIButton(type: .custom)
        deleteButton.setTitle(NSLocalizedString("common_delete", comment: ""), for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonTap), for: .touchUpInside)
        deleteButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 10, right: 20)

        let galleryController = GalleryViewController(spacing: 20)
        galleryController.items = items
        galleryController.initialIndex = currentViewIndex
        galleryController.transitionController = GalleryZoomTransitionController()
        galleryController.sharedControls = true
        galleryController.availableControls = [ .close ]
        galleryController.initialControlsVisibility = true
        galleryController.statusBarStyle = .default
        galleryController.setupAppearance = { controller in
            controller.initialControlsVisibility = true
            controller.closeButton.setTitle(NSLocalizedString("common_close_button", comment: ""), for: .normal)

            deleteButton.translatesAutoresizingMaskIntoConstraints = false
            controller.view.addSubview(deleteButton)
            NSLayoutConstraint.activate([
                deleteButton.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
                deleteButton.bottomAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.bottomAnchor),
            ])
        }
        galleryController.pageChanged = { [weak self] currentIndex in
            self?.currentViewIndex = currentIndex
        }
        galleryController.controlsVisibilityChanged = { controlsVisibility in
            deleteButton.alpha = controlsVisibility ? 1 : 0
        }
        output.showPhoto(galleryController, true, nil)
    }

    @objc private func deleteButtonTap() {
		if let document = data.filter { $0.attachment?.type == .photo } [currentViewIndex].attachment {
			output.deleteFromGalleryMedia(document)
		}
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		documentCollectionView.reloadData()
	}
    
    private enum Constants {
        static let firstCollectionCellSize = CGSize(width: 91, height: 97)
        static let collectionViewCellSize = CGSize(width: 97, height: 97)
    }
}
