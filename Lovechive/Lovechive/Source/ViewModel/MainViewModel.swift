//
//  MainViewModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/9/25.
//

import UIKit
import RxSwift
import RxCocoa

/// 메인 뷰 컨트롤러의 비즈니스 로직을 담당하는 뷰 모델
final class MainViewModel: ViewModelType {
    
    // MARK: - Input & Output Type
    
    struct Input {
        let firstButtonTapped: ControlEvent<Void>
        let secondButtonTapped: ControlEvent<Void>
        let thirdButtonTapped: ControlEvent<Void>
        let forthButtonTapped: ControlEvent<Void>
        let calendarDataRelay: PublishRelay<Void>
        let diaryDataRelay: PublishRelay<Void>
        let settingDataRelay: PublishRelay<Void>
    }
    
    struct Output {
        let changedCurretPage: PublishRelay<TabBarButtonState>
        let updateMainPage: PublishRelay<Void>
    }
    
    // MARK: - Properties
    
    private var disposeBag = DisposeBag()
    
    private let changedCurretPage = PublishRelay<TabBarButtonState>()
    private let updateMainPage = PublishRelay<Void>()
    
    /// input을 output으로 변환하는 메소드
    /// - Parameter input: input 데이터
    /// - Returns: output 데이터
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
        
        input.calendarDataRelay
            .skip(1)
            .bind(to: updateMainPage)
            .disposed(by: disposeBag)
        
        input.diaryDataRelay
            .skip(1)
            .bind(to: updateMainPage)
            .disposed(by: disposeBag)
        
        input.settingDataRelay
            .skip(1)
            .bind(to: updateMainPage)
            .disposed(by: disposeBag)
        
        return Output(changedCurretPage: changedCurretPage,
                      updateMainPage: updateMainPage
        )
    }
}
