/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation

public protocol ModalInputViewProtocol: class {
    var presenter: ModalInputViewPresenterProtocol? { get set }
    var context: AnyObject? { get set }
}

public protocol ModalInputViewPresenterProtocol: class {
    func hide(view: ModalInputViewProtocol, animated: Bool)
}

public protocol ModalInputViewPresenterDelegate: class {
    func presenterShouldHide(_ presenter: ModalInputViewPresenterProtocol) -> Bool
    func presenterDidHide(_ presenter: ModalInputViewPresenterProtocol)
}

public extension ModalInputViewPresenterDelegate {
    func presenterShouldHide(_ presenter: ModalInputViewPresenterProtocol) -> Bool {
        return true
    }

    func presenterDidHide(_ presenter: ModalInputViewPresenterProtocol) {}
}
