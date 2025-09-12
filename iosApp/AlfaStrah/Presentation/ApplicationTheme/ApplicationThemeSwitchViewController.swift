//
//  ApplicationThemeSwitchViewController.swift
//  AlfaStrah
//
//  Created by vit on 22.02.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import TinyConstraints

class ApplicationThemeSwitchViewController: ViewController {
	struct Input {
		let currentTheme: UIUserInterfaceStyle
	}
	
	struct Output {
		let selected: (UIUserInterfaceStyle) -> Void
	}
	
	var input: Input!
	var output: Output!
	
	private let scrollView = UIScrollView()
	private let contentStackView = UIStackView()
	private let systemThemeChoiceView = ChoiceView()
	private let lightThemeChoiceView = ChoiceView()
	private let darkThemeChoiceView = ChoiceView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = NSLocalizedString("application_theme", comment: "")
		
		view.backgroundColor = .Background.backgroundContent
		
		setupUI()
	}
	
	private func setupUI() {
		setupScrollView()
		setupContentStackView()
		
		systemThemeChoiceView.configure(
			image: .Illustrations.themeMix,
			title: NSLocalizedString("application_theme_system", comment: ""),
			callback: {[weak self] selected in
				guard let self
				else { return }
				
				if selected {
					self.output.selected(.unspecified)
					self.lightThemeChoiceView.reset()
					darkThemeChoiceView.reset()
				}
			}
		)
		contentStackView.addArrangedSubview(systemThemeChoiceView)
		
		lightThemeChoiceView.configure(
			image: .Illustrations.themeLight,
			title: NSLocalizedString("application_theme_light", comment: ""),
			callback: {[weak self] selected in
				guard let self
				else { return }
				
				if selected {
					self.output.selected(.light)
					self.systemThemeChoiceView.reset()
					self.darkThemeChoiceView.reset()
				}
			}
		)
		contentStackView.addArrangedSubview(lightThemeChoiceView)
		
		darkThemeChoiceView.configure(
			image: .Illustrations.themeDark,
			title: NSLocalizedString("application_theme_dark", comment: ""),
			callback: {[weak self] selected in
				guard let self
				else { return }
				
				if selected {
					self.output.selected(.dark)
					self.systemThemeChoiceView.reset()
					self.lightThemeChoiceView.reset()
				}
			}
		)
		contentStackView.addArrangedSubview(darkThemeChoiceView)
		
		switch input.currentTheme {				
			case .dark:
				darkThemeChoiceView.set()
			case .light:
				lightThemeChoiceView.set()
			case .unspecified:
				fallthrough
			@unknown default:
				systemThemeChoiceView.set()
		}
	}
	
	private func setupScrollView() {
		scrollView.canCancelContentTouches = false
		scrollView.delaysContentTouches = false
		
		view.addSubview(scrollView)
		scrollView.edgesToSuperview()
	}
	
	private func setupContentStackView() {
		scrollView.addSubview(contentStackView)
		
		contentStackView.isLayoutMarginsRelativeArrangement = true
		contentStackView.layoutMargins = UIEdgeInsets(top: 19, left: 31, bottom: 0, right: 31)
		contentStackView.alignment = .top
		contentStackView.distribution = .equalCentering
		contentStackView.axis = .horizontal
		contentStackView.spacing = 0
		contentStackView.backgroundColor = .clear
		
		contentStackView.edgesToSuperview()
		contentStackView.width(to: view)
	}
}
