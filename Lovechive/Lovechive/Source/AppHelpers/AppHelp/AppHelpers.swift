//
//  AppHelpManager.swift
//  Lovechive
//
//  Created by 장상경 on 3/10/25.
//

import UIKit
import RxSwift
import RxCocoa

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
    
    static func changeRootViewControllerFromWindow(_ rootViewType: RootViews) {
        guard let topView = self.getTopViewController()?.view else { return }
        
        var rootView: UIViewController
        
        switch rootViewType {
        case .main:
            rootView = UINavigationController(rootViewController: MainViewController())
        case .login:
            rootView = LoginViewController()
        case .start:
            rootView = LoginAlertViewController(type: .start)
        }
        
        DispatchQueue.main.async {
            UIView.transition(with: topView.window!, duration: 0.5, options: .transitionCrossDissolve) {
                topView.window?.rootViewController = rootView
            }
        }
    }
    
    static func checkCoupleData() {
        guard let coupleId = UserDefaults.standard.string(forKey: AppConfig.UserDefaultsConfig.coupleId), !coupleId.isEmpty else { return }
        
        var disposeBag = DisposeBag()
        
        FirestoreManager.shared.readFromFirestore(type: .couple(id: nil))
            .subscribe(onSuccess: { query in
                if query.isEmpty {
                    debugPrint("🚨 커플 데이터 없음")
                    disposeBag = DisposeBag()
                }
                
                guard let id = query.first?.data()[AppConfig.CouplesModel.user2Id] as? String else {
                    debugPrint("🚨 커플 미등록 상태")
                    return
                }
                
                if !id.isEmpty {
                    debugPrint("✅ 커플 등록 완료")
                    UserDefaults.standard.set(true, forKey: AppConfig.UserDefaultsConfig.login)
                    UserDefaults.standard.set(false, forKey: AppConfig.UserDefaultsConfig.ready)
                } else {
                    debugPrint("🚨 커플 미등록 상태")
                }
                
                disposeBag = DisposeBag()
                
            }, onFailure: { error in
                debugPrint("🚨 커플 데이터 확인 실패", error.localizedDescription)
                disposeBag = DisposeBag()
            })
            .disposed(by: disposeBag)
    }
}

enum RootViews {
    case main, login, start
}
