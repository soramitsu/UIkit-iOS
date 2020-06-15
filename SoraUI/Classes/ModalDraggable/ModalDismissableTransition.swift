//
/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/


import Foundation

protocol ModalDismissable {
    
    var draggableView: UIView { get }
    var childView: UIView! { get }
    
    func didDismiss()
    func dismiss(animated flag: Bool, completion: (() -> Void)?)
    
}

class ModalDismissableTransition: NSObject, UIViewControllerTransitioningDelegate {
    
    private lazy var animatedTransitioning: ModalDismissableAnimatedTransitioning = {
        return ModalDismissableAnimatedTransitioning()
    }()
    
    private var interactionControllerForDismissal: UIViewControllerInteractiveTransitioning? {
        return presentationController?.dismissInteractionController
    }
    
    private var presentationController: ModalDismissablePresentationViewController?
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animatedTransitioning.presenting = true
        return animatedTransitioning
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animatedTransitioning.presenting = false
        return animatedTransitioning
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionControllerForDismissal
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if let presentationController = presentationController {
            return presentationController
        }
        presentationController = ModalDismissablePresentationViewController(presentedViewController: presented, presenting: presenting ?? source)
        return presentationController
    }
    
}

class ModalDismissablePresentationViewController: UIPresentationController {
    
    var dismissInteractionController: UIPercentDrivenInteractiveTransition?
    
    var modalDismissable: ModalDismissable? {
        return presentedViewController as? ModalDismissable
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        containerView?.addSubview(presentedView!)
        if let modalDismissable = modalDismissable {
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
            modalDismissable.draggableView.addGestureRecognizer(gesture)
        }
    }
    
    @objc
    private func handlePan(gesture: UIPanGestureRecognizer) {
        guard let modalDismissable = modalDismissable else {
            return
        }
        let view = modalDismissable.childView!
        let percentThreshold: CGFloat = 0.3

        let translation = gesture.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        switch gesture.state {
        case .began:
            dismissInteractionController = UIPercentDrivenInteractiveTransition()
            dismissInteractionController?.completionSpeed = CGFloat(CATransaction.animationDuration())
            modalDismissable.dismiss(animated: true) { [weak self] in
                if let interactionController = self?.dismissInteractionController {
                    if interactionController.percentComplete >= percentThreshold {
                        modalDismissable.didDismiss()
                        self?.dismissInteractionController = nil
                    }
                    return
                } else {
                    modalDismissable.didDismiss()
                }
            }
        case .changed:
            dismissInteractionController?.update(progress)
        case .cancelled:
            dismissInteractionController?.cancel()
        case .ended:
            if progress > percentThreshold {
                dismissInteractionController?.finish()
            } else {
                dismissInteractionController?.cancel()
            }
        default:
            break
        }
    }
    
}


class ModalDismissableAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    private var transitionView: UIView!
    var presenting: Bool = true
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return CATransaction.animationDuration()
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
            else {
                return
        }
        let containerView = transitionContext.containerView
        let containerFrame = transitionContext.containerView.frame
        var toViewStartFrame = transitionContext.initialFrame(for: toVC)
        let toViewFinalFrame = transitionContext.finalFrame(for: toVC)
        var fromViewFinalFrame = transitionContext.finalFrame(for: fromVC)
        
        if (presenting) {
            transitionView = UIView(frame: containerFrame)
            transitionView.backgroundColor = UIColor.black
            transitionView.alpha = 0
            
            containerView.insertSubview(transitionView, belowSubview: toVC.view)
            toViewStartFrame.origin.x = 0;
            toViewStartFrame.origin.y = containerFrame.size.height;
            toVC.view.frame = toViewStartFrame
        } else {
            fromViewFinalFrame = CGRect(x: 0,
                                        y: containerFrame.size.height,
                                        width: toVC.view.frame.size.width,
                                        height: toVC.view.frame.size.height);
            
        }


        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       animations: {
                        if self.presenting {
                            self.transitionView.alpha = 0.4
                            toVC.view.frame = toViewFinalFrame
                        } else {
                            self.transitionView.alpha = 0
                            fromVC.view.frame = fromViewFinalFrame
                        }
        }) { _ in
            let success = !transitionContext.transitionWasCancelled
            
            if !self.presenting && success {
                fromVC.view.removeFromSuperview()
                self.transitionView.removeFromSuperview()
            }
            
            if self.presenting && !success {
                toVC.view.removeFromSuperview()
                self.transitionView.removeFromSuperview()
            }
            
            transitionContext.completeTransition(success)
        }
    }
}
