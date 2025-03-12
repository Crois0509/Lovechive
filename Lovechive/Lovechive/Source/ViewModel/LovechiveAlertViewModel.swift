//
//  LovechiveAlertViewModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/12/25.
//

import UIKit
import RxSwift
import RxCocoa

final class LovechiveAlertViewModel: ViewModelType {
    
    private var disposeBag = DisposeBag()
    
    struct Input {
        let cancelButtonTapped: ControlEvent<Void>
        let activeButtonTapped: ControlEvent<Void>
//        let scheduleTimeRelay: BehaviorRelay<Date>
//        let scheduleTitleRelay: BehaviorRelay<String>
    }
    
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        
        input.cancelButtonTapped
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, _ in
                owner.dismissAlertView()
            }
            .disposed(by: disposeBag)
        
        return Output()
    }
    
    private func dismissAlertView() {
        guard let topView = AppHelpers.getTopViewController() as? MainViewController,
              let alert = topView.children.last as? LovechiveAlertViewController
        else { return }
        
        alert.dismissSelf {
            alert.view.snp.removeConstraints()
            alert.view.removeFromSuperview()
            alert.removeFromParent()
        }
    }
}
