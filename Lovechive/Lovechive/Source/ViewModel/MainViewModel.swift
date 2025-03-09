//
//  MainViewModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/9/25.
//

import UIKit
import RxSwift
import RxCocoa

final class MainViewModel: ViewModelType {
    struct Input {
        let firstButtonTapped: ControlEvent<Void>
        let secondButtonTapped: ControlEvent<Void>
        let thirdButtonTapped: ControlEvent<Void>
        let forthButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        let changeCurretPage: PublishRelay<TabBarButtonState>
    }
    
    private var disposeBag = DisposeBag()
    
    private let changeCurretPage = PublishRelay<TabBarButtonState>()
    
    func transform(input: Input) -> Output {
        input.firstButtonTapped
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, _ in
                owner.changeCurretPage.accept(.home)
            }.disposed(by: disposeBag)
        
        input.secondButtonTapped
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, _ in
                owner.changeCurretPage.accept(.calendar)
            }.disposed(by: disposeBag)
        
        input.thirdButtonTapped
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, _ in
                owner.changeCurretPage.accept(.diary)
            }.disposed(by: disposeBag)
        
        input.forthButtonTapped
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, _ in
                owner.changeCurretPage.accept(.setting)
            }.disposed(by: disposeBag)
        
        return Output(changeCurretPage: changeCurretPage)
    }
}
