//
//  Date+Extension.swift
//  Lovechive
//
//  Created by 장상경 on 3/9/25.
//

import Foundation

extension Date {
    
    /// Date를 String 타입으로 변환시키는 메소드
    /// - Returns: String 타입의 날짜
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일"
        
        return formatter.string(from: self)
    }
    
    /// Date를 String 타입으로 변환시키는 메소드
    /// - Returns: String 타입의 날짜, 시간
    func formattedDateAndTime() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.M.d(E) a h시 m분"
        
        return formatter.string(from: self)
    }
    
}
