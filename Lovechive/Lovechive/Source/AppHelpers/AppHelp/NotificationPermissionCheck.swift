//
//  NotificationPermissionCheck.swift
//  Lovechive
//
//  Created by 장상경 on 3/17/25.
//

import UserNotifications

struct NotificationPermissionCheck {
    /*
     사용자의 알림 권한을 확인하고 결과를 완료 핸들러를 통해 반환합니다.
    
     - Parameter completion: 알림 권한 확인 결과를 처리할 완료 핸들러입니다. `true`는 알림 권한이 부여된 경우를 나타내고,
        `false`는 권한이 거부되거나 아직 결정되지 않은 경우를 나타냅니다.
     */
    
    static func check(completion: @escaping (Bool) -> Void) {
        let current = UNUserNotificationCenter.current()
        
        current.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                // 사용자가 알림 권한을 부여한 경우
                print("알림에 대한 권한이 부여된 사용자")
                completion(true)
            case .denied, .ephemeral, .notDetermined, .provisional:
                // 사용자가 알림 권한을 거부한 경우 또는 아직 결정하지 않은 경우
                print("사용자 거부 알림 권한 또는 아직 결정하지 않음")
                completion(false)
            @unknown default:
                // 알려지지 않은 권한 상태
                print("Unknown Status")
                completion(false)
            }
        }
    }
}
