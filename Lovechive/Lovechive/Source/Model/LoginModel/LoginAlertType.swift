//
//  LoginAlertType.swift
//  Lovechive
//
//  Created by 장상경 on 3/31/25.
//

import Foundation

enum LoginAlertType {
    case start
    case code
    case new
    
    var title: String {
        switch self {
        case .start:
            return "시작 방법 선택하기"
        case .code:
            return "코드 공유하기"
        case .new:
            return "코드 입력하기"
        }
    }
}
