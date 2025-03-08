//
//  FirestoreDataTypes.swift
//  Lovechive
//
//  Created by 장상경 on 3/8/25.
//

import Foundation

enum FirestoreDataTypes {
    case user
    case couple
    case diary
    case schedule
    
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
