//
//  LovechiveAlertModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/12/25.
//

import Foundation

/// 커스텀 Alert뷰의 상태를 정의하는 모델
enum AlertTypes {
    case newSchedule(date: Date)
    case editSchedule(data: ScheduleDataModel)
    case newDiary
    case editDiary(data: DiaryListDataModel)
    case editMyPage(user: UserDataModel, couple: CoupleDataModel)
    
    /// Alert의 타이틀 뷰 텍스트
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
    
    /// Alert의 active 버튼 타이틀
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
    
    /// Alert의 타입에 따른 인덱스
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
