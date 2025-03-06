//
//  CustomFont.swift
//  Lovechive
//
//  Created by 장상경 on 3/6/25.
//

import Foundation
import UIKit

// 커스텀폰트 추가
extension UIFont {
    static func myoyaFont(_ size: CGFloat) -> UIFont {
        let myoyaRegular = "MyoyaFont-Rg"
        
        return UIFont(name: myoyaRegular, size: size) ?? .systemFont(ofSize: size, weight: .regular)
    }
}
