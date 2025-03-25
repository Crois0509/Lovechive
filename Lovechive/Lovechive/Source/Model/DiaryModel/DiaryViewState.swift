//
//  DiaryViewState.swift
//  Lovechive
//
//  Created by 장상경 on 3/24/25.
//

import Foundation

enum DiaryViewState {
    case view(data: DiaryDataModel)
    case edit(data: DiaryDataModel?)
    
    var buttonTitle: String {
        switch self {
        case .view:
            return "수정하기"
        case .edit:
            return "기록하기"
        }
    }
}
