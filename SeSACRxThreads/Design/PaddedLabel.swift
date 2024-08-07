//
//  PaddedLabel.swift
//  SeSACRxThreads
//
//  Created by J Oh on 8/7/24.
//

import UIKit

final class BasePaddingLabel: UILabel {
    private var padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)

    convenience init(padding: UIEdgeInsets) {
        self.init()
        self.padding = padding
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right

        return contentSize
    }
}
