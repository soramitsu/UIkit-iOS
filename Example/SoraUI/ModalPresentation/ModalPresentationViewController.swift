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
        let view = UIView()
        view.backgroundColor = .darkText

        let headerStyle = ModalInputPresentationHeaderStyle(preferredHeight: 20.0,
                                                            backgroundColor: .darkText,
                                                            cornerRadius: 20.0,
                                                            indicatorVerticalOffset: 2.0,
                                                            indicatorSize: CGSize(width: 25, height: 2.0),
                                                            indicatorColor: .lightGray)
        let style = ModalInputPresentationStyle(backdropColor: UIColor.black.withAlphaComponent(0.19),
                                                    headerStyle: headerStyle)
        let configuration = ModalInputPresentationConfiguration(style: style)

        let viewController = UIViewController()
        viewController.preferredContentSize = CGSize(width: 0.0, height: 395.0)
        viewController.view = view
        viewController.modalTransitioningFactory = ModalInputPresentationFactory(configuration: configuration)
        viewController.modalPresentationStyle = .custom

        present(viewController, animated: true, completion: nil)
    }
}
