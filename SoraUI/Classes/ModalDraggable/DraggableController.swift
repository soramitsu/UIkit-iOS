//
//  DraggableController.swift
//  SoraUI
//
//  Created by ifoatov on 6/15/20.
//

import UIKit


public final class DraggableController: UIViewController {
    
    public struct DraggableStyle {
        let backgroundColor: UIColor
        let headerViewBackgroundColor: UIColor
        let headerViewHeight: CGFloat
        let panViewBackgroundColor: UIColor
        let panViewSize: CGSize
        let topHeaderCornerRadius: CGFloat
        
        public init(backgroundColor: UIColor, headerViewBackgroundColor: UIColor, headerViewHeight: CGFloat, panViewBackgroundColor: UIColor, panViewSize: CGSize, topHeaderCornerRadius: CGFloat) {
            self.backgroundColor = backgroundColor
            self.headerViewBackgroundColor = headerViewBackgroundColor
            self.headerViewHeight = headerViewHeight
            self.panViewBackgroundColor = panViewBackgroundColor
            self.panViewSize = panViewSize
            self.topHeaderCornerRadius = topHeaderCornerRadius
        }
    }
    
    private var headerView: UIView!
    private var panView: UIView!
    private var child: UIViewController!
    private let style: DraggableStyle
    private lazy var transition: UIViewControllerTransitioningDelegate! = {
        return ModalDismissableTransition()
    }()
    
    public init(child: UIViewController, style: DraggableStyle) {
        self.child = child
        self.style = style
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = transition
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupConstraints()
    }
    
    private func configureUI() {
        view.backgroundColor = style.backgroundColor
        view.layer.cornerRadius = style.headerViewHeight / 2
        panView = UIView()
        panView.backgroundColor = style.panViewBackgroundColor
        panView.layer.cornerRadius = style.panViewSize.height / 2
        
        headerView = UIView()
        headerView.backgroundColor = style.headerViewBackgroundColor
        headerView.layer.cornerRadius = style.topHeaderCornerRadius
        
        headerView.addSubview(panView)
        view.addSubview(headerView)
        
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    private func setupConstraints() {
        
        if style.topHeaderCornerRadius > 0 {
            
            let cornersView = UIView()
            cornersView.backgroundColor = style.headerViewBackgroundColor
            headerView.insertSubview(cornersView, at: 0)

            cornersView.translatesAutoresizingMaskIntoConstraints = false
            cornersView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            cornersView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            cornersView.heightAnchor.constraint(equalToConstant: style.topHeaderCornerRadius).isActive = true
            cornersView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        }
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        headerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: style.headerViewHeight).isActive = true
        
        panView.translatesAutoresizingMaskIntoConstraints = false
        panView.widthAnchor.constraint(equalToConstant: style.panViewSize.width).isActive = true
        panView.heightAnchor.constraint(equalToConstant: style.panViewSize.height).isActive = true
        panView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        panView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        
        let childView = child.view
        childView?.translatesAutoresizingMaskIntoConstraints = false
        childView?.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        childView?.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        childView?.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        childView?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
}


extension DraggableController: ModalDismissable {
    
    var draggableView: UIView {
        return headerView
    }
    
    var childView: UIView! {
        return child.view
    }
    
    func didDismiss() {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
        child = nil
        transition = nil
    }
}
