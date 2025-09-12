//
//  EuroProtocolPhotoPickerCollectionViewCell.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 01.04.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class EuroProtocolPhotoPickerCollectionViewCell: UICollectionViewCell {
    static let id: Reusable<EuroProtocolPhotoPickerCollectionViewCell> = .fromNib()

    @IBOutlet private var rootView: UIView!
    @IBOutlet private var imagePhotoView: UIImageView!
    @IBOutlet private var closeButton: UIButton!

    private let cornerRadius: CGFloat = 6

    func set(photo: UIImage?) {
        imagePhotoView.image = photo
        closeButton.isHidden = photo == nil
    }

    var deleteHandler: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    private func setupUI() {
        rootView.layer.cornerRadius = cornerRadius
        rootView.layer.masksToBounds = true

        imagePhotoView.layer.cornerRadius = cornerRadius
        imagePhotoView.layer.masksToBounds = true

        closeButton.layer.cornerRadius = 12
        closeButton.layer.masksToBounds = true

        closeButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        closeButton.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        closeButton.layer.shadowOpacity = 1.0
        closeButton.layer.shadowRadius = 0.0

        closeButton.isHidden = true
    }

    @IBAction func deleteAction(_ sender: Any) {
        deleteHandler?()
    }

}
