//
//  AlfaColors.swift
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 13.03.2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy
import CoreText
import Foundation

// swiftlint:disable file_length
enum Style {
	enum Color {
		enum Palette {
			static let white = UIColor.fromRequired(hex: "ffffff")
			static let seaShell = UIColor.fromRequired(hex: "F1F1F1")
			static let whiteGray = UIColor.fromRequired(hex: "F2F2F6")
			static let lightGray = UIColor.fromRequired(hex: "DCDCE7")
			static let gray = UIColor.fromRequired(hex: "999999")
			static let gray2 = UIColor.fromRequired(hex: "B3B3CB")
			static let darkGray = UIColor.fromRequired(hex: "7C7C89")
			static let darkGray2 = UIColor.fromRequired(hex: "E7E7EE")
			static let darkGray3 = UIColor.fromRequired(hex: "E6E6ED")
			static let black = UIColor.fromRequired(hex: "000000")
			static let whiteRed = UIColor.fromRequired(hex: "F9E8EB")
			static let lightRed = UIColor.fromRequired(hex: "e56353")
			static let red = UIColor.fromRequired(hex: "e51937")
			static let red2 = UIColor.fromRequired(hex: "FFF7FA")
			static let red3 = UIColor.fromRequired(hex: "FFE3E7")
			static let darkRed = UIColor.fromRequired(hex: "CF1530")
			static let pink = UIColor.fromRequired(hex: "FF798D")
			static let lightPink = UIColor.fromRequired(hex: "FFDCE2")
			static let yellow = UIColor.fromRequired(hex: "FFDF0D")
			static let lightYellow = UIColor.fromRequired(hex: "fff7e0")
			static let green = UIColor.fromRequired(hex: "12E06E")
			static let shadowNavy = UIColor.fromRequired(hex: "154578")
			static let blue = UIColor.blue
		}

		static let main = Palette.red
		static let background = Palette.white
		static let alternateBackground = Palette.whiteGray
		static let separator = Palette.gray
		static let shadow = Palette.shadowNavy

		static let text = Palette.black
		static let whiteText = Palette.white
		static let grayedText = UIColor.Text.textSecondary
		static let lightGrayText = Palette.lightGray
		static let errorText = Palette.red
	}
	
	enum Font {
		private static func regular(size: CGFloat) -> UIFont {
			return UIFont(name: "TTNormsPro-Rg", size: size)
				?? UIFont.systemFont(ofSize: size, weight: .regular)
		}
		
		private static func medium(size: CGFloat) -> UIFont {
			return UIFont(name: "TTNormsPro-Md", size: size)
				?? UIFont.systemFont(ofSize: size, weight: .medium)
		}
		
		private static func normal(size: CGFloat) -> UIFont {
			return UIFont(name: "TTNormsPro-Normal", size: size)
				?? UIFont.systemFont(ofSize: size, weight: .light)
		}
		
		private static func demiBold(size: CGFloat) -> UIFont {
			return UIFont(name: "TTNormsPro-DmBd", size: size)
				?? UIFont.systemFont(ofSize: size, weight: .semibold)
		}
		
		private static func italic(size: CGFloat) -> UIFont {
			return UIFont(name: "TTNormsPro-Italic", size: size)
				?? UIFont.systemFont(ofSize: size, weight: .regular)
		}
		
		// MARK: - Font styles
		static let buttonKeyboard = normal(size: 32)
		static let buttonLarge = normal(size: 16)
		static let buttonSmall = normal(size: 13)
		static let caption1 = normal(size: 11)
		static let caption2 = demiBold(size: 10)
		static let headline1 = demiBold(size: 16)
		static let headline2 = normal(size: 16)
		static let headline3 = demiBold(size: 13)
		static let headline4 = normal(size: 15)
		static let subhead = normal(size: 13)
		static let subhead2 = normal(size: 12)
		static let text = normal(size: 15)
		static let title1 = demiBold(size: 24)
		static let title2 = demiBold(size: 20)
		
		static let textItalic = italic(size: 15) // font for italic transformation with style apply
	}

	enum Label {
		struct ColoredLabel: Applicable {
			let titleColor: UIColor
			let font: UIFont

			func apply(_ object: UILabel) {
				object.textColor = titleColor
				object.font = font
			}

			var textAttributes: [NSAttributedString.Key: Any] {
				[
					.foregroundColor: titleColor,
					.font: font
				]
			}
		}
		
