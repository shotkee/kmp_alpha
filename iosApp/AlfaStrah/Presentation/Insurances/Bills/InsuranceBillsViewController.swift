//
//  InsuranceBillsViewController.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 08.12.2021.
//  Copyright © 2021 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

final class InsuranceBillsViewController: ViewController, UITableViewDelegate, UITableViewDataSource {
    enum Constants {
        static let minAmountToPayInRoubles: Double = 1
    }

    struct Input {
        var insurance: Insurance
    }
    
    struct Output {
        var onInsuranceBillTapped: (InsuranceBill) -> Void
        var payOffSelectedBills: ([InsuranceBill]) -> Void
        let updateBills: () -> Void
    }
    
    var input: Input!
    var output: Output!
    
    struct Notify {
        let insuranceUpdated: (Insurance) -> Void
    }
    
    private(set) lazy var notify = Notify(
        insuranceUpdated: { [weak self] insurance in
            guard let self = self
            else { return }
            
            guard insurance.id == self.input.insurance.id
            else { return }
            
            self.input.insurance = insurance
            
            self.update()
        }
    )
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var payOffSelectedBillsButtonContainer: UIView!
    @IBOutlet private var payOffSelectedBillsButton: RoundEdgeButton!

    private var isInSelectionMode = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        update()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
		navigationItem.rightBarButtonItem = nil
        isInSelectionMode = false
        updateSelectionMode()
        
        output.updateBills()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        setupBottomInsetIfNeeded()
    }

    private func setup() {
		view.backgroundColor = .Background.backgroundContent
		
        navigationItem.title = NSLocalizedString("insurance_bills", comment: "")

		tableView.backgroundColor = .clear
		subscribeDidBecomeActiveNotification()

        addZeroView()
		
		payOffSelectedBillsButton <~ Style.RoundedButton.redBackground
    }
	
	private func subscribeDidBecomeActiveNotification() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(didBecomeActiveNotification),
			name: UIApplication.didBecomeActiveNotification,
			object: nil
		)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		NotificationCenter.default.removeObserver(self)
	}
	
	@objc func didBecomeActiveNotification() {
		output.updateBills()
	}

    private func setupBottomInsetIfNeeded() {
        let bottomInset = payOffSelectedBillsButtonContainer.bounds.height
        if tableView.contentInset.bottom != bottomInset {
            tableView.contentInset.bottom = bottomInset
        }
    }

    func toggleSelectionMode() {
        isInSelectionMode.toggle()
        updateSelectionMode()
    }
    
    func updateSelectionMode() {
        self.navigationItem.rightBarButtonItem?.title = isInSelectionMode
            ? NSLocalizedString("insurance_pay_off_cancel", comment: "")
            : NSLocalizedString("insurance_select_bills", comment: "")

        tableView?.reloadData()
        for entry in input.insurance.bills.enumerated()
        where entry.element.canBeSelected {
            tableView.selectRow(
                at: .init(row: entry.offset, section: 0),
                animated: false,
                scrollPosition: .none
            )
        }

        updatePayOffSelectedBillsButton()
    }

    private func update() {
        if input.insurance.bills.isEmpty {
            let zeroViewModel = ZeroViewModel(
                kind: .custom(
                    title: NSLocalizedString("zero_no_insurance_accounts", comment: ""),
                    message: nil,
                    iconKind: .search
                )
            )
            zeroView?.update(viewModel: zeroViewModel)
            showZeroView()
        } else {
            hideZeroView()
            tableView?.reloadData()
        }

        updatePayOffSelectedBillsButton()
    }

    // MARK: - TableView delegate and data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        input.insurance.bills.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(InsuranceBillCell.id)
        let insuranceBill = input.insurance.bills[indexPath.row]
        cell.set(insuranceBill: insuranceBill, isSelecting: isInSelectionMode)
        return cell
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let insuranceBill = input.insurance.bills[indexPath.row]
        if isInSelectionMode && !insuranceBill.canBeSelected {
            return nil
        }
        return indexPath
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let insuranceBill = input.insurance.bills[indexPath.row]
        if !isInSelectionMode {
            output.onInsuranceBillTapped(insuranceBill)
        }
        updatePayOffSelectedBillsButton()
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        updatePayOffSelectedBillsButton()
    }

    private func updatePayOffSelectedBillsButton() {
        let paymentAmount = calculateSumToPay()
		payOffSelectedBillsButton.setTitle(
			getPayOffBillsButtonTitle(paymentAmount: paymentAmount),
			for: .normal
		)

        let numSelectedBills = tableView.indexPathsForSelectedRows?.count ?? 0
        payOffSelectedBillsButton.isEnabled = isInSelectionMode
            && numSelectedBills > 0
            && paymentAmount >= Constants.minAmountToPayInRoubles

        payOffSelectedBillsButton.isHidden = input.insurance.bills.isEmpty
    }

    private func calculateSumToPay() -> Double {
        (tableView.indexPathsForSelectedRows ?? [])
            .map { input.insurance.bills[$0.row].moneyAmount }
            .reduce(0, +)
    }

    private func getPayOffBillsButtonTitle(paymentAmount: Double) -> String {
        if isInSelectionMode {
            let hasFractionPart = paymentAmount.truncatingRemainder(dividingBy: 1) >= 0.01

            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = hasFractionPart ? 2 : 0
            formatter.maximumFractionDigits = 2

            return paymentAmount >= Constants.minAmountToPayInRoubles
                ? String(
                    format: NSLocalizedString("insurance_bills_pay_amount", comment: ""),
                    "\(formatter.string(for: paymentAmount) ?? "")"
                )
                : NSLocalizedString("insurance_bills_pay", comment: "")
        } else {
            return NSLocalizedString("insurance_bills_pay", comment: "")
        }
    }

    @IBAction func paySelectedBillsButtonTap() {
        guard let selectedBills = tableView.indexPathsForSelectedRows?
                .map({ input.insurance.bills[$0.row] }),
              !selectedBills.isEmpty
        else { return }

        output.payOffSelectedBills(selectedBills)
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		tableView.reloadData()
	}
}

extension InsuranceBill {
    var canBeSelected: Bool {
        canBePaidInGroup
    }

    var shouldBeHighlighted: Bool {
        switch highlighting {
            case .noHighlighting:
                return false
            case .highlightWithRed:
                return true
        }
    }
}
