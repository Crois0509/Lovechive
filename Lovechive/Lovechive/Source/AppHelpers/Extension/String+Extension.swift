//
//  String+Extension.swift
//  Lovechive
//
//  Created by 장상경 on 3/13/25.
//

import Foundation

extension String {
    
    func formattedStringToDate() -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 a h시 m분"
        
        return formatter.date(from: self)
    }
    
}
