/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import UIKit

class ModalInputPresentationController: UIPresentationController {
    let shadowOpacity: CGFloat

    private var backgroundView: UIView?

    var interactiveDismissal: UIPercentDrivenInteractiveTransition?
    var initialTranslation: CGPoint = .zero

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

    private func attachPanGesture() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(sender:)))
        containerView?.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
    }

    // MARK: Presentation overridings

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {
            return
        }

        configureBackgroundView(on: containerView)
        attachCancellationGesture()
        attachPanGesture()

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

    // MARK: Interactive dismissal

    @objc func didPan(sender: Any?) {
        guard let panGestureRecognizer = sender as? UIPanGestureRecognizer else { return }
        guard let view = panGestureRecognizer.view else { return }

        handlePan(from: panGestureRecognizer, on: view)
    }

    private func handlePan(from panGestureRecognizer: UIPanGestureRecognizer, on view: UIView) {
        let translation = panGestureRecognizer.translation(in: view)
        let velocity = panGestureRecognizer.velocity(in: view)

        switch panGestureRecognizer.state {
        case .began, .changed:

            if let interactiveDismissal = interactiveDismissal {
                let progress = min(1.0, max(0.0, (translation.y - initialTranslation.y) / max(1.0, view.bounds.size.height)))

                interactiveDismissal.update(progress)
            } else {
                interactiveDismissal = UIPercentDrivenInteractiveTransition()
                initialTranslation = translation
                presentedViewController.dismiss(animated: true)
            }
        case .cancelled, .ended:
            if let interactiveDismissal = interactiveDismissal {
                stopPullToDismiss(finished: panGestureRecognizer.state != .cancelled && (
                    (interactiveDismissal.percentComplete >= 0.35 && velocity.y >= 0) ||
                        (
                            velocity.y >= 1280.0 &&
                                translation.y >= 87.0
                        )
                ))
            }
        default:
            break
        }
    }

    private func stopPullToDismiss(finished: Bool) {
        guard let interactiveDismissal = interactiveDismissal else {
            return
        }

        if finished {
            interactiveDismissal.completionSpeed = 0.45
            interactiveDismissal.finish()
        } else {
            interactiveDismissal.completionSpeed = 0.45
            interactiveDismissal.cancel()
        }

        self.interactiveDismissal = nil
    }
}

extension ModalInputPresentationController: ModalInputViewPresenterProtocol {
    func hide(view: ModalInputViewProtocol, animated: Bool) {
        guard interactiveDismissal == nil else {
            return
        }

        dismiss(animated: animated)
    }
}

extension ModalInputPresentationController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
