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
    public let shadowOpacity: CGFloat
    public let headerStyle: ModalInputPresentationHeaderStyle?

    public init(shadowOpacity: CGFloat, headerStyle: ModalInputPresentationHeaderStyle? = nil) {
        self.shadowOpacity = shadowOpacity
        self.headerStyle = headerStyle
    }
}

public extension ModalInputPresentationStyle {
    static var defaultStyle: ModalInputPresentationStyle {
        ModalInputPresentationStyle(shadowOpacity: 0.5, headerStyle: nil)
    }
}
