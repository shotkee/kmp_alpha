//
//  OSAGORenewInProgressViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 15.03.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class OSAGORenewInProgressViewController: ViewController {
    private var timer: Timer?

    struct Input {
        let renewStatus: (@escaping (_ continueTimer: Bool) -> Void) -> Void
    }

    var input: Input!

    override func viewDidLoad() {
        super.viewDidLoad()

        _ = showLoadingIndicator(message: NSLocalizedString("osago_renew_inprogress_text", comment: ""))
        updateRenewStatus()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stopTimer()
    }

    private func starTimer() {
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(updateRenewStatus), userInfo: nil, repeats: true)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc private func updateRenewStatus() {
        stopTimer()
        input.renewStatus { [weak self] continueTimer in
            guard let self = self else { return }

            if continueTimer {
                self.starTimer()
            }
        }
    }
}