		// MARK: - Label styles / alphabet name order in mark-sections
		// MARK: - ButtonLarge
		static let primaryButtonLarge = ColoredLabel(titleColor: .Text.textPrimary, font: Font.buttonLarge)
		// MARK: - ButtonSmall
		static let accentButtonSmall = ColoredLabel(titleColor: .Text.textAccent, font: Font.buttonSmall)
		static let contrastButtonSmall = ColoredLabel(titleColor: .Text.textContrast, font: Font.buttonSmall)
		// MARK: - Headline1
		static let accentHeadline1 = ColoredLabel(titleColor: .Text.textAccent, font: Font.headline1)
		static let contrastHeadline1 = ColoredLabel(titleColor: .Text.textContrast, font: Font.headline1)
		static let linkHeadline1 = ColoredLabel(titleColor: .Text.textLink, font: Font.headline1)
		static let primaryHeadline1 = ColoredLabel(titleColor: .Text.textPrimary, font: Font.headline1)
		static let secondaryHeadline1 = ColoredLabel(titleColor: .Text.textSecondary, font: Font.headline1)
		static let tertiaryHeadline1 = ColoredLabel(titleColor: .Text.textTertiary, font: Font.headline1)
		// MARK: - Headline2
		static let accentHeadline2 = ColoredLabel(titleColor: .Text.textAccent, font: Font.headline2)
		static let contrastHeadline2 = ColoredLabel(titleColor: .Text.textContrast, font: Font.headline2)
		static let primaryHeadline2 = ColoredLabel(titleColor: .Text.textPrimary, font: Font.headline2)
		static let secondaryHeadline2 = ColoredLabel(titleColor: .Text.textSecondary, font: Font.headline2)
		// MARK: - Headline3
		static let accentHeadline3 = ColoredLabel(titleColor: .Text.textAccent, font: Font.headline3)
		static let contrastHeadline3 = ColoredLabel(titleColor: .Text.textContrast, font: Font.headline3)
		static let primaryHeadline3 = ColoredLabel(titleColor: .Text.textPrimary, font: Font.headline3)
		static let secondaryHeadline3 = ColoredLabel(titleColor: .Text.textSecondary, font: Font.headline3)
		// MARK: - Subhead
		static let accentSubhead = ColoredLabel(titleColor: .Text.textAccent, font: Font.subhead)
		static let contrastSubhead = ColoredLabel(titleColor: .Text.textContrast, font: Font.subhead)
		static let contrastSubhead2 = ColoredLabel(titleColor: .Text.textAccent, font: Font.subhead2)
		static let negativeSubhead = ColoredLabel(titleColor: .Text.textNegative, font: Font.subhead)
		static let primarySubhead = ColoredLabel(titleColor: .Text.textPrimary, font: Font.subhead)
		static let secondarySubhead = ColoredLabel(titleColor: .Text.textSecondary, font: Font.subhead)
		// MARK: - Text
		static let accentText = ColoredLabel(titleColor: .Text.textAccent, font: Font.text)
		static let accentThemedText = ColoredLabel(titleColor: .Text.textAccentThemed, font: Font.text)
		static let contrastText = ColoredLabel(titleColor: .Text.textContrast, font: Font.text)
		static let contrastText2 = ColoredLabel(titleColor: .Text.textContrast, font: Font.subhead2)
		static let primaryText = ColoredLabel(titleColor: .Text.textPrimary, font: Font.text)
		static let secondaryText = ColoredLabel(titleColor: .Text.textSecondary, font: Font.text)
		static let tertiaryText = ColoredLabel(titleColor: .Text.textTertiary, font: Font.text)
		// MARK: - Title1
		static let contrastTitle1 = ColoredLabel(titleColor: .Text.textContrast, font: Font.title1)
		static let primaryTitle1 = ColoredLabel(titleColor: .Text.textPrimary, font: Font.title1)
		// MARK: - Title2
		static let primaryTitle2 = ColoredLabel(titleColor: .Text.textPrimary, font: Font.title2)
		// MARK: - Caption1
		static let accentCaption1 = ColoredLabel(titleColor: .Text.textAccent, font: Font.caption1)
		static let contrastCaption1 = ColoredLabel(titleColor: .Text.textContrast, font: Font.caption1)
		static let primaryCaption1 = ColoredLabel(titleColor: .Text.textPrimary, font: Font.caption1)
		static let secondaryCaption1 = ColoredLabel(titleColor: .Text.textSecondary, font: Font.caption1)
		static let tertiaryCaption1 = ColoredLabel(titleColor: .Text.textTertiary, font: Font.caption1)
		// MARK: - Caption2
		static let contrastCaption2 = ColoredLabel(titleColor: .Text.textContrast, font: Font.caption2)
		static let secondaryCaption2 = ColoredLabel(titleColor: .Text.textSecondary, font: Font.caption2)
	}

	enum TextView {
		struct ColoredTextView: Applicable {
			let color: UIColor
			let font: UIFont

			func apply(_ object: UITextView) {
				object.textColor = color
				object.font = font
			}
		}

		static let primaryText = ColoredTextView(color: .Text.textPrimary, font: Font.text)
		static let primaryHeadline1 = ColoredTextView(color: .Text.textPrimary, font: Font.headline1)
		static let primaryHeadline3 = ColoredTextView(color: .Text.textPrimary, font: Font.headline3)
		static let secondaryText = ColoredTextView(color: .Text.textSecondary, font: Font.text)
	}

	enum TextField {
		struct ColoredTextField: Applicable {
			let color: UIColor
			let font: UIFont

			func apply(_ object: UITextField) {
				object.textColor = color
				object.font = font
			}
		}

		static let primaryText = ColoredTextField(color: .Text.textPrimary, font: Font.text)
		static let primaryHeadline3 = ColoredTextField(color: .Text.textPrimary, font: Font.headline3)
	}

	enum View {
		struct ShadowView: Applicable {
			func apply(_ object: UIView) {
				var shadowLayer: CAShapeLayer!
				shadowLayer = CAShapeLayer()
				shadowLayer.path = UIBezierPath(roundedRect: object.bounds, cornerRadius: object.layer.cornerRadius).cgPath
				shadowLayer.fillColor = UIColor.white.cgColor
				shadowLayer.shadowColor = Style.Color.Palette.lightGray.cgColor
				shadowLayer.shadowPath = shadowLayer.path
				shadowLayer.shadowOffset = CGSize(width: 0.0, height: 0.0)
				shadowLayer.shadowOpacity = 0.5
				shadowLayer.shadowRadius = 18
				object.layer.insertSublayer(shadowLayer, at: 0)
			}
		}
	}

	enum Button {
		struct ActionBlack: Applicable {
			let title: String

			func apply(_ object: UIButton) {
				object.titleLabel?.font = Font.text
				object.setTitleColor(.Text.textPrimary, for: .normal)
				object.setTitleColor(.Text.textSecondary, for: .highlighted)
				object.setTitleColor(.Text.textSecondary, for: .disabled)
				object.setTitle(title, for: .normal)
			}
		}

