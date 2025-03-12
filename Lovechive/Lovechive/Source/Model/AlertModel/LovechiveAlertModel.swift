//
//  LovechiveAlertModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/12/25.
//

import Foundation

enum AlertTypes {
    case newSchedule
    case editSchedule
    case newDiary
    case editDiary
    case editMyPage
    
    var alertTitle: String {
        switch self {
        case .newSchedule:
            return "새 일정 추가하기"
        case .editSchedule:
            return "일정 수정하기"
        case .newDiary:
            return "새 다이어리 만들기"
        case .editDiary:
            return "다이어리 수정하기"
        case .editMyPage:
            return "내 정보 편집하기"
        }
    }
    
    var alertActiveButtonTitle: String {
        switch self {
        case .newDiary, .newSchedule:
            return "만들기"
        case .editDiary, .editSchedule:
            return "수정하기"
        case .editMyPage:
            return "편집"
        }
    }
    
    var typeIndex: Int {
        switch self {
        case .newSchedule, .editSchedule:
            return 0
        case .newDiary, .editDiary:
            return 1
        case .editMyPage:
            return 2
        }
    }
}
