/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation

public struct ModalInputPresentationHeaderStyle {
    public let preferredHeight: CGFloat
    public let backgroundColor: UIColor
    public let cornerRadius: CGFloat
    public let indicatorVerticalOffset: CGFloat
    public let indicatorSize: CGSize
    public let indicatorColor: UIColor

    public init(preferredHeight: CGFloat,
                backgroundColor: UIColor,
                cornerRadius: CGFloat,
                indicatorVerticalOffset: CGFloat,
                indicatorSize: CGSize,
                indicatorColor: UIColor) {
        self.preferredHeight = preferredHeight
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.indicatorVerticalOffset = indicatorVerticalOffset
        self.indicatorSize = indicatorSize
        self.indicatorColor = indicatorColor
    }
}

public struct ModalInputPresentationStyle {
    public let backdropColor: UIColor
    public let headerStyle: ModalInputPresentationHeaderStyle?

    public init(backdropColor: UIColor, headerStyle: ModalInputPresentationHeaderStyle? = nil) {
        self.backdropColor = backdropColor
        self.headerStyle = headerStyle
    }
}

public extension ModalInputPresentationStyle {
    static var defaultStyle: ModalInputPresentationStyle {
        ModalInputPresentationStyle(backdropColor: UIColor.black.withAlphaComponent(0.5), headerStyle: nil)
    }
}
