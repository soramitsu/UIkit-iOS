/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import UIKit

class ModalInputPresentationController: UIPresentationController {
    let shadowOpacity: CGFloat

    private var backgroundView: UIView?

    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, shadowOpacity: CGFloat) {

        self.shadowOpacity = shadowOpacity

        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        if let modalInputView = presentedViewController.view as? ModalInputViewProtocol {
            modalInputView.presenter = self
        }
    }

    private func configureBackgroundView(on view: UIView) {
        if let currentBackgroundView = backgroundView {
            view.insertSubview(currentBackgroundView, at: 0)
        } else {
            let newBackgroundView = UIView(frame: view.bounds)
            newBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(shadowOpacity)
            view.insertSubview(newBackgroundView, at: 0)
            backgroundView = newBackgroundView
        }

        backgroundView?.frame = view.bounds
    }

    private func attachCancellationGesture() {
        let cancellationGesture = UITapGestureRecognizer(target: self,
                                                         action: #selector(actionDidCancel(gesture:)))
        backgroundView?.addGestureRecognizer(cancellationGesture)
    }

    // MARK: Presentation overridings

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {
            return
        }

        configureBackgroundView(on: containerView)
        attachCancellationGesture()

        animateBackgroundAlpha(fromValue: 0.0, toValue: 1.0)
    }

    override func dismissalTransitionWillBegin() {
        animateBackgroundAlpha(fromValue: 1.0, toValue: 0.0)
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let presentedView = presentedView else {
            return .zero
        }

        guard let containerView = containerView else {
            return .zero
        }

        var layoutFrame = containerView.bounds

        if #available(iOS 11.0, *) {
            layoutFrame = containerView.safeAreaLayoutGuide.layoutFrame
        }

        return CGRect(x: layoutFrame.minX,
                      y: layoutFrame.maxY - presentedView.frame.size.height,
                      width: presentedView.frame.size.width,
                      height: presentedView.frame.size.height)
    }

    // MARK: Animation

    func animateBackgroundAlpha(fromValue: CGFloat, toValue: CGFloat) {
        backgroundView?.alpha = fromValue

        let animationBlock: (UIViewControllerTransitionCoordinatorContext) -> Void = { _ in
            self.backgroundView?.alpha = toValue
        }

        presentingViewController.transitionCoordinator?
            .animate(alongsideTransition: animationBlock, completion: nil)
    }

    func dismiss(animated: Bool) {
        presentingViewController.dismiss(animated: animated, completion: nil)
    }

    // MARK: Action

    @objc func actionDidCancel(gesture: UITapGestureRecognizer) {
        guard let modalInputView = presentedView as? ModalInputViewPresenterDelegate else {
            dismiss(animated: true)
            return
        }

        if modalInputView.presenterShouldHide(self) {
            dismiss(animated: true)
        }
    }
}

extension ModalInputPresentationController: ModalInputViewPresenterProtocol {
    func hide(view: ModalInputViewProtocol, animated: Bool) {
        dismiss(animated: animated)
    }
}
