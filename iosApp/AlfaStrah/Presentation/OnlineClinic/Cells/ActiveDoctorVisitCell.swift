//
//  ActiveDoctorVisitCell.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 22/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class ActiveDoctorVisitCell: UITableViewCell, UIScrollViewDelegate {
    static let id: Reusable<ActiveDoctorVisitCell> = .fromClass()

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var pageControl: UIPageControl!

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    private func setup() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delaysContentTouches = false
        scrollView.clipsToBounds = false
        scrollView.backgroundColor = .clear
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: .valueChanged)
    }
    
    func set(
        appointments: [CommonAppointment],
        getDateFormatter: (CommonAppointment) -> DateFormatter,
        imageLoader: ImageLoader,
        appointmentTapCallback: @escaping (CommonAppointment) -> Void
    ) {
        stackView.subviews.forEach { $0.removeFromSuperview() }

        for appointment in appointments {
            let cell = ActiveDoctorVisitView.fromNib()
            cell.set(
                appointment: appointment,
                getDateFormatter: getDateFormatter,
                imageLoader: imageLoader,
                appointmentTapCallback: appointmentTapCallback
            )
            
			cell.backgroundColor = .clear
			
			let containerView = cell.embedded(margins: insets(16), hasShadow: true)
			
			stackView.addArrangedSubview(containerView)

			containerView.width(to: scrollView)
			containerView.height(to: scrollView)
        }

        configurePageControl(appointments.count)
    }

    private func configurePageControl(_ numberOfPages: Int) {
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
		pageControl.pageIndicatorTintColor = .Icons.iconSecondary
		pageControl.currentPageIndicatorTintColor = .Icons.iconSecondary
    }

    @objc private func changePage(sender: AnyObject) {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
}
