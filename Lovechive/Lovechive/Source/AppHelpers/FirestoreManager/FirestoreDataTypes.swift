//
//  FirestoreDataTypes.swift
//  Lovechive
//
//  Created by 장상경 on 3/8/25.
//

import Foundation

/// FirestoreManager의 State를 정의하는 enum
enum FirestoreDataTypes {
    case user
    case couple
    case diary(id: String)
    case schedule(id: String)
    
    var typeName: String {
        switch self {
        case .user:
            return "users"
        case .couple:
            return "couples"
        case .diary:
            return "diaries"
        case .schedule:
            return "schedules"
        }
    }
}
