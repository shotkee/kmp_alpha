//
//  OfficeCell
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 19/11/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class OfficeCell: UITableViewCell {
    static let id: Reusable<OfficeCell> = .fromNib()
    private let officeView = OfficeInfoView()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        clipsToBounds = false
        contentView.clipsToBounds = false
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        selectionStyle = .none
        contentView.subviews.forEach { $0.removeFromSuperview() }
        contentView.addSubview(officeView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: officeView, in: contentView))
    }

    func set(office: Office) {
        officeView.set(office: office)
    }
}
