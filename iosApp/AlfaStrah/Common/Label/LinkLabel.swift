//
// LinkLabel
// AlfaStrah
//
// Created by Amir Nuriev on 23 April 2020.
// Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

/// Label that can contain clickable links.
class LinkLabel: UILabel {
    override var text: String? {
        didSet {
            attributedText = text.flatMap {
                attributedStringsWithLinks(text: $0, textAttributes: textAttributes, linkAttributes: linkAttributes)
            }
        }
    }

    override var attributedText: NSAttributedString? {
        didSet {
            activeLink = nil
            linkSelected = false
            linksBounds = .zero
            updateLinkFrames()
        }
    }

    var textAttributes: [NSAttributedString.Key: Any] = [:]
    var linkAttributes: [NSAttributedString.Key: Any] = [:]
    var selectedLinkAttributes: [NSAttributedString.Key: Any] = [:]

    var linkTapAction: ((URL) -> Void)?
    var linkTapStateChangeAction: ((Bool) -> Void)?

    /// Clickable link model.
    private struct Link {
        var url: URL
        var range: NSRange
        var frames: [CGRect]
    }

    static let linkAttributeName = NSAttributedString.Key("LinkAttributeName")
    private var links: [Link] = []
    private var linksBounds: CGRect = .zero

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateLinkFrames()
    }

    /// Sets up UI.
    private func setup() {
        isUserInteractionEnabled = true
    }

    private var naturalParagraphStyle: NSMutableParagraphStyle {
        let result = NSMutableParagraphStyle()
        result.alignment = .natural
        return result
    }

    private let tagger = NSLinguisticTagger(tagSchemes: [ .language ], options: 0)

    /// Calculates correct attributes for the text depending on its directionality.
    private func correctTextAlignment(text: String, attributes: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any] {
        var attributes = attributes
        let style = attributes[.paragraphStyle] as? NSParagraphStyle
        let paragraphStyle = style?.mutableCopy() as? NSMutableParagraphStyle ?? naturalParagraphStyle
        attributes[.paragraphStyle] = paragraphStyle
        return attributes
    }

    private static let dataDetectorTypes: NSTextCheckingResult.CheckingType = [ .link ]
    private static let dataDetector: NSDataDetector? = try? NSDataDetector(types: dataDetectorTypes.rawValue)

    /// Applies attributes to the string. General text gets textAttributes, links — linkAttributes.
    private func attributedStringsWithLinks(
        text: String,
        textAttributes: [NSAttributedString.Key: Any],
        linkAttributes: [NSAttributedString.Key: Any]
    ) -> NSAttributedString {
        let textAttributes = correctTextAlignment(text: text, attributes: textAttributes)

        let attributedString = NSMutableAttributedString(string: text, attributes: textAttributes)

        guard let dataDetector = LinkLabel.dataDetector else { return attributedString }

        let range = NSRange(location: 0, length: (text as NSString).length)
        dataDetector.enumerateMatches(in: text, options: [], range: range) { result, _, _ in
            if let result = result, let url = result.url, url.scheme == "http" || url.scheme == "https" {
                attributedString.addAttribute(LinkLabel.linkAttributeName, value: url, range: result.range)
                attributedString.addAttributes(linkAttributes, range: result.range)
            }
        }

        return NSAttributedString(attributedString: attributedString)
    }

    /// Calculates frames of the links in the text.
    private func updateLinkFrames() {
        guard bounds != linksBounds else { return }

        links = []

        guard let attributedText = attributedText else { return }

        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0
        layoutManager.addTextContainer(textContainer)

        let textHeight = layoutManager.boundingRect(forGlyphRange: layoutManager.glyphRange(for: textContainer), in: textContainer).height
        let yOffset = (bounds.height - textHeight) / 2

        attributedText.enumerateAttribute(
            LinkLabel.linkAttributeName,
            in: NSRange(location: 0, length: attributedText.length),
            options: .longestEffectiveRangeNotRequired
        ) { value, range, _ in
            guard let url = value as? URL  else { return }

            var glyphRange = NSRange(location: 0, length: 0)
            layoutManager.characterRange(forGlyphRange: range, actualGlyphRange: &glyphRange)

            var link = Link(url: url, range: range, frames: [])

            layoutManager.enumerateEnclosingRects(
                forGlyphRange: glyphRange,
                withinSelectedGlyphRange: NSRange(location: NSNotFound, length: 0),
                in: textContainer
            ) { rect, _ in
                let fixedRect = CGRect(x: rect.origin.x, y: yOffset + rect.origin.y, width: rect.width, height: rect.height)
                link.frames.append(fixedRect)
            }

            links.append(link)
        }

        linksBounds = bounds
    }

    // MARK: - Touches

    private var activeLink: Link?
    private var linkSelected: Bool = false

    /// Updates link attributes when it is pressed on.
    private func updateSelection(link: Link, selected: Bool) {
        guard linkSelected != selected, let mutableAttributedText = attributedText.flatMap(NSMutableAttributedString.init) else { return }

        let attributes = selected ? selectedLinkAttributes : linkAttributes
        mutableAttributedText.addAttributes(attributes, range: link.range)
        super.attributedText = mutableAttributedText

        linkSelected = selected
    }

    /// Clears link selection when press is finished.
    private func clearSelection() {
        if let link = activeLink {
            updateSelection(link: link, selected: false)
        }
        linkSelected = false
        activeLink = nil
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let point = touch.location(in: self)

        activeLink = links.first { link in
            link.frames.contains { $0.contains(point) }
        }

        if let link = activeLink {
            updateSelection(link: link, selected: true)
            linkSelected = true
            linkTapStateChangeAction?(true)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        if let link = activeLink {
            let point = touch.location(in: self)
            let selected = link.frames.contains { $0.contains(point) }
            updateSelection(link: link, selected: selected)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        if let link = activeLink {
            let point = touch.location(in: self)
            let active = link.frames.contains { $0.contains(point) }
            if active {
                linkTapAction?(link.url)
            }
            linkTapStateChangeAction?(false)
        }

        clearSelection()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if activeLink != nil {
            linkTapStateChangeAction?(false)
        }

        clearSelection()
    }
}
