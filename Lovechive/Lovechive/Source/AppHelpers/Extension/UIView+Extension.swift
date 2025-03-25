//
//  UIView+Extension.swift
//  Lovechive
//
//  Created by 장상경 on 3/25/25.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIView {
    var boundsHeight: Observable<CGFloat> {
        base.rx.observe(CGRect.self, "bounds")
            .compactMap { $0?.height }
            .distinctUntilChanged()
    }
}