		struct CalendarDayButton: Applicable {
			let title: String

			func apply(_ object: UIButton) {
				object.titleLabel?.font = Font.headline1
				object.setTitleColor(.Text.textPrimary, for: .normal)
				object.setTitleColor(.Text.textContrast, for: .selected)
				object.setTitleColor(.Text.textSecondary, for: .disabled)
				object.setTitle(title, for: .normal)
			}
		}

		/// Соответствует RMRRedSubtitleButton
		/// Красная кнопка действия внизу экрана
		struct ActionRed: Applicable {
			let title: String

			func apply(_ object: UIButton) {
				object.setTitleColor(.Text.textContrast, for: .normal)
				object.setTitle(title, for: .normal)
				object.titleLabel?.font = Style.Font.headline1
				object.setBackgroundColor(.Background.backgroundAccent, forState: .normal)
				object.setBackgroundColor(.States.backgroundAccentPressed, forState: .highlighted)
				object.setBackgroundColor(.States.backgroundAccentDisabled, forState: .disabled)
				object.contentEdgeInsets = UIEdgeInsets(top: 16, left: 10, bottom: 16, right: 10)
			}
		}
		
		struct ActionRedRounded: Applicable {
			let title: String

			func apply(_ object: UIButton) {
				object.setTitleColor(.Text.textContrast, for: .normal)
				object.setTitleColor(.Text.textSecondary, for: .disabled)
				object.setTitle(title, for: .normal)
				object.titleLabel?.font = Style.Font.text
				object.setBackgroundColor(.Background.backgroundAccent, forState: .normal)
				object.setBackgroundColor(.States.backgroundAccentPressed, forState: .highlighted)
				object.setBackgroundColor(.States.backgroundAccentDisabled, forState: .disabled)
				object.contentEdgeInsets = UIEdgeInsets(top: 16, left: 10, bottom: 16, right: 10)
				object.layer.masksToBounds = true
				object.layer.cornerRadius = 25
			}
		}

		struct ActionWhite: Applicable {
			let title: String

			func apply(_ object: UIButton) {
				object.setTitleColor(Color.Palette.red, for: .normal)
				object.setTitle(title, for: .normal)
				object.titleLabel?.font = Font.headline1
				object.setBackgroundColor(Color.Palette.white, forState: .normal)
				object.setBackgroundColor(Color.Palette.lightGray, forState: .disabled)
				object.setBackgroundColor(.clear, forState: .highlighted)
				object.contentEdgeInsets = UIEdgeInsets(top: 16, left: 10, bottom: 16, right: 10)
			}
		}

		struct NavigationItemBlack: Applicable {
			let title: String

            func apply(_ object: UIBarButtonItem) {
                object.title = title
                object.setTitleTextAttributes(
                    [ .foregroundColor: UIColor.Icons.iconAccentThemed, .font: Font.text ],
                    for: .normal
                )
                object.setTitleTextAttributes(
                    [ .foregroundColor: UIColor.States.backgroundAccentPressed, .font: Font.text ],
                    for: .highlighted
                )
                object.setTitleTextAttributes(
                    [ .foregroundColor: UIColor.States.backgroundAccentDisabled, .font: Font.text ],
                    for: .disabled
                )
            }
        }
		
        struct NavigationItemUnderlineMain: Applicable {
            let title: String
			
			func apply(_ object: UIBarButtonItem) {
				object.title = title
				object.setTitleTextAttributes([ .foregroundColor: Color.Palette.black, .font: Font.text ], for: .normal)
				object.setTitleTextAttributes([ .foregroundColor: Color.Palette.darkGray, .font: Font.text ], for: .highlighted)
			}
		}
		
		struct NavigationItemDarkGray: Applicable {
			let title: String

			func apply(_ object: UIBarButtonItem) {
				object.title = title
				object.setTitleTextAttributes([ .foregroundColor: UIColor.Text.textSecondary, .font: Font.text ], for: .normal)
				object.setTitleTextAttributes([ .foregroundColor: UIColor.Text.textSecondary, .font: Font.text ], for: .highlighted)
			}
		}

		struct NavigationItemRed: Applicable {
			let title: String

			func apply(_ object: UIBarButtonItem) {
				object.title = title
				object.setTitleTextAttributes(
					[ .foregroundColor: UIColor.Icons.iconAccentThemed, .font: Font.text ],
					for: .normal
				)
				object.setTitleTextAttributes(
					[ .foregroundColor: UIColor.States.backgroundAccentPressed, .font: Font.text ],
					for: .highlighted
				)
				object.setTitleTextAttributes(
					[ .foregroundColor: UIColor.States.backgroundAccentDisabled, .font: Font.text ],
					for: .disabled
				)
			}
		}

		struct UnderlineMainButton: Applicable {
			let title: String

			func apply(_ object: UIButton) {
				let attributedTitle = title <~ TextAttributes.underlineText
				object.setAttributedTitle(attributedTitle, for: .normal)
				object.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
			}
		}

		struct RedLinkButton: Applicable {
			let title: String

			func apply(_ object: UIButton) {
				object.titleLabel?.font = Font.subhead
				object.setTitle(title, for: .normal)
				object.setTitleColor(Color.Palette.red, for: .normal)
				object.setTitleColor(Color.Palette.darkRed, for: .highlighted)
			}
		}

		struct ColoredButton: Applicable {
			var background: UIColor?
			var border: UIColor?
			var title: UIColor?
			var cornerRadius: CGFloat?
			let font: UIFont
			var contentEdgeInsets: UIEdgeInsets?
			let invertColors: Bool

