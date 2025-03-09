//
//  TabBarButtonState.swift
//  Lovechive
//
//  Created by 장상경 on 3/9/25.
//

import UIKit

enum TabBarButtonState {
    case home
    case calendar
    case diary
    case setting
    
    var tabTitle: String {
        switch self {
        case .home:
            return "홈"
        case .calendar:
            return "캘린더"
        case .diary:
            return "다이어리"
        case .setting:
            return "설정"
        }
    }
    
    var tabImage: UIImage {
        switch self {
        case .home:
            return UIImage.Icon.homeTabIcon
        case .calendar:
            return UIImage.Icon.calendarTabIcon
        case .diary:
            return UIImage.Icon.diaryTabIcon
        case .setting:
            return UIImage.Icon.settingTabIcon
        }
    }
}
