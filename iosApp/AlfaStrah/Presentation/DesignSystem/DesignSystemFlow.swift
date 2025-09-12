//
//  DesignSystemFlow
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16.04.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

protocol DesignSystemComponent {
    var title: String { get }
}

class DesignSystemFlow: BaseFlow {
    private enum Constants {
        static let designSystemVersion: String = "1.0"
    }

    enum DesignSystemComponents: String, CaseIterable, DesignSystemComponent {
        case cards = "Cards"
        case buttons = "Buttons"
        case colorPalette = "ColorPalette"
        case photoCard = "PhotoCard"
        case fonts = "Fonts"
        case inputs = "Inputs"
        case chipView = "ChipView"

        var title: String {
            rawValue
        }
    }

    enum Cards: String, CaseIterable, DesignSystemComponent {
        case valueCard = "ValueCard"
        case smallValueCard = "SmallValueCard"
        case navigationCard = "NavigationCard"
        case readonlyValueCard = "ReadonlyValueCard"

        var title: String {
            rawValue
        }
    }

    enum Buttons: String, CaseIterable, DesignSystemComponent {
        case cardButton = "CardButton"

        var title: String {
            rawValue
        }
    }

    struct ComponentsSection {
        let title: String
        let components: [DesignSystemComponent]
    }

    private let componentsList: [ComponentsSection] = [
        ComponentsSection(title: "Components", components: DesignSystemComponents.allCases),
    ]

    private let cardsList: [ComponentsSection] = [
        ComponentsSection(title: "Cards", components: Cards.allCases),
    ]

    private let buttonsList: [ComponentsSection] = [
        ComponentsSection(title: "Buttons", components: Buttons.allCases),
    ]

    func start() {
        showComponentsListScreen()
    }

    private func showComponentsListScreen() {
        let controller: DesignSystemComponentsList = .init()
        container?.resolve(controller)

        controller.input = .init(
            componentsSections: componentsList,
            version: Constants.designSystemVersion
        )
        controller.output = .init(
            componentTap: { component in
                switch component {
                    case DesignSystemComponents.cards:
                        self.showCardsListScreen()
                    case DesignSystemComponents.colorPalette:
                        self.showColorPaletteScreen(title: component.title)
                    case DesignSystemComponents.photoCard:
                        self.showPhotoPickerScreen(title: component.title)
                    case DesignSystemComponents.fonts:
                        self.showFontsScreen(title: component.title)
                    case DesignSystemComponents.buttons:
                        self.showButtonsListScreen()
                    case DesignSystemComponents.inputs:
                        self.showInputsListScreen(title: component.title)
                    case DesignSystemComponents.chipView:
                        self.showChipViewScreen(title: component.title)
                    default:
                        break
                }
            }
        )
        controller.addCloseButton { [weak controller] in
            controller?.dismiss(animated: true, completion: nil)
        }

        createAndShowNavigationController(viewController: controller, mode: .modal)
    }

    private func showValueCardScreen(title: String) {
        let controller: ValueCardViewController = .init()
        container?.resolve(controller)
        controller.input = .init(title: title)
        createAndShowNavigationController(viewController: controller, mode: .push)
    }

    private func showSmallValueCardScreen(title: String) {
        let controller: SmallValueCardViewController = .init()
        container?.resolve(controller)
        controller.input = .init(title: title)
        createAndShowNavigationController(viewController: controller, mode: .push)
    }

    private func showNavigationCardScreen(title: String) {
        let controller: NavigationCardViewController = .init()
        container?.resolve(controller)
        controller.input = .init(title: title)
        createAndShowNavigationController(viewController: controller, mode: .push)
    }

    private func showFontsScreen(title: String) {
        let controller: FontsViewController = .init()
        container?.resolve(controller)
        controller.input = .init(title: title)
        createAndShowNavigationController(viewController: controller, mode: .push)
    }

    private func showColorPaletteScreen(title: String) {
        let controller: ColorPaletteViewController = .init()
        container?.resolve(controller)
        controller.input = .init(title: title)
        createAndShowNavigationController(viewController: controller, mode: .push)
    }

    private func showReadonlyValueCardScreen(title: String) {
        let controller: ReadonlyCardViewController = .init()
        container?.resolve(controller)
        controller.input = .init(title: title)
        createAndShowNavigationController(viewController: controller, mode: .push)
    }

    private func showCardButtonScreen(title: String) {
        let controller: CardButtonViewController = .init()
        container?.resolve(controller)
        controller.input = .init(title: title)
        createAndShowNavigationController(viewController: controller, mode: .push)
    }

    private func showChipViewScreen(title: String) {
        let controller: ChipViewController = .init()
        container?.resolve(controller)
        controller.input = .init(title: title)
        createAndShowNavigationController(viewController: controller, mode: .push)
    }

    private func showCardsListScreen() {
        let controller: DesignSystemComponentsList = .init()
        container?.resolve(controller)

        controller.input = .init(
            componentsSections: cardsList,
            version: Constants.designSystemVersion
        )
        controller.output = .init(
            componentTap: { component in
                switch component {
                    case Cards.valueCard:
                        self.showValueCardScreen(title: component.title)
                    case Cards.smallValueCard:
                        self.showSmallValueCardScreen(title: component.title)
                    case Cards.navigationCard:
                        self.showNavigationCardScreen(title: component.title)
                    case Cards.readonlyValueCard:
                        self.showReadonlyValueCardScreen(title: component.title)
                    default:
                        break
                }
            }
        )
        createAndShowNavigationController(viewController: controller, mode: .push)
    }

    private func showButtonsListScreen() {
        let controller: DesignSystemComponentsList = .init()
        container?.resolve(controller)

        controller.input = .init(
            componentsSections: buttonsList,
            version: Constants.designSystemVersion
        )
        controller.output = .init(
            componentTap: { component in
                switch component {
                    case Buttons.cardButton:
                        self.showCardButtonScreen(title: component.title)
                    default:
                        break
                }
            }
        )
        createAndShowNavigationController(viewController: controller, mode: .push)
    }

    private func showPhotoPickerScreen(title: String) {
        let controller: PhotoPickerViewController = .init()
        container?.resolve(controller)
        controller.input = .init(title: title)
        createAndShowNavigationController(viewController: controller, mode: .push)
    }

    private func showInputsListScreen(title: String) {
        let controller: DesignSystemInputsViewController = .init()
        container?.resolve(controller)
        controller.input = .init(title: title)
        createAndShowNavigationController(viewController: controller, mode: .push)
    }
}
