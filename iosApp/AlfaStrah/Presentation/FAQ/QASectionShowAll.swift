//
//  QASectionShowAll.swift
//  AlfaStrah
//
//  Created by mac on 07.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

class QASectionShowAll: UIView {
    struct Output {
        let tapOnView: () -> Void
    }
    
    var output: Output!
    
    @objc private func tapOnView() {
        output.tapOnView()
    }
    
    override required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    private func setupUI() {
        self.layer.cornerRadius = 16
        self.backgroundColor = .Background.backgroundAdditional
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 120),
            self.heightAnchor.constraint(equalToConstant: 208)
        ])
        
        let stackView: UIStackView = {
            let stack = UIStackView()
            stack.spacing = 9
            stack.axis = .vertical
            stack.distribution = .fill
            stack.alignment = .center
            return stack
        }()
        
        let imageView = UIImageView()
        imageView.image = .Icons.arrowInCircle
        imageView.tintColor = .Icons.iconAccent

        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("main_questions_show_all_button_title", comment: "")
        titleLabel <~ Style.Label.accentSubhead
        
        self.addSubview(stackView)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16)
        ])
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnView))
        addGestureRecognizer(tapGestureRecognizer)
    }
}
