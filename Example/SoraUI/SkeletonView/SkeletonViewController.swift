/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import UIKit
import SoraUI

final class SkeletonViewController: UIViewController, AdaptiveDesignable {

    var itemSize = CGSize(width: 335.0, height: 328.0)
    var containerInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    var verticalSpacing: CGFloat = 20.0

    override func viewDidLoad() {
        super.viewDidLoad()

        adjustLayout()
        configure()
    }

    private func adjustLayout() {
        itemSize.width *= designScaleRatio.width
        itemSize.height *= designScaleRatio.width

        containerInsets.top *= designScaleRatio.width
        containerInsets.left *= designScaleRatio.width
        containerInsets.right *= designScaleRatio.width
        containerInsets.bottom *= designScaleRatio.width

        verticalSpacing *= designScaleRatio.width
    }

    private func configure() {
        let skrull = Skrull(size: itemSize,
                            decorations: [
                                SingleDecoration(position: CGPoint(x: 0.5, y: 0.5), size: CGSize(width: 0.95, height: 0.95))
                                    .fill(.white)
                                    .round(CGSize(width: 10.0 / itemSize.width, height: 10.0 / itemSize.height))
                                    .shadow(UIColor(red: 124.0 / 255.0,
                                                    green: 168.0 / 255.0,
                                                    blue: 158.0 / 255.0,
                                                    alpha: 0.25),
                                            offset: CGSize(width: 0.0, height: 1.0),
                                            radius: 5.0)
            ],
                            skeletons: [
                                SingleSkeleton(position: CGPoint(x: 0.5, y: 0.22),
                                               size: CGSize(width: 0.95, height: 0.4))
                                    .round(CGSize(width: 10.0 / (itemSize.width * 0.95), height: 10.0 / (itemSize.height * 0.4)),
                                           mode: [.topLeft, .topRight]),

                                SingleSkeleton(position: CGPoint(x: 0.5, y: 0.5), size: CGSize(width: 0.9, height: 0.05))
                                    .round(),

                                MultilineSkeleton(startLinePosition: CGPoint(x: 0.5, y: 0.6),
                                                  lineSize: CGSize(width: 0.9, height: 0.025),
                                                  count: 3,
                                                  spacing: 0.025)
                                    .round()
                                    .lastLine(fraction: 0.3),

                                SingleSkeleton(position: CGPoint(x: 0.5, y: 0.8), size: CGSize(width: 0.9, height: 0.04))
                                    .round(),

                                SingleSkeleton(position: CGPoint(x: 0.08, y: 0.9), size: CGSize(width: 0.05, height: 0.05))
                                    .round()
                                    .fillStart(UIColor(red: 208.0 / 255.0, green: 2.0 / 255.0, blue: 27.0 / 255.0, alpha: 1.0))
                                    .fillEnd(UIColor(red: 208.0 / 255.0, green: 2.0 / 255.0, blue: 27.0 / 255.0, alpha: 0.9)),

                                SingleSkeleton(position: CGPoint(x: 0.92, y: 0.9), size: CGSize(width: 0.05, height: 0.05))
                                    .round()
                                    .fillStart(UIColor(red: 115.0 / 255.0, green: 168.0 / 255.0, blue: 166.0 / 255.0, alpha: 1.0))
                                    .fillEnd(UIColor(red: 115.0 / 255.0, green: 168.0 / 255.0, blue: 166.0 / 255.0, alpha: 0.9))
            ]
        )
            .fillSkeletonStart(UIColor(white: 230.0 / 255.0, alpha: 1.0))
            .fillSkeletonEnd(color: UIColor(white: 230.0 / 255.0, alpha: 0.8))
            .insets(containerInsets)
            .replicateVertically(count: 3, spacing: verticalSpacing)

        let skrullView = skrull.build()
        skrullView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(skrullView)

        skrullView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        skrullView.widthAnchor.constraint(equalToConstant: skrullView.frame.size.width).isActive = true
        skrullView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        skrullView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        skrullView.startSkrulling()
    }
}
