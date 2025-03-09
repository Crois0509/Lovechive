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
        let changedPage: PublishRelay<Int>
    }
    
    struct Output {
        let changedCurretPage: PublishRelay<TabBarButtonState>
        let scrollToPage: PublishRelay<TabBarButtonState>
    }
    
    private var disposeBag = DisposeBag()
    
    private let changedCurretPage = PublishRelay<TabBarButtonState>()
    private let scrollToPage = PublishRelay<TabBarButtonState>()
    
    func transform(input: Input) -> Output {
        input.firstButtonTapped
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, _ in
                owner.changedCurretPage.accept(.home)
            }.disposed(by: disposeBag)
        
        input.secondButtonTapped
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, _ in
                owner.changedCurretPage.accept(.calendar)
            }.disposed(by: disposeBag)
        
        input.thirdButtonTapped
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, _ in
                owner.changedCurretPage.accept(.diary)
            }.disposed(by: disposeBag)
        
        input.forthButtonTapped
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, _ in
                owner.changedCurretPage.accept(.setting)
            }.disposed(by: disposeBag)
        
        input.changedPage
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, index in
                let state = TabBarButtonState.allCases[index]
                owner.scrollToPage.accept(state)
            }.disposed(by: disposeBag)
        
        return Output(changedCurretPage: changedCurretPage,
                      scrollToPage: scrollToPage)
    }
}