			init(background: UIColor? = nil, border: UIColor? = nil, title: UIColor? = nil, font: UIFont, cornerRadius: CGFloat? = nil,
				 contentEdgeInsets: UIEdgeInsets? = nil, invertColors: Bool = true
			) {
				self.background = background
				self.border = border
				self.title = title
				self.cornerRadius = cornerRadius
				self.font = font
				self.contentEdgeInsets = contentEdgeInsets
				self.invertColors = invertColors
			}

			func apply(_ object: UIButton) {
				object.layer.masksToBounds = true

				object.backgroundColor = .clear

				if let background = background {
					object.setBackgroundImage(.from(color: background), for: .normal)
					object.setBackgroundImage(.from(color: background.withAlphaComponent(0.5)), for: .disabled)
					if let titleColor = title, invertColors {
						object.setBackgroundImage(.from(color: titleColor), for: .highlighted)
						object.setBackgroundImage(.from(color: titleColor), for: .selected)
					} else {
						object.setBackgroundImage(.from(color: background.withAlphaComponent(0.7)), for: .highlighted)
						object.setBackgroundImage(.from(color: background.withAlphaComponent(0.7)), for: .selected)
					}
				}

				if let border = border {
					object.layer.borderWidth = 1
					object.layer.borderColor = border.cgColor
				}

				if let title = title {
					object.setTitleColor(title, for: .normal)
					object.setTitleColor(title.withAlphaComponent(0.5), for: .disabled)
					if let backgroundColor = background, invertColors {
						object.setTitleColor(backgroundColor, for: .highlighted)
						object.setTitleColor(backgroundColor, for: .selected)
					} else {
						object.setTitleColor(title.withAlphaComponent(0.7), for: .highlighted)
						object.setTitleColor(title.withAlphaComponent(0.7), for: .selected)
					}
				}

				if let cornerRadius = cornerRadius {
					object.layer.cornerRadius = cornerRadius
				}

				if let contentEdgeInsets = contentEdgeInsets {
					object.contentEdgeInsets = contentEdgeInsets
				}

				object.titleLabel?.font = font
			}
		}
		
		static let accentLabelButtonSmall = ColoredButton(title: .Text.textAccent, font: Font.buttonSmall)
		static let backgroundButton = ColoredButton(background: Color.Palette.whiteGray, font: Font.buttonLarge)
		static let whiteGrayButton = ColoredButton(background: .Background.backgroundTertiary, font: Font.text)
		static let lightBackgroundButton = ColoredButton(background: Color.Palette.whiteGray, title: Color.Palette.black, font: Font.text)
		static let darkGrayButton = ColoredButton(background: Color.Palette.darkGray, font: Font.text)
		static let redInvertRoundButton = ColoredButton(background: .Background.backgroundAccent, title: .Text.textContrast, font: Font.text)
		static let labelButton = ColoredButton(title: .Text.textSecondary, font: Font.text)
		static let redLabelButton = ColoredButton(title: Color.Palette.red, font: Font.text, invertColors: false)
		static let redLabelSmallTextButton = ColoredButton(title: .Text.textAccent, font: Font.text)
		static let pinPadButton = ColoredButton(title: Color.text, font: Font.buttonKeyboard)
		static let alertActionButton = ColoredButton(title: Color.main, font: Font.headline2)
		static let alertDefaultButton = ColoredButton(title: Color.text, font: Font.headline2)
	}

	enum RoundedButton {
		struct ButtonConfiguration {
			struct ButtonColors {
				let title: UIColor
				let background: UIColor
				var border: UIColor?
			}
			
			let normal: ButtonColors
			let highlighted: ButtonColors
			let disabled: ButtonColors

			var hasBorder: Bool {
				normal.border != nil || highlighted.border != nil || disabled.border != nil
			}
			
			let shadow: ShadowAppearance?
			
			let canSelect: Bool
		}
		
		struct ColoredButton: Applicable {
			let configuration: ButtonConfiguration
			let font: UIFont
			var contentEdgeInsets: UIEdgeInsets

			init(
				configuration: ButtonConfiguration,
				font: UIFont,
				customContentEdgeInsets: UIEdgeInsets = Margins.defaultButtonContentInset
			) {
				self.configuration = configuration
				self.font = font
				self.contentEdgeInsets = customContentEdgeInsets
			}

			func apply(_ object: RoundEdgeButton) {
				object.layer.masksToBounds = false
				object.backgroundColor = .clear
				object.contentEdgeInsets = contentEdgeInsets
				object.titleLabel?.font = font
							 
				object.buttonConfiguration = configuration
				
				if configuration.canSelect {
					object.setTitleColor(configuration.highlighted.title, for: .selected)
				}

				object.setTitleColor(configuration.normal.title, for: .normal)
				object.setTitleColor(configuration.disabled.title, for: .disabled)
				object.setTitleColor(configuration.highlighted.title, for: .highlighted)

				object.layer.borderWidth = configuration.hasBorder ? 1 : 0
				object.setBorderColor(
					normal: configuration.normal.border,
					highlighted: configuration.highlighted.border,
					disabled: configuration.disabled.border
				)
			}
		}
		
		struct RoundedParameterizedButton: Applicable  {
			let textColor: UIColor?
			let backgroundColor: UIColor?
			let borderColor: UIColor?

			init(
				textColor: UIColor?,
				backgroundColor: UIColor?,
				borderColor: UIColor? = nil
			) {
				self.textColor = textColor
				self.backgroundColor = backgroundColor
				self.borderColor = borderColor
			}
			
