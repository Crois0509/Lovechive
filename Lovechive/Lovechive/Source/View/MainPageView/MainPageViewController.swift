//
//  MainPageViewController.swift
//  Lovechive
//
//  Created by 장상경 on 3/9/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

/// 메인 페이지를 관리하는 ViewController
final class MainPageViewController: UIViewController {
    
    // MARK: - Rx Properties
    
    private var disposeBag = DisposeBag()
    private let fetchTrigger = PublishRelay<Void>()
    
    private let viewModel = MainPageViewModel()
    
    // MARK: - UI Components
    
    private let logoView = LogoView()
    private let contentsView = MainPageScrollView()
        
    // MARK: - VC LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        fetchTrigger.accept(())
    }

}

// MARK: - UI Setting Method

private extension MainPageViewController {
    
    func setupUI() {
        configureSelf()
        setupLayout()
        bind()
    }
    
    func configureSelf() {
        view.backgroundColor = .Personal.backgroundPink
        [logoView, contentsView].forEach {
            view.addSubview($0)
        }
    }

    func setupLayout() {
        logoView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(40)
        }
        
        contentsView.snp.makeConstraints {
            $0.top.equalTo(logoView.snp.bottom).offset(16)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
    }
    
    /// 데이터 바인딩 메소드
    func bind() {
        let input = MainPageViewModel.Input(fetchTrigger: fetchTrigger)
        
        let output = viewModel.transform(input: input)
        
        // 플래너뷰 데이터소스 연동
        output.sections
            .bind(to: contentsView.planerView.planView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        // 플래너뷰 동적 사이즈 조절
        output.sections
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, _ in
                owner.contentsView.updateTableViewData()
            }.disposed(by: disposeBag)
        
        // 최근 작성한 일기 업데이트
        output.latestDiaryRelay
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, data in
                owner.contentsView.diaryView.configureView(content: data.content, date: data.createdAt, image: data.image)
            }.disposed(by: disposeBag)
        
        // D-Day 업데이트
        output.dDayRelay
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, data in
                owner.contentsView.dDayView.configureDDayView(data.dDay)
            }.disposed(by: disposeBag)
    }
}
