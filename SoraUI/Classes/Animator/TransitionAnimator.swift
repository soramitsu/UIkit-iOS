/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import UIKit

public final class TransitionAnimator: ViewAnimatorProtocol {
    public var duration: TimeInterval
    public var type: CATransitionType

    public init(type: CATransitionType, duration: TimeInterval = 0.25) {
        self.type = type
        self.duration = duration
    }

    public func animate(view: UIView, completionBlock: ((Bool) -> Void)?) {
        CATransaction.begin()

        let animation = CATransition()
        animation.type = type
        animation.duration = duration
        view.layer.add(animation, forKey: nil)

        if let completion = completionBlock {
            CATransaction.setCompletionBlock {
                completion(true)
            }
        }

        CATransaction.commit()
    }
}
