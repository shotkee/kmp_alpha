//
//  OfficesListViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16/11/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

final class OfficesListViewController: ViewController,
                                       UITableViewDataSource,
                                       UITableViewDelegate {
    struct Input {
        let data: () -> NetworkData<[Office]>
    }

    struct Output {
        let office: (Office) -> Void
        let refresh: () -> Void
    }

    struct Notify {
        let changed: (Insurance.Kind?) -> Void
    }

    var input: Input!
    var output: Output!

    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        changed: { [weak self] insuranceKind in
            guard let `self` = self, self.isViewLoaded else { return }

            self.update(insuranceKind)
        }
    )

    @IBOutlet private var tableView: UITableView!

    private var offices: [Office] = []
    private var filteredOffices: [Office] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        update(nil)
        output.refresh()
    }

    private func setup() {
        view.backgroundColor = .Background.backgroundContent
        
        tableView.contentInset.top = 0
        tableView.contentInset.bottom = 20
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .clear

        addZeroView()
    }

    private func update(_ insuranceKind: Insurance.Kind?) {
        switch input.data() {
            case .loading:
                zeroView?.update(viewModel: .init(kind: .loading))
                showZeroView()
            case .data(let offices):
                switch insuranceKind {
                    case .kasko?:
                        self.offices = offices.filter { $0.damageClaimAvailable }
                    case .osago?:
                        self.offices = offices.filter { $0.osagoClaimAvailable }
                    case .unknown?, .dms?, .vzr?, .property?, .passengers?, .life?, .accident?, .vzrOnOff?, .flatOnOff?, .none:
                        self.offices = offices
                }
                if offices.isEmpty {
                    showZeroView()
                    zeroView?.update(viewModel: .init(kind: .emptyList))
                } else {
                    hideZeroView()
                }
                filteredOffices = offices
                tableView.reloadData()
            case .error(let error):
                let zeroViewModel = ZeroViewModel(
                    kind: .error(error, retry: .init(kind: .always, action: { [weak self] in self?.output.refresh() }))
                )
                zeroView?.update(viewModel: zeroViewModel)
                zeroView?.update(viewModel: zeroViewModel)
                showZeroView()
        }
        view.endEditing(true)
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredOffices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(OfficeCell.id, indexPath: indexPath)
        let office = filteredOffices[indexPath.row]
        cell.set(office: office)
        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        output.office(filteredOffices[indexPath.row])
    }
}
