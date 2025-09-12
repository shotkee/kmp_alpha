//
//  MessageCell
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 17.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

/// Base message cell.
class MessageCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
        layout()
        staticStylize()
        dynamicStylize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        fatalError("Xibs and storyboards are not supported")
    }

    /// Sets up the cell.
    func setup() {
        selectionStyle = .none
    }

    /// Stylizes the cell when initializing.
    func staticStylize() {
        clipsToBounds = false
        contentView.clipsToBounds = false
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    /// Stylizes the cell when updating content.
    func dynamicStylize() {
    }

    // MARK: - Layout

    /// Exact height of the cell.
    class var height: CGFloat { UITableView.automaticDimension }

    /// Estimated height of the cell.
    class var estimatedHeight: CGFloat { 44 }

    /// Cell's constraints.
    private(set) var layoutConstraints: [NSLayoutConstraint] = []

    /// Lays out the cell.
    func layout() {
        NSLayoutConstraint.deactivate(layoutConstraints)

        layoutConstraints = []
    }

    /// Adds constraints to the cell.
    func add(constraints: [NSLayoutConstraint]) {
        NSLayoutConstraint.activate(constraints)

        layoutConstraints += constraints
    }
}
