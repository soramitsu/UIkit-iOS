/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import UIKit

public struct ModalInputPresentationConfiguration {
    public var contentAppearanceAnimator: BlockViewAnimatorProtocol
    public var contentDissmisalAnimator: BlockViewAnimatorProtocol
    public var shadowOpacity: CGFloat

    public init(contentAppearanceAnimator: BlockViewAnimatorProtocol = BlockViewAnimator(duration: 0.35, delay: 0.0, options: [.curveEaseOut]),
                contentDissmisalAnimator: BlockViewAnimatorProtocol = BlockViewAnimator(duration: 0.35, delay: 0.0, options: [.curveEaseIn]),
                shadowOpacity: CGFloat = 0.5) {
        self.contentAppearanceAnimator = contentAppearanceAnimator
        self.contentDissmisalAnimator = contentDissmisalAnimator
        self.shadowOpacity = shadowOpacity
    }
}

public class ModalInputPresentationFactory: NSObject {
    let configuration: ModalInputPresentationConfiguration

    public init(configuration: ModalInputPresentationConfiguration) {
        self.configuration = configuration

        super.init()
    }
}

extension ModalInputPresentationFactory: UIViewControllerTransitioningDelegate {

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalInputPresentationAppearanceAnimator(animator: configuration.contentAppearanceAnimator)
    }

    public func animationController(forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
        return ModalInputPresentationDismissAnimator(animator: configuration.contentDissmisalAnimator)
    }

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?,
                                       source: UIViewController) -> UIPresentationController? {
        let inputPresentationController = ModalInputPresentationController(presentedViewController: presented,
                                                                           presenting: presenting,
                                                                           shadowOpacity: configuration.shadowOpacity)
        return inputPresentationController
    }
}

public final class ModalInputPresentationAppearanceAnimator: NSObject {
    let animator: BlockViewAnimatorProtocol

    public init(animator: BlockViewAnimatorProtocol) {
        self.animator = animator

        super.init()
    }
}

extension ModalInputPresentationAppearanceAnimator: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animator.duration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let presentedController = transitionContext.viewController(forKey: .to) else {
            return
        }

        let finalFrame = transitionContext.finalFrame(for: presentedController)
        var initialFrame = finalFrame
        initialFrame.origin.y += finalFrame.size.height

        presentedController.view.frame = initialFrame
        transitionContext.containerView.addSubview(presentedController.view)

        let animationBlock: () -> Void = {
            presentedController.view.frame = finalFrame
        }

        let completionBlock: (Bool) -> Void = { finished in
            transitionContext.completeTransition(finished)
        }

        animator.animate(block: animationBlock, completionBlock: completionBlock)
    }
}

public final class ModalInputPresentationDismissAnimator: NSObject {
    let animator: BlockViewAnimatorProtocol

    public init(animator: BlockViewAnimatorProtocol) {
        self.animator = animator

        super.init()
    }
}

extension ModalInputPresentationDismissAnimator: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animator.duration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let presentedController = transitionContext.viewController(forKey: .from) else {
            return
        }

        let initialFrame = presentedController.view.frame
        var finalFrame = initialFrame
        finalFrame.origin.y = transitionContext.containerView.frame.maxY

        let animationBlock: () -> Void = {
            presentedController.view.frame = finalFrame
        }

        let completionBlock: (Bool) -> Void = { finished in
            presentedController.view.removeFromSuperview()
            transitionContext.completeTransition(finished)
        }

        animator.animate(block: animationBlock, completionBlock: completionBlock)
    }
}
