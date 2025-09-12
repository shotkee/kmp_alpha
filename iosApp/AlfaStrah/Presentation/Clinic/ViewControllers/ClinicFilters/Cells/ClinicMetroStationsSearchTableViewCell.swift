//
//  ClinicMetroStationsSearchTableViewCell.swift
//  AlfaStrah
//
//  Created by Makson on 15.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import TinyConstraints
import Legacy

class ClinicMetroStationsSearchTableViewCell: UITableViewCell
{
	static let id: Reusable<ClinicMetroStationsSearchTableViewCell> = .fromClass()
	
	// MARK: - Outlets
	private let stackView = createStackView()
	private(set) var searchBar = UISearchBar()
	private let containerCollectionView = UIView()
	private lazy var collectionView: UICollectionView = {
		let value: UICollectionView = .init(frame: .zero, collectionViewLayout: collectionLayout)
		value.backgroundColor = .clear
		value.delegate = self
		value.dataSource = self
		value.showsHorizontalScrollIndicator = false
		value.showsVerticalScrollIndicator = false
		value.isScrollEnabled = true
		value.isUserInteractionEnabled = true
		value.registerReusableCell(ClinicMetroStationsTagCollectionViewCell.id)
		
		return value
	}()
	
	private lazy var collectionLayout: UICollectionViewFlowLayout = {
		let value: UICollectionViewFlowLayout = .init()
		value.scrollDirection = .horizontal
		
		return value
	}()
	
	// MARK: - Variables
	private var searchText: String = ""
	private var metroStations: [MetroStation] = []
	private var tapDeleteMetroStationCallback: ((MetroStation) -> Void)?
	private var editTextCallback: ((String) -> Void)?
	
	// MARK: Lifecycle
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
	{
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		setupUI()
	}

	required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		
		fatalError("init(coder:) has not been implemented")
	}
}

extension ClinicMetroStationsSearchTableViewCell
{
	func setup(
		metroStations: [MetroStation],
		tapDeleteMetroStationCallback: @escaping ((MetroStation) -> Void),
		editTextCallback: @escaping ((String) -> Void)
	)
	{
		self.metroStations = metroStations
		self.tapDeleteMetroStationCallback = tapDeleteMetroStationCallback
		self.editTextCallback = editTextCallback
		containerCollectionView.isHidden = metroStations.isEmpty
		self.collectionView.reloadData()
	}
}

private extension ClinicMetroStationsSearchTableViewCell
{
	static func createStackView() -> UIStackView
	{
		let stackView = UIStackView()
		stackView.axis = .vertical
		return stackView
	}
	
	func setupUI()
	{
		selectionStyle = .none
		clipsToBounds = false
		contentView.clipsToBounds = false
		backgroundColor = .Background.backgroundContent
		contentView.backgroundColor = .Background.backgroundContent
		setupSeparatorView()
		setupStackView()
		setupSearchBar()
		setupCollectionView()
	}
	
	func setupSeparatorView()
	{
		let view = UIView()
		view.backgroundColor = .Stroke.divider
		contentView.addSubview(view)
		view.edgesToSuperview(
			excluding: .bottom,
			insets: .init(
				top: 24,
				left: 18,
				bottom: 0,
				right: 7
			)
		)
		view.height(1)
	}
	
	func setupStackView()
	{
		contentView.addSubview(stackView)
		stackView.edgesToSuperview(
			insets: .init(
				top: 49,
				left: 10,
				bottom: 6,
				right: 0
			)
		)
	}
	
	func setupSearchBar()
	{
		searchBar.delegate = self
		searchBar.placeholder = NSLocalizedString("common_search", comment: "")
		searchBar.returnKeyType = .search
		searchBar.backgroundImage = UIImage()
		searchBar.barTintColor = .Background.backgroundContent
		stackView.addArrangedSubview(searchBar)
	}
	
	func setupCollectionView()
	{
		containerCollectionView.addSubview(collectionView)
		collectionView.edgesToSuperview(
			insets: .init(
				top: 0,
				left: 6,
				bottom: 0,
				right: 5
			)
		)
		collectionView.height(28)
		stackView.addArrangedSubview(containerCollectionView)
		containerCollectionView.isHidden = metroStations.isEmpty
	}
}

// MARK: UISearchBarDelegate
extension ClinicMetroStationsSearchTableViewCell: UISearchBarDelegate
{
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		self.searchBar.showsCancelButton = true
	}

	func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
		searchBar.showsCancelButton = !(searchBar.text?.isEmpty ?? true)
		searchBar.setShowsCancelButton(false, animated: true)
		return true
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		self.searchText = searchText
		editTextCallback?(searchText)
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.showsCancelButton = false
		searchBar.resignFirstResponder()
	}

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		if searchText != searchBar.text {
			searchText = searchBar.text ?? ""
		}
		
		searchBar.resignFirstResponder()
	}
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension ClinicMetroStationsSearchTableViewCell: UICollectionViewDelegate,
												  UICollectionViewDataSource,
												  UICollectionViewDelegateFlowLayout
{
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int 
	{
		metroStations.count
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize 
	{
		guard let metroStation = metroStations[safe: indexPath.item]
		else { return .zero }
		
		let widthTag = metroStation.title.width(
			withConstrainedHeight: 15,
			font: Style.Font.text
		) + 56

		return .init(width: widthTag, height: 28)
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
	{
		let cell = collectionView.dequeueReusableCell(
			ClinicMetroStationsTagCollectionViewCell.id,
			indexPath: indexPath
		)
		
		cell.setup(
			metroStation: metroStations[indexPath.item],
			tapDeleteMetroStationCallback:
			{
				[weak self] metroStation in
				
				self?.tapDeleteMetroStationCallback?(metroStation)
			}
		)
		
		return cell
	}
}

// MARK: - Constants

private extension ClinicMetroStationsSearchTableViewCell
{
	struct Constants {
		static let tagViewHeight: CGFloat = 28
		static let widthScreen = UIScreen.main.bounds.width
		static let defaultWidthCollection: CGFloat = widthScreen - 32
	}
}
