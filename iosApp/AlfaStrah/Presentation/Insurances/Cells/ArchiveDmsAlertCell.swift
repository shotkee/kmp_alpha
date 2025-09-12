//
//  ArchiveDmsAlertCell
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 14/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class ArchiveDmsAlertCell: UITableViewCell {
    static let id: Reusable<ArchiveDmsAlertCell> = .fromNib()

    @IBOutlet private var titleLabel: UILabel!
	@IBOutlet private var downloadAlertImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

		backgroundColor = UIColor.Background.background
        titleLabel <~ Style.Label.secondaryText
        
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		updateTheme()
	}
	
	private func updateTheme() {
		let image = downloadAlertImageView.image
		
		downloadAlertImageView.image = image?.tintedImage(withColor: .Icons.iconSecondary)
	}
    
    func set(title: String) {
        titleLabel.text = title
    }
}
