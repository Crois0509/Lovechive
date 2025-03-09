//
//  Date+Extension.swift
//  Lovechive
//
//  Created by 장상경 on 3/9/25.
//

import Foundation

extension Date {
    
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        
        return formatter.string(from: self)
    }
    
}
