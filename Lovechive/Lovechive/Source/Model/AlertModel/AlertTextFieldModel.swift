//
//  AlertTextFieldModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/12/25.
//

import UIKit

/// 커스텀 Alert 뷰의 텍스트필드 상태를 정의하는 모델
enum AlertTextFieldModel {
    case limit(value: Int)
    case time
    case calendar
    
    var buttonImage: UIImage? {
        switch self {
        case .limit:
            return nil
        case .time:
            return UIImage.Icon.selectTimeIcon
        case .calendar:
            return UIImage.Icon.selectDateIcon
        }
    }
}
