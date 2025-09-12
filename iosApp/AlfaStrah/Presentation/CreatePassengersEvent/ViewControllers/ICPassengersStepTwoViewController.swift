//
//  ICPassengersStepTwoViewController.swift
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 30.08.17.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import UIKit

class ICPassengersStepTwoViewController: ViewController {
    var categories: [RiskCategory] = []
    var draft: PassengersEventDraft?

    var output: ((ICPassengersStepTwoViewController, [RiskValue]) -> Void)?
    var onStoryboardSegue: ((UIStoryboardSegue, [RiskValue]) -> Void)?
    var onSaveDraft: ((ICPassengersStepTwoViewController, [RiskValue]) -> Void)?

    @IBOutlet private var tableView: RiskCategoryTableView!
    @IBOutlet private var nextButton: UIButton!

    private lazy var nextButtonAccessory: UIButton = {
        let button = RMRRedSubtitleButton(type: UIButton.ButtonType.custom)
        button.frame = nextButton.bounds
        button.title = "Далее"
        button.addTarget(self, action: #selector(proceedToNextStep), for: .touchUpInside)
        button.isEnabled = tableView.dataIsReady()
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        subscribeForKeyboardNotifications()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.reloadData()
    }

    private func setupUI() {
        nextButton <~ Style.Button.ActionRed(title: NSLocalizedString("common_next", comment: ""))

        title = "Шаг 2 из 4"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Ещё", style: .plain, target: self, action: #selector(showMoreMenu))

        tableView.parentViewController = self
        tableView.categories = categories
        tableView.values = draft?.values
        tableView.inputAccessory = nextButtonAccessory
        tableView.dataIsReadyCallback = { [weak self] ready in
            self?.nextButton.isEnabled = ready
            self?.nextButtonAccessory.isEnabled = ready
        }

        nextButton.isEnabled = tableView.dataIsReady()
    }

    @objc func showMoreMenu() {
        let ctrl = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let saveDraftAction = UIAlertAction(title: "Сохранить черновик", style: .default) { [unowned self] _ in
            self.saveDraft()
        }
        let cancel = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        ctrl.addAction(saveDraftAction)
        ctrl.addAction(cancel)
        if let popoverController = ctrl.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(ctrl, animated: true, completion: nil)
    }

    func saveDraft() {
        guard let save = onSaveDraft else { return }

        save(self, tableView.outputValues)
    }

    @IBAction private func proceedToNextStep() {
        view.endEditing(true)
        output?(self, tableView.outputValues)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        onStoryboardSegue?(segue, tableView.outputValues)
    }

    // MARK: - Keyboard notifications handling

    func subscribeForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard
            let frameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        else { return }

        let keyboardFrame = frameValue.cgRectValue
        let converted = view.convert(keyboardFrame, from: nil)
        var insets = tableView.contentInset

        let tableMaxY = tableView.frame.maxY
        insets.bottom = tableMaxY - converted.origin.y

        UIView.animate(withDuration: animationDuration.doubleValue) {
            self.tableView.contentInset = insets
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        guard
            let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        else { return }

        var insets = self.tableView.contentInset
        insets.bottom = 0.0

        UIView.animate(withDuration: animationDuration.doubleValue) {
            self.tableView.contentInset = insets
        }
    }
}
