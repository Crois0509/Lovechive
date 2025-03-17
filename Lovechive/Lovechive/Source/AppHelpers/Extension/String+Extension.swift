//
//  String+Extension.swift
//  Lovechive
//
//  Created by 장상경 on 3/13/25.
//

import Foundation

extension String {
    
    /// String 타입의 데이터를 Date 타입으로 변환하는 메소드
    /// - Returns: Date 타입으로 변환 된 데이터(nil일 수도 있음)
    func formattedStringToDate() -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 a h시 m분"
        
        return formatter.date(from: self)
    }
    
}