			func apply(_ object: RoundEdgeButton) {
				object.titleLabel?.font = Style.Font.headline2
				
				object.backgroundColor = backgroundColor
				
				if let borderColor {
					object.layer.borderWidth = 1
					object.layer.borderColor = borderColor.cgColor
				}
				
				object.setTitleColor(
					textColor,
					for: .normal
				)
				
				if let borderColor = borderColor {
					object.layer.borderWidth = 1
					object.layer.borderColor = borderColor.cgColor
				}
			}
		}
		
		static let redParameterizedButton = RoundedParameterizedButton(
			textColor: .Text.textContrast,
			backgroundColor: .Background.backgroundAccent
		)
        
        static let redBorderedAndBackgroundClear = ColoredButton(
            configuration: .init(
                normal: .init(title: Color.Palette.red, background: .clear, border: Color.Palette.red),
                highlighted: .init(title: Color.Palette.darkRed, background: .clear, border: Color.Palette.darkRed),
                disabled: .init(title: Color.Palette.darkGray, background: .clear, border: Color.Palette.lightGray),
                shadow: nil,
                canSelect: false
            ),
            font: Font.text
        )

		static let accentButtonSmall = ColoredButton(
			configuration: .init(
				normal: .init(title: .Text.textContrast, background: .Background.backgroundAccent),
				highlighted: .init(title: .Text.textContrast, background: .States.backgroundAccentPressed),
				disabled: .init(title: .Text.textSecondary, background: .States.backgroundAccentDisabled),
				shadow: nil,
				canSelect: false
			),
			font: Font.buttonSmall
		)
		
		static let outlinedButtonSmall = ColoredButton(
			configuration: .init(
				normal: .init(title: .Text.textAccent, background: .clear, border: .Stroke.strokeAccent),
				highlighted: .init(title: .Text.textAccent, background: .States.transparentThemedPressed, border: .Stroke.strokeAccent),
				disabled: .init(title: Color.Palette.darkGray, background: .clear, border: .States.strokeAccentDisabled),
				shadow: nil,
				canSelect: false
			),
			font: Font.buttonSmall
		)
		
		static let outlinedButtonLarge = ColoredButton(
			configuration: .init(
				normal: .init(title: .Text.textAccent, background: .clear, border: .Stroke.strokeAccent),
				highlighted: .init(title: .Text.textAccent, background: .States.transparentThemedPressed, border: .Stroke.strokeAccent),
				disabled: .init(title: Color.Palette.darkGray, background: .clear, border: .States.strokeAccentDisabled),
				shadow: nil,
				canSelect: false
			),
			font: Font.buttonLarge
		)
		
		static let primaryButtonLarge = ColoredButton(
			configuration: .init(
				normal: .init(title: .Text.textContrast, background: .Background.backgroundAccent),
				highlighted: .init(title: .Text.textContrast, background: .States.backgroundAccentPressed),
				disabled: .init(title: .Text.textSecondary, background: .States.backgroundAccentDisabled),
				shadow: nil,
				canSelect: false
			),
			font: Font.buttonLarge
		)
		
		static let primaryWhiteButtonLarge = ColoredButton(
			configuration: .init(
				normal: .init(title: .Text.reverseTextPrimary, background: .Background.reverseBackgroundContent),
				highlighted: .init(title: .Text.reverseTextPrimary, background: .Background.reverseBackgroundContent),
				disabled: .init(title: .Text.reverseTextPrimary, background: .clear),
				shadow: nil,
				canSelect: false
			),
			font: Font.headline3
		)
      
		static let primaryButtonLargeWithoutBorder = ColoredButton(
			configuration: .init(
				normal: .init(title: .Text.textAccent, background: .clear, border: .clear),
				highlighted: .init(title: .States.textAccentPressed, background: .clear, border: .clear),
				disabled: .init(title: .Text.textSecondary, background: .clear, border: .clear),
				shadow: nil,
				canSelect: true
			),
			font: Font.buttonLarge
		)
		
		static let primaryButtonSmallWithoutBorder = ColoredButton(
			configuration: .init(
				normal: .init(title: .Text.textAccent, background: .clear, border: .clear),
				highlighted: .init(title: .States.textAccentPressed, background: .clear, border: .clear),
				disabled: .init(title: .Text.textSecondary, background: .clear, border: .clear),
				shadow: nil,
				canSelect: true
			),
			font: Font.buttonSmall
		)
		
		// MARK: - Deprecated rounded button styles (DO NOT MAKE ANY CHANGES AND DO NOT USE)
		static let redBordered = ColoredButton(
			configuration: .init(
				normal: .init(title: .Text.textAccent, background: .clear, border: .Stroke.strokeAccent),
				highlighted: .init(
					title: .States.textAccentPressed,
					background: .States.transparentThemedPressed,
					border: .Stroke.strokeAccent
				),
				disabled: .init(
					title: .States.strokeDisabled,
					background: .clear,
					border: .Text.textSecondary
				),
				shadow: nil,
				canSelect: false
			),
			font: Font.text
		)
		
        static let oldOutlinedButtonSmall = ColoredButton(
            configuration: .init(
                normal: .init(title: .Text.textAccent, background: .clear, border: .Stroke.strokeAccent),
                highlighted: .init(title: .Text.textAccent, background: .States.transparentThemedPressed, border: .Stroke.strokeAccent),
                disabled: .init(title: Color.Palette.darkGray, background: .clear, border: .States.strokeAccentDisabled),
                shadow: nil,
                canSelect: false
            ),
            font: Font.headline2
        )
		
