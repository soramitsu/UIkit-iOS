/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import UIKit
import SoraUI

final class ModalPresentationViewController: UIViewController {

    let modalPresentationFactory: ModalInputPresentationFactory = {
        let configuration = ModalInputPresentationConfiguration(shadowOpacity: 0.19)
        return ModalInputPresentationFactory(configuration: configuration)
    }()

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
        let toolbar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: 514.0))

        let viewController = UIViewController()
        viewController.view = toolbar
        viewController.transitioningDelegate = modalPresentationFactory
        viewController.modalPresentationStyle = .custom

        present(viewController, animated: true, completion: nil)
    }
}
