//
//  AppHelpManager.swift
//  Lovechive
//
//  Created by 장상경 on 3/10/25.
//

import UIKit

enum AppHelpers {
    
    /// 현재 window의 최상단 VC를 가져오는 메소드
    /// - Returns: 최상단 VC
    static func getTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        
        var topViewController = window.rootViewController
        
        if let navigationViewController = topViewController as? UINavigationController {
            topViewController = navigationViewController.visibleViewController
        }
        
        if let presentedVC = topViewController?.presentedViewController {
            topViewController = presentedVC
        }
        
        debugPrint(topViewController == nil ? "topViewController를 찾을 수 없습니다." : "topViewController:", topViewController!)
        return topViewController
    }
    
    // iPhoneSE 같은 작은 화면의 아이폰을 쓸 경우
    // Bottom SafeArea의 크기를 측정하고 활용하는 코드
    static var isSmallSizePhone: Bool {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return false }
        let haveBottomSize = window.safeAreaInsets.bottom == 0 ? true : false
        return haveBottomSize
    }
    
}
