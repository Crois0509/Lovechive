//
//  AlertColorSetModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/19/25.
//

import UIKit

enum AlertColorSetModel: CaseIterable {
    case pink, purple, blue, green, yellow
    
    var sendColor: UIColor? {
        switch self {
        case .pink:
            return UIColor.Personal.pointPink
        case .purple:
            return UIColor.Diary.purple
        case .blue:
            return UIColor.Diary.blue
        case .green:
            return UIColor.Diary.green
        case .yellow:
            return UIColor.Diary.yellow
        }
    }
    
    var sendColorName: String {
        switch self {
        case .pink:
            return "personalColor/pointPink"
        case .purple:
            return "diaryColor/purple"
        case .blue:
            return "diaryColor/blue"
        case .green:
            return "diaryColor/green"
        case .yellow:
            return "diaryColor/yellow"
        }
    }
}
