//
// HorizontalScrollView
// AlfaStrah
//
// Created by Vasiliy Kotsiuba on 10 April 2018.
// Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

/// Section view with horizontal scroll view
class HorizontalScrollView: UIView, UIScrollViewDelegate {
    private let scrollView: UIScrollView = UIScrollView()
    private var insets: UIEdgeInsets = .zero
    private let spacing: CGFloat
    private(set) var children: [UIView]
    private weak var stackView: UIStackView?
    private let sectionWidth: CGFloat
    private var isPaging: Bool?

    private var pagingEnabled: Bool {
        cellCount > 1
    }

    private var cellCount: Int {
        children.count
    }

    var showsScrollIndicator: Bool {
        get {
            scrollView.showsHorizontalScrollIndicator
        }
        set {
            scrollView.showsHorizontalScrollIndicator = newValue
        }
    }

    init(
        spacing: CGFloat,
        insets: UIEdgeInsets,
        views: [UIView],
        autoscrollInterval: TimeInterval? = nil,
        sectionWidth: CGFloat = 0,
        isPaging: Bool? = nil
    ) {
        self.spacing = spacing
        self.insets = insets
        self.children = views
        self.autoscrollInterval = autoscrollInterval
        self.sectionWidth = sectionWidth
        self.isPaging = isPaging
        super.init(frame: .zero)


        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateScrollContent()
        startAutoscroll()
    }

    func removeSubview(_ subview: UIView) {
        guard
            let firstIndexOfView = children.firstIndex(of: subview),
            stackView?.arrangedSubviews.contains(subview) == true
        else { return }

        children.remove(at: firstIndexOfView)
        stackView?.removeArrangedSubview(subview)
        subview.removeFromSuperview()
    }

    private func updateScrollContent() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }

        let horizontalStackView = UIStackView()
        stackView = horizontalStackView
        horizontalStackView.isLayoutMarginsRelativeArrangement = true
        horizontalStackView.layoutMargins = UIEdgeInsets(top: 0, left: spacing / 2, bottom: 0, right: spacing / 2)
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .fill
        horizontalStackView.alignment = .fill
        horizontalStackView.spacing = spacing

        for view in children {
            if view !== children.last { // fix show all button infinite width calculation
                NSLayoutConstraint.fixWidth(view: view, constant: cellWidth)
            }
            horizontalStackView.addArrangedSubview(view)
        }

        scrollView.addSubview(horizontalStackView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: horizontalStackView, in: scrollView))
        scrollView.heightAnchor.constraint(equalTo: horizontalStackView.heightAnchor).isActive = true
    }

    private func setup() {
        backgroundColor = .clear
        clipsToBounds = false

        addSubview(scrollView)
        let scrollViewInsets = UIEdgeInsets(
            top: insets.top,
            left: insets.left - spacing / 2,
            bottom: insets.bottom, right:
            insets.right - spacing / 2
        )
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: scrollView, in: self, margins: scrollViewInsets))

        scrollView.showsHorizontalScrollIndicator = true
        scrollView.delaysContentTouches = false
        scrollView.clipsToBounds = false
        scrollView.backgroundColor = .clear
        scrollView.accessibilityIdentifier = "dailyDealsCollectionView"
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: -insets.left, bottom: -insets.bottom, right: -insets.right)
        scrollView.isPagingEnabled = isPaging ?? pagingEnabled
        scrollView.delegate = self
    }

    // MARK: - Autoscroll
    
    private var pageWidth: CGFloat {
        scrollView.bounds.width
    }
    private var cellWidth: CGFloat {
        sectionWidth != 0 ? sectionWidth : pageWidth - spacing
    }

    private var autoscrollInterval: TimeInterval?

    private var autoscrollTimer: Timer?

    private func stopAutoscroll() {
        autoscrollTimer?.invalidate()
        autoscrollTimer = nil
    }

    private func startAutoscroll() {
        stopAutoscroll()

        if let autoscrollInterval = self.autoscrollInterval, pagingEnabled {
            autoscrollTimer = Timer.scheduledTimer(withTimeInterval: autoscrollInterval, repeats: true) { [weak self] _ in
                self?.scrollToNextPage()
            }
        }
    }

    private func scrollToNextPage() {
        let initialPageOffsetX = ceil(scrollView.contentOffset.x / pageWidth) * pageWidth
        let nextPosition = initialPageOffsetX + pageWidth
        let targetOffset: CGPoint
        if nextPosition >= scrollView.contentSize.width - (spacing + insets.right) {
            targetOffset = CGPoint(x: 0, y: 0)
        } else {
            targetOffset = CGPoint(x: nextPosition, y: 0)
        }
        scrollView.setContentOffset(targetOffset, animated: true)
    }

    // MARK: - ScrollView delegate

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoscroll()
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        startAutoscroll()
    }
}
