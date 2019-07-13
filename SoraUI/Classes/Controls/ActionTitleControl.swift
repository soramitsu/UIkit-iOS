/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import UIKit

@IBDesignable
open class ActionTitleControl: UIControl {
    public enum LayoutType: UInt {
        case fixed
        case flexible
    }

    private struct Constants {
        static let activationAnimationDuration: TimeInterval = 0.25
        static let highlightedAlpha: CGFloat = 0.5
    }

    public private(set) var imageView: UIImageView!
    public private(set) var titleLabel: UILabel!

    public private(set) var isActivated: Bool = false

    open var horizontalSpacing: CGFloat = 8.0 {
        didSet {
            invalidateLayout()
        }
    }

    open var iconDisplacement: CGFloat = 0.0 {
        didSet {
            invalidateLayout()
        }
    }

    open var activationIconAngle: CGFloat = -CGFloat.pi {
        didSet {
            if isActivated {
                imageView.transform = CGAffineTransform(rotationAngle: activationIconAngle)
            }

            invalidateLayout()
        }
    }

    open var identityIconAngle: CGFloat = 0.0 {
        didSet {
            if !isActivated {
                imageView.transform = CGAffineTransform(rotationAngle: identityIconAngle)
            }

            invalidateLayout()
        }
    }

    open var layoutType: LayoutType = .fixed {
        didSet {
            invalidateLayout()
        }
    }

    // MARK: Initialization

    override public init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        configure()
    }

    private func configure() {
        imageView = UIImageView()
        imageView.backgroundColor = .clear

        addSubview(imageView)

        titleLabel = UILabel()
        titleLabel.backgroundColor = .clear

        addSubview(titleLabel)

        addTarget(self, action: #selector(actionOnTouchUpInside(sender:)), for: .touchUpInside)
    }

    // MARK: Layout

    override open var intrinsicContentSize: CGSize {
        var contentHeight: CGFloat = 0.0
        var contentWidth: CGFloat = 0.0

        contentHeight = max(contentHeight, imageView.intrinsicContentSize.height)
        contentHeight = max(contentHeight, titleLabel.intrinsicContentSize.height)

        let preferredWidth = titleLabel.intrinsicContentSize.width + horizontalSpacing
            + imageView.intrinsicContentSize.width
        contentWidth = max(contentWidth, preferredWidth)

        return CGSize(width: contentWidth, height: contentHeight)
    }

    override open func sizeToFit() {
        let newOrigin = CGPoint(x: frame.midX - intrinsicContentSize.width / 2.0,
                                y: frame.midY - intrinsicContentSize.height / 2.0)
        frame = CGRect(origin: newOrigin, size: intrinsicContentSize)
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        var titleLabelSize = titleLabel.intrinsicContentSize
        var contentSize = intrinsicContentSize
        let imageSize = imageView.intrinsicContentSize

        if bounds.width < contentSize.width {
            titleLabelSize.width = bounds.width - horizontalSpacing - imageSize.width
            contentSize.width = bounds.width
        }

        let titleLabelOrigin: CGPoint
        let imageOrigin: CGPoint

        switch layoutType {
        case .fixed:
            titleLabelOrigin = CGPoint(x: bounds.midX - contentSize.width / 2.0,
                                       y: bounds.midY - titleLabelSize.height / 2.0)
            imageOrigin = CGPoint(x: titleLabelOrigin.x + titleLabelSize.width + horizontalSpacing,
                                  y: bounds.midY - imageSize.height / 2.0 + iconDisplacement)
        case .flexible:
            titleLabelOrigin = CGPoint(x: bounds.minX,
                                       y: bounds.midY - titleLabelSize.height / 2.0)
            imageOrigin = CGPoint(x: bounds.maxX - imageSize.width,
                                  y: bounds.midY - imageSize.height / 2.0 + iconDisplacement)
        }

        titleLabel.frame = CGRect(origin: titleLabelOrigin, size: titleLabelSize)

        if imageView.transform != .identity {
            let currentTransform = imageView.transform
            imageView.transform = .identity
            imageView.frame = CGRect(origin: imageOrigin, size: imageSize)
            imageView.transform = currentTransform
        } else {
            imageView.frame = CGRect(origin: imageOrigin, size: imageSize)
        }
    }

    open func invalidateLayout() {
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

    // MARK: Activation

    open func activate(animated: Bool) {
        isActivated = true

        if animated {
            UIView.animate(withDuration: Constants.activationAnimationDuration) {
                // apply half path first to enforce right rotation direction
                self.imageView.transform = CGAffineTransform(rotationAngle: self.activationIconAngle / 2.0)
                self.imageView.transform = CGAffineTransform(rotationAngle: self.activationIconAngle)
            }
        } else {
            self.imageView.transform = CGAffineTransform(rotationAngle: activationIconAngle)
        }
    }

    open func deactivate(animated: Bool) {
        isActivated = false

        if animated {
            UIView.animate(withDuration: Constants.activationAnimationDuration) {
                // apply half path first to enforce right rotation direction
                self.imageView.transform = CGAffineTransform(rotationAngle: self.identityIconAngle / 2.0)
                self.imageView.transform = CGAffineTransform(rotationAngle: self.identityIconAngle)
            }
        } else {
            self.imageView.transform = CGAffineTransform(rotationAngle: self.identityIconAngle)
        }
    }

    // Actions

    @objc func actionOnTouchUpInside(sender: AnyObject) {
        if isActivated {
            deactivate(animated: true)
        } else {
            activate(animated: true)
        }

        sendActions(for: [.valueChanged])
    }

    override open var isHighlighted: Bool {
        didSet {
            updateDisplayState()
        }
    }

    private func updateDisplayState() {
        imageView.alpha = isHighlighted ?  Constants.highlightedAlpha : 1.0
        titleLabel.alpha = isHighlighted ? Constants.highlightedAlpha : 1.0
    }
}
