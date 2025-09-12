//
//  SosTableViewCell.swift
//  AlfaStrah
//
//  Created by Makson on 09.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import SDWebImage

class SosTableViewCell: UITableViewCell {
    static let id: Reusable<SosTableViewCell> = .fromClass()
    
    private var verticalStackView = UIStackView()
    private var warningView = UIView()
    private var warningLabel = UILabel()
    private var warningIconImageView = UIImageView()
    
    private var sosListAndIconColors: [SosModelAndIconURL] = []
    private var sosViewArray: [UIView] = []
    
    var tapCallback: ((SosModel) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }
    
    private func setupUI() {
        clipsToBounds = false
        contentView.clipsToBounds = false
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        setupVerticalStackView()
    }
    
    private func setupVerticalStackView() {
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 12
        contentView.addSubview(verticalStackView)
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 16
            ),
            verticalStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 18
            ),
            verticalStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -18
            ),
            verticalStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -8
            )
        ])
    }
    
    private func setupWarningView() {
        warningView.backgroundColor = .Background.backgroundTertiary
        warningView.clipsToBounds = true
        warningView.layer.cornerRadius = 10
        verticalStackView.addArrangedSubview(warningView)
        verticalStackView.setCustomSpacing(20, after: warningView)
        warningIconImageView.translatesAutoresizingMaskIntoConstraints = false
        warningView.addSubview(warningIconImageView)
        NSLayoutConstraint.activate([
            warningIconImageView.topAnchor.constraint(
                equalTo: warningView.topAnchor,
                constant: 12
            ),
            warningIconImageView.leadingAnchor.constraint(
                equalTo: warningView.leadingAnchor,
                constant: 12
            ),
            warningIconImageView.heightAnchor.constraint(
                equalToConstant: 18
            ),
            warningIconImageView.widthAnchor.constraint(
                equalTo: warningIconImageView.heightAnchor,
                multiplier: 1
            )
        ])
        
        warningLabel <~ Style.Label.primarySubhead
        warningLabel.numberOfLines = 0
        warningLabel.textAlignment = .left
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        warningView.addSubview(warningLabel)
        NSLayoutConstraint.activate([
            warningLabel.topAnchor.constraint(
                equalTo: warningView.topAnchor,
                constant: 12
            ),
            warningLabel.leadingAnchor.constraint(
                equalTo: warningView.leadingAnchor,
                constant: 39
            ),
            warningLabel.trailingAnchor.constraint(
                equalTo: warningView.trailingAnchor,
                constant: -12
            ),
            warningLabel.bottomAnchor.constraint(
                equalTo: warningView.bottomAnchor,
                constant: -12
            )
        ])
    }
    
    private func createLineSosModelView(
        sosModelList: [SosModelAndIconURL]
    ) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        let horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 12
        horizontalStackView.distribution = .fillEqually
        containerView.addSubview(horizontalStackView)
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            horizontalStackView.topAnchor.constraint(
                equalTo: containerView.topAnchor
            ),
            horizontalStackView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor
            ),
            horizontalStackView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor
            ),
            horizontalStackView.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor
            )
        ])
        
        sosModelList.forEach { sosModel in
            horizontalStackView.addArrangedSubview(
                createSosContainerView(
                    sosModel: sosModel,
                    isOneElement: sosModelList.count == 1
                )
            )
        }
        
        return containerView
    }
    
    private func createSosContainerView(
        sosModel: SosModelAndIconURL,
        isOneElement: Bool
    ) -> UIView {
        let sosView = createSosView(
            sosModel: sosModel,
            isOneElement: isOneElement
        )
        sosView.backgroundColor = .Background.backgroundSecondary
        
        sosViewArray.append(sosView)
                
        return sosView.embedded(hasShadow: true, cornerRadius: 16)
    }
    
    private func createSosView(
        sosModel: SosModelAndIconURL,
        isOneElement: Bool
    ) -> UIView {
        
		guard let title = sosModel.sosModel.insuranceCategory?.title,
			  let description = sosModel.sosModel.insuranceCategory?.description
        else { return UIView() }
        
        let view = UIView()
        view.backgroundColor = .clear
        
        let imageContainerView = createIconImageView(
			iconURL: sosModel.iconURL
        )
        
        view.addSubview(imageContainerView)
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            imageContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageContainerView.heightAnchor.constraint(equalToConstant: 40),
            imageContainerView.widthAnchor.constraint(
                equalTo: imageContainerView.heightAnchor,
                multiplier: 1
            )
        ])
        
        let infoView = createInfoView(
            title: title,
            description: description
        )
        
        view.addSubview(infoView)
        infoView.translatesAutoresizingMaskIntoConstraints = false
        
        if isOneElement {
            NSLayoutConstraint.activate([
                infoView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
                infoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
                infoView.leadingAnchor.constraint(equalTo: imageContainerView.trailingAnchor, constant: 12),
                infoView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
            ])
        }
        else {
            NSLayoutConstraint.activate([
                infoView.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: 10),
                infoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                infoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                infoView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
            ])
        }
        
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTapView(_:))
        )
        
        view.addGestureRecognizer(tap)
        
        return view
    }
    
    @objc private func handleTapView(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view,
              let index = sosViewArray.firstIndex(where: { $0 === view }),
			  let sosModel = sosListAndIconColors[safe: index]?.sosModel
        else { return }
            
        tapCallback?(sosModel)
    }
    
	private func createIconImageView(iconURL: URL?) -> UIView {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.backgroundColor = .Background.backgroundTertiary
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.sd_setImage(
            with: iconURL,
            completed: { [weak self] image, _, _, _ in
                
                iconImageView.isHidden = image == nil
                iconImageView.image = image
            }
        )
        view.addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: iconImageView, in: view)
        )
        
        return view
    }
    
    private func createInfoView(
        title: String,
        description: String
    ) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: stackView, in: view)
        )
        
        let titleLabel = UILabel()
        titleLabel <~ Style.Label.primaryHeadline3
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .left
        titleLabel.text = title
        stackView.addArrangedSubview(titleLabel)
        
        let descriptionLabel = UILabel()
        descriptionLabel <~ Style.Label.secondarySubhead
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .left
        descriptionLabel.text = description
        stackView.addArrangedSubview(descriptionLabel)
        
        return view
    }
}

struct SosModelAndIconURL {
	let sosModel: SosModel
	let iconURL: URL?
}

extension SosTableViewCell {
    func configure(
        sosListAndColors: [SosModelAndIconURL],
		iconURL: URL?,
        information: SosEmergencyConnectionScreenInformation? = nil
    ) {
		self.sosListAndIconColors = sosListAndColors
        sosViewArray = []
        verticalStackView.subviews.forEach { $0.removeFromSuperview() }
        setupWarningView()

        if let information = information {
            warningLabel.text = information.title
            warningIconImageView.sd_setImage(
				with: iconURL
            )
            warningView.isHidden = false
        } else {
            warningView.isHidden = true
        }

		let groupSosList = sosListAndIconColors.chunks(chunkSize: 2)
		groupSosList.forEach { sosList in
            verticalStackView.addArrangedSubview(
                createLineSosModelView(
					sosModelList: sosList
                )
            )
        }
    }
}