		static let redTitleMediumWithoutBorder = ColoredButton(
			configuration: .init(
				normal: .init(title: .Text.textAccent, background: .clear, border: .clear),
				highlighted: .init(title: .States.textAccentPressed, background: .clear, border: .clear),
				disabled: .init(title: .Text.textSecondary, background: .clear, border: .clear),
				shadow: nil,
				canSelect: true
			),
			font: Font.headline2
		)
		static let timeRedBordered = ColoredButton(
			configuration: .init(
				normal: .init(title: .Text.textAccent, background: .clear, border: .Stroke.strokeAccent),
				highlighted: .init(title: .Text.textContrast, background: .Background.backgroundAccent, border: .clear),
				disabled: .init(title: .Text.textSecondary, background: .clear, border: .States.strokeAccentDisabled),
				shadow: nil,
				canSelect: true
			),
			font: Font.text,
			customContentEdgeInsets: UIEdgeInsets(top: 6, left: 15, bottom: 6, right: 15)
		)
		
		static let timeDisabledBordered = ColoredButton(
			configuration: .init(
				normal: .init(title: .Text.textSecondary, background: .clear, border: .Stroke.strokeBorder),
				highlighted: .init(title: .Text.textSecondary, background: .clear, border: .Stroke.strokeBorder),
				disabled: .init(title: .Text.textSecondary, background: .clear, border: .Stroke.strokeBorder),
				shadow: nil,
				canSelect: false
			),
			font: Font.text,
			customContentEdgeInsets: UIEdgeInsets(top: 6, left: 15, bottom: 6, right: 15)
		)
		
		static let redBackground = ColoredButton(
			configuration: .init(
				normal: .init(title: .Text.textContrast, background: .Background.backgroundAccent),
				highlighted: .init(title: .Text.textContrast, background: .States.backgroundAccentPressed),
				disabled: .init(title: .Text.textSecondary, background: .States.backgroundAccentDisabled),
				shadow: nil,
				canSelect: false
			),
			font: Font.text
		)
		
		static let oldPrimaryButtonSmall = ColoredButton(
			configuration: .init(
				normal: .init(title: .Text.textContrast, background: .Background.backgroundAccent),
				highlighted: .init(title: .Text.textContrast, background: .States.backgroundAccentPressed),
				disabled: .init(title: .Text.textSecondary, background: .States.backgroundAccentDisabled),
				shadow: nil,
				canSelect: false
			),
			font: Font.headline2
		)
		
		static let primaryButtonSmall = ColoredButton(
			configuration: .init(
				normal: .init(title: .Text.textContrast, background: .Background.backgroundAccent),
				highlighted: .init(title: .Text.textContrast, background: .States.backgroundAccentPressed),
				disabled: .init(title: .Text.textSecondary, background: .States.backgroundAccentDisabled),
				shadow: nil,
				canSelect: false
			),
			font: Font.headline2
		)
		
		static let redTitle = ColoredButton(
			configuration: .init(
				normal: .init(title: .Text.textAccent, background: .clear),
				highlighted: .init(title: .States.textAccentPressed, background: .clear),
				disabled: .init(title: .clear, background: .clear),
				shadow: nil,
				canSelect: false
			),
			font: Font.text
		)
		static let grayBorderGrayTitle = ColoredButton(
			configuration: .init(
				normal: .init(title: .Text.textPrimary, background: .Background.backgroundTertiary, border: .Background.backgroundAdditional),
				highlighted: .init(title: .Text.textPrimary, background: .Background.backgroundTertiary, border: .Background.backgroundAdditional),
				disabled: .init(title: .Text.textSecondary, background: .States.backgroundSecondaryDisabled, border: .Background.backgroundAdditional),
				shadow: nil,
				canSelect: false
			),
			font: Font.text
		)
		
		static let grayBorderBlackTitle = ColoredButton(
			configuration: .init(
				normal: .init(title: Color.Palette.black, background: Color.Palette.white, border: Color.Palette.lightGray),
				highlighted: .init(title: Color.Palette.white, background: Color.Palette.red, border: Color.Palette.lightGray),
				disabled: .init(title: Color.Palette.black, background: Color.Palette.white, border: Color.Palette.lightGray),
				shadow: nil,
				canSelect: true
			),
			font: Font.text
		)
		
		static let grayBackground = ColoredButton(
			configuration: .init(
				normal: .init(title: Color.Palette.black, background: Color.Palette.whiteGray),
				highlighted: .init(title: Color.Palette.black, background: Color.Palette.gray),
				disabled: .init(title: Color.Palette.darkGray, background: Color.Palette.lightGray),
				shadow: nil,
				canSelect: false
			),
			font: Font.text,
			customContentEdgeInsets: UIEdgeInsets(top: 9, left: 15, bottom: 9, right: 15)
		)
		
		static let whiteGrayBackground = ColoredButton(
			configuration: .init(
				normal: .init(title: .Text.textPrimary, background: .Background.backgroundTertiary),
				highlighted: .init(title: .Text.textPrimary, background: .Background.backgroundTertiary),
				disabled: .init(title: .Text.textSecondary, background: .States.backgroundSecondaryDisabled),
				shadow: nil,
				canSelect: false
			),
			font: Font.text,
			customContentEdgeInsets: UIEdgeInsets(top: 9, left: 15, bottom: 9, right: 15)
		)

		static let grayBackgroundMedium = ColoredButton(
			configuration: .init(
				normal: .init(title: .Text.textPrimary, background: .Background.backgroundTertiary),
				highlighted: .init(title: .Text.textPrimary, background: .Background.backgroundTertiary),
				disabled: .init(title: .Text.textSecondary, background: .States.backgroundSecondaryDisabled),
				shadow: nil,
				canSelect: false
			),
			font: Font.headline2
		)
		
