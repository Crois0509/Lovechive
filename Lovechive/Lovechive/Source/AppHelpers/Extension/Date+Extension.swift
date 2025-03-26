//
//  Date+Extension.swift
//  Lovechive
//
//  Created by 장상경 on 3/9/25.
//

import Foundation

extension Date {
    
    /// Date 타입의 formtter 타입 정의
    enum DateFormatType {
        case yearMonthDay
        case yearMonthDayHourMinute
        case yearMonthDayE
        case yearMonth
        case monthDay
        case hourMinute
        case day
        case fullTime
        
        var dateFormat: String {
            switch self {
            case .yearMonthDay:
                return "yyyy년 M월 d일"
            case .yearMonthDayHourMinute:
                return "yyyy.M.d(E) a h시 m분"
            case .yearMonthDayE:
                return "yyyy년 M월 d일(E)"
            case .yearMonth:
                return "yyyy년 M월"
            case .monthDay:
                return "M월 d일 일정"
            case .hourMinute:
                return "a h시 m분"
            case .day:
                return "d일"
            case .fullTime:
                return "yyyy년 M월 d일 a h시 m분"
            }
        }
    }
    
    /// Date 타입의 데이터를 String 타입으로 변환시키는 메소드
    /// - Parameter type: 변경시킬 Date 타입
    /// - Returns: 변환된 String 타입
    func formattedDateToString(_ type: DateFormatType) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = type.dateFormat
        
        return formatter.string(from: self)
    }
    
}
