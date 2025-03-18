//
//  String+Extension.swift
//  Lovechive
//
//  Created by 장상경 on 3/13/25.
//

import Foundation

extension String {
    
    enum StringFormatType {
        case fullTime
        case yearMonthDay
        case hourMinute
        
        var stringFormat: String {
            switch self {
            case .fullTime:
                return "yyyy년 M월 d일 a h시 m분"
            case .yearMonthDay:
                return "yyyy년 M월 d일"
            case .hourMinute:
                return "a h시 m분"
            }
        }
    }
    
    /// String 타입의 데이터를 Date 타입으로 변환하는 메소드
    /// - Returns: Date 타입으로 변환 된 데이터(nil일 수도 있음)
    func formattedStringToDate(_ type: StringFormatType) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = type.stringFormat
        
        return formatter.date(from: self) ?? Date()
    }
    
}