		static let redBackgroundActionAlignedRight = ColoredButton(
			configuration: .init(
				normal: .init(title: .Text.textContrast, background: .Background.backgroundAccent),
				highlighted: .init(title: .Text.textContrast, background: .States.backgroundAccentPressed),
				disabled: .init(title: .Text.textSecondary, background: .States.backgroundAccentDisabled),
				shadow: .shadow70pct,
				canSelect: false
			),
			font: Font.headline2
		)
		
		static let mainFilterButton = ColoredButton(
			configuration: .init(
				normal: .init(title: .Text.textPrimary, background: .Background.backgroundSecondary),
				highlighted: .init(title: .Text.textPrimary, background: .States.backgroundSecondaryPressed),
				disabled: .init(title: .Text.textSecondary, background: .States.backgroundSecondaryDisabled),
				shadow: .cardShadow,
				canSelect: false
			),
			font: Font.headline2
		)
}

	enum Paragraph {
		static var centered: NSParagraphStyle {
			let result = NSMutableParagraphStyle()
			result.alignment = .center
			return result
		}
		static func withLineHeight(_ lineHeight: CGFloat) -> NSParagraphStyle {
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.maximumLineHeight = lineHeight
			paragraphStyle.minimumLineHeight = lineHeight
			return paragraphStyle
		}
	}

	enum TextAttributes {
		static let taskAlertTitle: [NSAttributedString.Key: Any] = [
			.font: Font.headline3,
			.paragraphStyle: Paragraph.centered,
		]

		static let taskAlertText: [NSAttributedString.Key: Any] = [
			.font: Font.subhead,
			.paragraphStyle: Paragraph.centered,
		]

		static let underlineText: [NSAttributedString.Key: Any] = [
			.font: Font.text,
			.paragraphStyle: Paragraph.centered,
			.foregroundColor: Color.main,
			.underlineStyle: 1
		]
		
        static let placeholder: [NSAttributedString.Key: Any] = [
            .font: Font.headline1,
            .foregroundColor: Color.grayedText,
        ]
        static let grayInfoText: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.Text.textSecondary,
            .font: Font.text
        ]
		
		static let secondaryText: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.Text.textSecondary,
			.font: Font.text
		]
		
        static let stepTitleText: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.Text.textPrimary,
            .font: Font.headline1
        ]
        static let normalText: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.Text.textPrimary,
            .font: Font.text
        ]
        static let chatTextVisitorColor: UIColor = .Text.textContrast
        static let chatTextVisitor: [NSAttributedString.Key: Any] = [
            .foregroundColor: chatTextVisitorColor,
            .font: Font.text
        ]
        static let chatTextOperatorColor: UIColor = .Text.textPrimary
        static let chatTextOperator: [NSAttributedString.Key: Any] = [
            .foregroundColor: chatTextOperatorColor,
            .font: Font.text
        ]
        static let link: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.Text.textLink,
            .underlineStyle: 1
        ]
        static let chatLinkSelected: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.States.textLinkVisited,
            .underlineStyle: 1
        ]
        static let startButtonTitle: [NSAttributedString.Key: Any] = [
            .foregroundColor: Color.whiteText,
            .font: Font.headline3,
            .paragraphStyle: Paragraph.centered
        ]
        static let datesLabelText: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.Text.textPrimary,
            .font: Font.headline1
        ]
        static let daysBalanceText: [NSAttributedString.Key: Any] = [
            .foregroundColor: Color.Palette.darkGray,
            .font: Font.text
        ]
        static let daysBalanceBoldText: [NSAttributedString.Key: Any] = [
            .foregroundColor: Color.text,
            .font: Font.headline3
        ]
        static let daysBalanceSmallText: [NSAttributedString.Key: Any] = [
            .foregroundColor: Color.Palette.darkGray,
            .font: Font.caption1
        ]
        static let daysBalanceSmallBoldText: [NSAttributedString.Key: Any] = [
            .foregroundColor: Color.text,
            .font: Font.headline3
        ]
		static let subtitleMediumText: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.Text.textPrimary,
			.font: Font.headline2
		]
		static let blackInfoSmallText: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.Text.textPrimary,
			.font: Font.caption1
		]
		static let oldPrimaryText: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.Text.textPrimary,
			.font: Font.text
		]
		static let accentThemedText: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.Text.textAccentThemed,
			.font: Font.text
		]
		static let primaryText: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.Text.textPrimary,
			.font: Font.text
		]
		static let primaryHeadline2: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.Text.textPrimary,
			.font: Font.headline2
		]
		static let primarySubhead: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.Text.textPrimary,
			.font: Font.subhead
		]
	}

	enum Margins {
		static let `default`: CGFloat = 18
		static let defaultInsets: UIEdgeInsets = UIEdgeInsets(top: 12, left: 18, bottom: 12, right: 18)
		static let inputInsets: UIEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
		static let defaultButtonContentInset: UIEdgeInsets = UIEdgeInsets(top: 8, left: 18, bottom: 8, right: 18)
	}
}

protocol Applicable {
	associatedtype Applicant

	func apply(_ object: Applicant)
}

precedencegroup StylePrecedence {
	associativity: left
	higherThan: AdditionPrecedence
}

infix operator <~: StylePrecedence

@discardableResult
func <~<T: Applicable>(object: T.Applicant, applicable: T) -> T.Applicant {
	applicable.apply(object)
	return object
}

func <~ (string: String, attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
	NSAttributedString(string: string, attributes: attributes)
}

