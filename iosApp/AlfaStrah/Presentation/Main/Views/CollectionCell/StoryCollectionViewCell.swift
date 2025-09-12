//
//  StoryCollectionViewCell.swift
//  AlfaStrah
//
//  Created by Makson on 06.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import SDWebImage

class StoryCollectionViewCell: UICollectionViewCell {
    static let id: Reusable<StoryCollectionViewCell> = .fromClass()
    
    // MARK: - Outlets
    private let containerView = UIView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private var isLoadingImage = false
    
    private lazy var gradientView: GradientView = {
        var value: GradientView = .init(frame: .zero)
        value.startPoint = CGPoint(x: 0.5, y: 0.97)
        value.endPoint = CGPoint(x: 0.5, y: 0.03)

        value.startColor = .Other.imageOverlayStart
        value.endColor = .Other.imageOverlayStop
        value.update()
        return value
    }()
    
    // MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundView?.isOpaque = true
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setupContentView()
        setupContainerView()
        setupImageView()
        setupGradientView()
        setupTitleLabel()
    }
    
    private func setupContentView() {
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 15
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.Stroke.strokeAccent.cgColor
    }
    
    private func setupContainerView() {
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 10
        containerView.backgroundColor = .clear
        containerView.isUserInteractionEnabled = false
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }
    
    private func setupImageView() {
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        containerView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: imageView, in: containerView)
        )
    }
    
    private func setupGradientView(){
        gradientView.isHidden = true
        containerView.addSubview(gradientView)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: gradientView, in: containerView)
        )
    }
    
    private func setupTitleLabel() {
        titleLabel.numberOfLines = 4
        titleLabel.font = Style.Font.headline3
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
    }
    
    func set(
        story: Story
    ) {
        titleLabel.text = story.title
        gradientView.isHidden = true
        imageView.isHidden = true
        imageView.sd_setImage(
            with: story.preview,
            placeholderImage: nil,
            completed: { [weak self] (img, err, _, _) in
                if img != nil {
                    self?.isLoadingImage = true
                    self?.containerView.layer.removeAllAnimations()
                    self?.containerView.backgroundColor = .clear
                    self?.imageView.isHidden = false
                    self?.gradientView.isHidden = false
                }
            }
        )
        
        titleLabel.textColor = .from(hex: story.titleColor)
        
        switch story.status {
            case .viewed:
                contentView.layer.borderColor = UIColor.Stroke.strokeBorder.cgColor
            case .unviewed:
                contentView.layer.borderColor = UIColor.Stroke.strokeAccent.cgColor
        }
    }
    
    func updateColorContainerView() {
        if isLoadingImage {
            return
        }
        containerView.layer.removeAllAnimations()
        UIView.animateKeyframes(
            withDuration: 2,
            delay: 0,
            options: [.repeat],
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                    self.containerView.backgroundColor = .States.strokeDisabled
                })
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                    self.containerView.backgroundColor = .Stroke.strokeBorder
                })
            },
            completion: nil
        )
    }
}
