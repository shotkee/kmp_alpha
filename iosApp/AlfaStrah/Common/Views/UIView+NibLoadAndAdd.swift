//
//  UIView+NibLoadAndAdd
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 29/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

extension UIView {
    /// Loads view with nib-file and inserts it into self.
    @discardableResult
    func loadAndAddSubViewFromNib(name: String) -> UIView {
        let view = UIView.fromNib(name: name, bundle: Bundle(for: type(of: self)), owner: self)
        view.frame = bounds

        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.leftAnchor.constraint(equalTo: leftAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        return view
    }
    
    @discardableResult
    func addSelfAsSubviewFromNib() -> UIView {
        return loadAndAddSubViewFromNib(name: String(describing: type(of: self)))
    }
}
