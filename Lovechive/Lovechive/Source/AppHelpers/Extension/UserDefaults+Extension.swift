//
//  UserDefaults+Extension.swift
//  Lovechive
//
//  Created by 장상경 on 4/3/25.
//

import UIKit

extension UserDefaults {
    static var shared: UserDefaults {
        let groupId: String = "group.lovechive"
        return UserDefaults(suiteName: groupId)!
    }
}
