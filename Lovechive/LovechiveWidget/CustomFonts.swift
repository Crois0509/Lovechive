//
//  CustomFonts.swift
//  Lovechive
//
//  Created by 장상경 on 4/3/25.
//

import Foundation
import SwiftUI

// 커스텀폰트 추가
extension Font {
    static func myoyaFont(_ size: CGFloat) -> Font {
        let myoyaRegular = "MyoyaFont-Rg"
        
        return .custom(myoyaRegular, size: size)
    }
}
