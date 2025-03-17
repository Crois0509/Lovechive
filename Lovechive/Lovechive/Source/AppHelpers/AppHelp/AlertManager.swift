//
//  AlertManager.swift
//  TripLog
//
//  Created by 장상경 on 1/23/25.
//

import UIKit
import RxSwift

/**
 프로젝트 전역에서 사용할 Alert 객체
 
 - **Example**:
 ```swift
 // 기본적인 Alert 사용 방법
 let alert = AlertManager(title: "알림", message: "저장하시겠습니까?", cancelTitle: "취소")
 
 alert.showAlert(.alert)
 ```
 */
struct AlertManager {
    var title: String
    var message: String
    var cancelTitle: String
    var activeTitle: String?
    var destructiveTitle: String?
    
    // 가장 기본적인 형태의 Alert
    // cancel 버튼만 보유
    // handler 없음
    init(title: String,
         message: String,
         cancelTitle: String
    ) {
        self.title = title
        self.message = message
        self.cancelTitle = cancelTitle
        self.activeTitle = nil
        self.destructiveTitle = nil
    }
    
    // 2개의 선택지를 제공하는 Alert
    // defaults 형태의 버튼 제공
    // handler 있음
    init(title: String,
         message: String,
         cancelTitle: String,
         activeTitle: String?
    ) {
        self.title = title
        self.message = message
        self.cancelTitle = cancelTitle
        self.activeTitle = activeTitle
        self.destructiveTitle = nil
    }
    
    // 2개의 선택지를 제공하는 Alert
    // destructive 형태의 버튼 제공
    // handler 있음
    init(title: String,
         message: String,
         cancelTitle: String,
         destructiveTitle: String?
    ) {
        self.title = title
        self.message = message
        self.cancelTitle = cancelTitle
        self.destructiveTitle = destructiveTitle
        self.activeTitle = nil
    }
    
    /// Alert 을 뷰 컨트롤러에 present 하는 메소드
    /// - Parameters:
    ///   - view: Alert을 present 할 뷰 컨트롤러
    ///   - style: AlertViewController Style
    func showAlert(_ style: UIAlertController.Style) -> Observable<Bool> {
        return Observable.create { observer in
            guard let view = AppHelpers.getTopViewController() else { return Disposables.create() }
            
            let alert = UIAlertController(title: self.title, message: self.message, preferredStyle: style)
            
            alert.addAction(UIAlertAction(title: self.cancelTitle, style: .cancel) { _ in
                observer.onNext(false)
                observer.onCompleted()
            })
            
            if let activeTitle {
                alert.addAction(UIAlertAction(title: activeTitle, style: .default) { [weak view] _ in
                    observer.onNext(true)
                    observer.onCompleted()
                })
            } else if let destructiveTitle {
                alert.addAction(UIAlertAction(title: destructiveTitle, style: .destructive) { [weak view] _ in
                    observer.onNext(true)
                    observer.onCompleted()
                })
            }
            
            DispatchQueue.main.async {
                view.present(alert, animated: true)
            }
            
            return Disposables.create {
                alert.dismiss(animated: true)
            }
        }
    }
    
}


