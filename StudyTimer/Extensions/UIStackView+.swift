//
//  UIStackView+.swift
//  StudyTimer
//
//  Created by Ryu on 2021/07/18.
//

import UIKit

extension UIStackView {
    func addArrangedSubViews(views: [UIView]) {
        removeAllArrangedSubviews()
        views.forEach {
            self.addArrangedSubview($0)
        }
    }
    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({$0.constraints }))
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}
