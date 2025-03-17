//
//  UITextField+Extension.swift
//  Lovechive
//
//  Created by 장상경 on 3/12/25.
//

import UIKit

extension UITextField {
    
    /// 텍스트필드의 플레이스홀더를 세팅하는 메소드
    /// - Parameters:
    ///   - title: 플레이스홀더의 텍스트
    ///   - color: 플레이스홀더의 컬러
    func setPlaceholder(title: String, color: UIColor) {
        let title = title
        self.attributedPlaceholder = NSAttributedString(
            string: title,
            attributes: [NSAttributedString.Key.foregroundColor: color,
                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular)
                        ]
        )
    }
}
