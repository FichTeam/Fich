//
//  UILabelWithPadding.swift
//  Fich
//
//  Created by Tran Tien Tin on 8/10/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import Foundation
import UIKit

class UILabelWithPadding: UILabel {
    let topInset = CGFloat(5)
    let bottomInset = CGFloat(5)
    let leftInset = CGFloat(10)
    let rightInset = CGFloat(10)
    
    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override public var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += topInset + bottomInset
        intrinsicSuperViewContentSize.width += leftInset + rightInset
        return intrinsicSuperViewContentSize
    }
}
