//
//  FirstDamagePlaceBasePickerView.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 05.07.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

protocol FirstDamagePlacePicker: UIView {
    var state: FirstDamagePlacePickerState { get set }
    var selectionHandler: ((_ position: EuroProtocolFirstBumpScheme?) -> Void)? { get set }
    func updateSelection(with: EuroProtocolFirstBumpScheme)
}

enum FirstDamagePlacePickerState {
    case bumpSelectable
    case bumpPreview
}

class FirstDamagePlaceBasePickerView<T: EuroProtocolFirstBumpScheme>: UIView, FirstDamagePlacePicker {
    // swiftlint:disable:next private_outlet
    @IBOutlet var directionControls: [DamageDirectionControl]!

    var state: FirstDamagePlacePickerState = .bumpSelectable {
        didSet {
            updateControlsVisibility()
        }
    }

    var numberOfDirectionControls: Int {
        fatalError("\(#function) must be implemented in subclasses")
    }

    var maxSimultaneouslySelectedDirections: Int {
        fatalError("\(#function) must be implemented in subclasses")
    }

    var selectionHandler: ((_ position: EuroProtocolFirstBumpScheme?) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        assignDirectionsToControls()
        addTargetsToControls()
    }

    func assignDirectionsToControls() {
        fatalError("\(#function) must be implemented in subclasses")
    }

    private func addTargetsToControls() {
        directionControls.forEach {
            $0.addTarget(self, action: #selector(controlSelected(_:)), for: .touchUpInside)
        }
    }

    @objc private func controlSelected(_ control: UIControl) {
        guard state == .bumpSelectable else { return }

        control.isSelected = !control.isSelected
        updateEnabledControls()
        let selectedControlTags = directionControls
            .filter { $0.isSelected }
            .map { $0.tag }
        let position = T(viewTags: selectedControlTags)
        selectionHandler?(position)
    }

    private func updateEnabledControls() {
        let selectedControls = directionControls
            .filter { $0.isSelected }
        let deselectedControls = directionControls
            .filter { !$0.isSelected }

        guard selectedControls.count < maxSimultaneouslySelectedDirections else {
            deselectedControls.forEach { $0.isEnabled = false }
            return
        }

        guard let selectedControl = selectedControls.first else {
            directionControls.forEach {
                $0.isEnabled = true
            }
            return
        }

        // find neighbour controls
        let tag = selectedControl.tag
        let tagOffset = tag - 1
        let prevTagOffset = (tagOffset - 1 + numberOfDirectionControls) % numberOfDirectionControls
        let nextTagOffset = (tagOffset + 1) % numberOfDirectionControls
        let prevTag = prevTagOffset + 1
        let nextTag = nextTagOffset + 1

        directionControls.forEach {
            $0.isEnabled = [ tag, prevTag, nextTag ].contains($0.tag)
        }
    }

    func updateSelection(with bumpScheme: EuroProtocolFirstBumpScheme) {
        let tags = bumpScheme.viewTags
        directionControls.forEach {
            $0.isSelected = tags.contains($0.tag)
        }
        updateEnabledControls()
        updateControlsVisibility()
    }

    private func updateControlsVisibility() {
        directionControls.forEach {
            switch state {
                case .bumpSelectable:
                    $0.isCircleVisible = true
                case .bumpPreview:
                    $0.isCircleVisible = $0.isSelected
            }
        }
    }
}