@discardableResult
func <~ (string: NSMutableAttributedString, attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString {
	string.addAttributes(attributes, range: NSRange(location: 0, length: string.length))
	return string
}

func <~ (attributesTo: [NSAttributedString.Key: Any], attributesFrom: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any] {
	var resultAttributes = attributesTo
	attributesFrom.forEach { item in
		resultAttributes[item.key] = item.value
	}
	return resultAttributes
}

extension UIColor {
	enum Background {
		static let backgroundAdditional = color("Background Additional")
		static let background = color("Background")
		static let backgroundAccent = color("Background Accent")
		static let backgroundContent = color("Background Content")
		static let reverseBackgroundContent = color("Reverse Background Content")
		static let backgroundModal = color("Background Modal")
		static let backgroundNegativeTint = color("Background Negative Tint")
		static let backgroundSecondary = color("Background Secondary")
		static let backgroundTertiary = color("Background Tertiary")
		static let fieldBackground = color("Field Background")
		static let segmentedControlAccent = color("Segmented Control Accent")
		static let segmentedControl = color("Segmented Control")
		static let blackOverlay = color("Black Overlay")
	}
	
	enum Icons {
		static let iconPrimary = color("Icon Primary")
		static let iconMedium = color("Icon Medium")
		static let iconSecondary = color("Icon Secondary")
		static let iconTertiary = color("Icon Tertiary")
		static let iconContrast = color("Icon Contrast")
		static let iconAccent = color("Icon Accent")
		static let iconAccentThemed = color("Icon Accent Themed")
		static let iconNegative = color("Icon Negative")
		static let iconBlack = color("Icon Black")
	}
	
	enum Other {
		static let imageGradient = color("Image gradient")
		static let imageOverlayStart = color("Image overlay - Start")
		static let imageOverlayStop = color("Image overlay - Stop")
		static let imageOverlayThemedStart = color("Image overlay themed - Start")
		static let imageOverlayThemedStop = color("Image overlay themed - Stop")
		static let overlayPrimary = color("Overlay Primary")
		static let systemUI = color("System UI")
	}
	
	enum Pallete {
		static let accentGreen = color("Accent Green")
		static let accentRed = color("Accent Red")
	}
	
	enum States {
		static let backgroundAccentDisabled = color("Background Accent – Disabled")
		static let backgroundAccentPressed = color("Background Accent – Pressed")
		static let strokeDisabled = color("Stroke – Disabled")
		static let strokeAccentDisabled = color("Stroke Accent – Disabled")
		static let transparentThemedPressed = color("Transperent Themed – Pressed")
		static let backgroundSecondaryDisabled = color("Background Secondary – Disabled")
		static let backgroundSecondaryPressed = color("Background Secondary – Pressed")
		static let textAccentPressed = color("Text Accent – Pressed")
		static let textLinkVisited = color("Text Link - Visited")
	}
	
	enum Stroke {
		static let divider = color("Divider")
		static let strokeAccent = color("Stroke Accent")
		static let strokeBorder = color("Stroke Border")
		static let strokeInput = color("Stroke Input")
		static let strokeNegative = color("Stroke Negative")
		static let strokePrimary = color("Stroke Primary")
	}
	
	enum Text {
		static let textPrimary = color("Text Primary")
		static let reverseTextPrimary = color("Reverse Text Primary")
		static let textSecondary = color("Text Secondary")
		static let textTertiary = color("Text Tertiary")
		static let textContrast = color("Text Contrast")
		static let textAccent = color("Text Accent")
		static let textAccentThemed = color("Text Accent Themed")
		static let textLink = color("Text Link")
		static let textNegative = color("Text Negative")
	}
	
	enum Shadow {
		static let elevation1 = color("Elevation 1")
		static let elevation2Primary = color("Elevation 2 - Primary")
		static let elevation2Secondary = color("Elevation 2 - Secondary")
		static let tabbarShadow = color("Tabbar Shadow")
		static let shadow70pct = color("Shadow 70%")
		static let shadow100pct = color("Shadow 100%")
		static let cardShadow = color("Сard Shadow")
		static let iconShadow = color("Icon Shadow")
		static let buttonShadow = color("Button Shadow")
		static let shadow = color("Shadow")
	}
	
	private static func color(_ colorAssetName: String) -> UIColor {
		return UIColor(named: colorAssetName) ?? .clear
	}
}

struct ShadowAppearance: Applicable {
	let color: UIColor
	let offset: CGSize
	let opacity: Float
	let radius: CGFloat
	
	func apply(_ object: CALayer) {
		object.shadowColor = color.cgColor
		object.shadowOffset = offset
		object.shadowOpacity = opacity
		object.shadowRadius = radius
	}
	
	static let zero = ShadowAppearance(color: .clear, offset: .zero, opacity: 0.0, radius: 0.0)
	static let shadow100pct = ShadowAppearance(color: .Shadow.shadow100pct, offset: CGSize(width: 0, height: 3), opacity: 1, radius: 25)
	static let shadow70pct = ShadowAppearance(color: .Shadow.shadow70pct, offset: CGSize(width: 0, height: 2), opacity: 1, radius: 16)
	static let primaryElevation1 = ShadowAppearance(color: .Shadow.elevation1, offset: CGSize(width: 0, height: 4), opacity: 1, radius: 16)
	static let secondaryElevation1 = ShadowAppearance(color: .Shadow.elevation1, offset: .zero, opacity: 1, radius: 2)
	static let primaryElevation2 = ShadowAppearance(color: .Shadow.elevation2Primary, offset: .zero, opacity: 1, radius: 8)
	static let secondaryElevation2 = ShadowAppearance(color: .Shadow.elevation2Secondary, offset: CGSize(width: 0, height: 16), opacity: 1, radius: 16)
	static let cardShadow = ShadowAppearance(color: .Shadow.cardShadow, offset: CGSize(width: 0, height: 3), opacity: 1, radius: 18)
	static let buttonShadow = ShadowAppearance(color: .Shadow.buttonShadow, offset: CGSize(width: 0, height: 4), opacity: 1, radius: 20)
}
// swiftlint:enable file_length
