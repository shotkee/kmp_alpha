//
// LayoutHelper
// AlfaStrah
//
// Created by Eugene Egorov on 02 August 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    public func with(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }

    @objc static func fill(view: UIView, in superview: UIView, margins: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        view.translatesAutoresizingMaskIntoConstraints = false
        return [
            view.topAnchor.constraint(equalTo: superview.topAnchor, constant: margins.top),
            view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: margins.left),
            superview.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: margins.bottom),
            superview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: margins.right),
        ]
    }

    static func fixWidth(view: UIView, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let identifier = "FixWidthConstraint"
        view.removeConstraints(view.constraints.filter { $0.identifier == identifier })

        let width = NSLayoutConstraint(
            item: view,
            attribute: .width,
            relatedBy: relation,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: constant
        )
        width.identifier = identifier
        NSLayoutConstraint.activate([ width ])
    }

    static func fixHeight(view: UIView, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let identifier = "FixHeightConstraint"
        view.removeConstraints(view.constraints.filter { $0.identifier == identifier })

        let height = NSLayoutConstraint(
            item: view,
            attribute: .height,
            relatedBy: relation,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: constant
        )

        height.identifier = identifier
        NSLayoutConstraint.activate([ height ])
    }
}

extension UILayoutPriority {
    static func + (left: UILayoutPriority, right: Float) -> UILayoutPriority {
        UILayoutPriority(left.rawValue + right)
    }

    static func - (left: UILayoutPriority, right: Float) -> UILayoutPriority {
        UILayoutPriority(left.rawValue - right)
    }
}

func doNotTranslateAutoresizingMaskIntoConstraints(_ views: UIView ...) {
    views.forEach {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
}

func setTableHeightUsingAutolayout(tableView: UITableView, tableViewHeightContraint: NSLayoutConstraint)
{
    // Compute table height using auto-layout, see:
    // https://stackoverflow.com/a/36027259/5272316

    tableViewHeightContraint.constant = CGFloat.greatestFiniteMagnitude
    tableView.reloadData()
    tableView.layoutIfNeeded()
    tableViewHeightContraint.constant = tableView.contentSize.height
}
