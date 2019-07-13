/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import UIKit
import SoraUI

final class ModalPresentationViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        configureSelectButton()
    }

    private func configureSelectButton() {
        let selectItem = UIBarButtonItem(title: "Select",
                                         style: .plain,
                                         target: self,
                                         action: #selector(actionSelect))
        navigationItem.rightBarButtonItem = selectItem
    }

    // MARK

    @objc func actionSelect() {
        let toolbar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: 44.0))

        let configuration = ModalInputPresentationConfiguration(shadowOpacity: 0.19)
        let transitioningDelegate = ModalInputPresentationFactory(configuration: configuration)

        let viewController = UIViewController()
        viewController.view = toolbar
        viewController.transitioningDelegate = transitioningDelegate
        viewController.modalPresentationStyle = .custom

        present(viewController, animated: true, completion: nil)
    }
}
