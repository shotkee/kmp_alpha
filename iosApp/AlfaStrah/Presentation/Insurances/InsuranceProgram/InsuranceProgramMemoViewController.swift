//
//  InsuranceProgramMemoViewController.swift
//  AlfaStrah
//
//  Created by mac on 20.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import TinyConstraints
import WebKit

class InsuranceProgramMemoViewController: ViewController,
										  UISearchBarDelegate {
    private let webView = createWebView()
    private lazy var searchButton = createSearchButton()
    private lazy var searchBar = createSearchBar()
    private let searchKeybarLabel = createSearchKeybarLabel()
    private lazy var previousSearchResultButton = createPreviousSearchResultButton()
    private lazy var nextSearchResultButton = createNextSearchResultButton()
    private let keyboardBehavior = KeyboardBehavior()
    
    private var searchResultIndex = 1
    private var searchResultsCount: Int?
    
    struct Input {
        var insuranceContent: InsuranceProgramContent
    }
    
    var input: Input!

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        keyboardBehavior.subscribe()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        keyboardBehavior.unsubscribe()
    }
    
    private func setup() {
        title = input.insuranceContent.title
		view.backgroundColor = .Background.backgroundContent
        
        setSearchActive(false)
        
        webView.loadHTMLString(input.insuranceContent.text, baseURL: nil)
        view.addSubview(webView)
        webView.topToSuperview(usingSafeArea: true)
        webView.horizontalToSuperview(insets: .horizontal(18))
        webView.bottomToSuperview()
        
        keyboardBehavior.animations = { [weak self] frame, _, _ in
            
            guard let self
            else { return }
            
            self.webView.scrollView.contentInset.bottom = max(
                0,
                UIScreen.main.bounds.height - frame.minY - self.view.safeAreaInsets.bottom
            )
        }
    }
    
    private static func createWebView() -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.contentInset.top = 21
        webView.scrollView.showsVerticalScrollIndicator = false
        
        if #available(iOS 14.0, *) {
            webView.pageZoom = 0.5
        }
        
        return webView
    }
    
    private func createSearchButton() -> UIBarButtonItem
    {
        return UIBarButtonItem(
			image: .Icons.search,
            style: .plain,
            target: self,
            action: #selector(onSearchButton)
        )
    }
    
    @objc private func onSearchButton()
    {
        setSearchActive(true)
    }
    
    private func createSearchBar() -> UISearchBar
    {
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = true
        searchBar.placeholder = NSLocalizedString("common_search", comment: "")
		searchBar.tintColor = .Icons.iconAccent
        searchBar.inputAccessoryView = createSearchKeybar()
        searchBar.delegate = self
        
        return searchBar
    }
    
    private func createSearchKeybar() -> UIToolbar
    {
        let fixedSpaceItem = UIBarButtonItem(
            barButtonSystemItem: .fixedSpace,
            target: nil,
            action: nil
        )
        fixedSpaceItem.width = 8
        
        let searchKeybar = UIToolbar()
        searchKeybar.height(44)
        searchKeybar.items = [
            .init(customView: searchKeybarLabel),
            .init(
                barButtonSystemItem: .flexibleSpace,
                target: nil,
                action: nil
            ),
            previousSearchResultButton,
            fixedSpaceItem,
            nextSearchResultButton
        ]
        
        return searchKeybar
    }
    
    private static func createSearchKeybarLabel() -> UILabel
    {
        let searchKeybarLabel = UILabel()
        searchKeybarLabel.font = .systemFont(ofSize: 13)
        
        return searchKeybarLabel
    }
    
    private func createPreviousSearchResultButton() -> UIBarButtonItem
    {
        return UIBarButtonItem(
            image: .init(named: "toolbar_arrow_up"),
            style: .plain,
            target: self,
            action: #selector(onPreviousSearchResultButton)
        )
    }
    
    @objc private func onPreviousSearchResultButton()
    {
        webView.searchPrevious()
        
        searchResultIndex -= 1
        updateSearchResults()
    }
    
    private func createNextSearchResultButton() -> UIBarButtonItem
    {
        return UIBarButtonItem(
            image: .init(named: "toolbar_arrow_down"),
            style: .plain,
            target: self,
            action: #selector(onNextSearchResultButton)
        )
    }
    
    @objc private func onNextSearchResultButton()
    {
        webView.searchNext()
        
        searchResultIndex += 1
        updateSearchResults()
    }
    
    private func setSearchActive(_ active: Bool)
    {
        if active
        {
            navigationItem.rightBarButtonItem = nil
            navigationItem.titleView = searchBar
            searchBar.becomeFirstResponder()
            searchResultsCount = nil
            updateSearchResults()
        }
        else
        {
            navigationItem.rightBarButtonItem = searchButton
            navigationItem.titleView = nil
            webView.removeAllHighlights()
        }
    }
    
    private func updateSearchResults()
    {
        if let searchResultsCount
        {
            searchKeybarLabel.text = searchResultsCount > 0
                ? String(
                    format: NSLocalizedString("common_progress_counter", comment: ""),
                    searchResultIndex,
                    searchResultsCount
                )
                : NSLocalizedString("common_nothing_found", comment: "")
            searchKeybarLabel.sizeToFit()
            
            previousSearchResultButton.isEnabled = searchResultIndex > 1
            nextSearchResultButton.isEnabled = searchResultIndex < searchResultsCount
        }
        else
        {
            searchKeybarLabel.text = nil
            previousSearchResultButton.isEnabled = false
            nextSearchResultButton.isEnabled = false
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.text = nil
        setSearchActive(false)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        webView.removeAllHighlights()
        searchResultIndex = 1
        searchResultsCount = nil
        
        guard !searchText.isEmpty
        else
        {
            updateSearchResults()
            return
        }
        
        webView.highlightAllOccurencesOfString(string: searchText)
        webView.searchNext()
        
        webView.handleSearchResultCount { [weak self] count in
            
            guard let self
            else { return }
            
            self.searchResultsCount = count
            self.updateSearchResults()
        }
    }
}
