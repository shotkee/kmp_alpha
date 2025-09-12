//
//  SelectInsuranceViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 14/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class SelectInsuranceViewController: ViewController,
                                     UITableViewDataSource,
                                     UITableViewDelegate {
    private let tableView = UITableView(frame: CGRect.zero, style: .plain)
    
    struct Item {
        let insuranceId: String
        let title: String
        let subtitle: String
        let description: String
    }
    
    struct Input {
        var data: (_ useCache: Bool, _ completion: @escaping (Result<[Item], AlfastrahError>) -> Void) -> Void
    }

    struct Output {
        var selectByInsuranceId: (String) -> Void
    }

    var input: Input!
    var output: Output!
    
    private var items: [Item] = []
	
	private var firstAutoSelection = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .Background.backgroundContent
        
        title = NSLocalizedString("user_insurance_list_screen_title", comment: "")
        
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refresh(useCache: true) // for lottie animation compability
    }
    
    private func setupTableView() {
        tableView.clipsToBounds = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        
        tableView.contentInset = UIEdgeInsets(top: 21, left: 0, bottom: 0, right: 0)
        
        tableView.contentInsetAdjustmentBehavior = .never
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: tableView, in: view)
        )

        tableView.registerReusableCell(CardInsuranceCell.id)
    }
    
    private func refresh(useCache: Bool, completion: (() -> Void)? = nil) {
		var hide: (((() -> Void)?) -> Void)?
		if !useCache {
			hide = showLoadingIndicator(message: NSLocalizedString("common_load", comment: ""))
		}
        
        input.data(useCache) { [weak self] result in
			hide?(nil)
            completion?()
            
            guard let self
            else { return }
            
            switch result {
                case .success(let items):
                    if items.count == 1,
					   firstAutoSelection {
                        self.output.selectByInsuranceId(items[0].insuranceId)
						firstAutoSelection = false
                    }
                    
                    self.items = items
                    
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    self.processError(error)
                    
            }
        }
    }

    // MARK: - TableView data source & delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(CardInsuranceCell.id)
        let item = items[indexPath.row]
        cell.set(title: item.title, subtitle: item.subtitle, description: item.description)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if let insuranceId = items[safe: indexPath.row]?.insuranceId {
            output.selectByInsuranceId(insuranceId)
        }
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		tableView.reloadData()
	}
}
