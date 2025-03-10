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

final class MainPageViewController: UIViewController {
    
    private var disposeBag = DisposeBag()
    private let fetchTrigger = PublishRelay<Void>()
    
    private let viewModel = MainPageViewModel()
    
    private let logoView = LogoView()
    private let contentsView = MainPageScrollView()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        fetchTrigger.accept(())
    }

}

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
    
    func bind() {
        let input = MainPageViewModel.Input(fetchTrigger: fetchTrigger)
        
        let output = viewModel.transform(input: input)
        
        output.sections
            .bind(to: contentsView.planerView.planView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.sections
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, _ in
                owner.contentsView.updateTableViewSize()
            }.disposed(by: disposeBag)
        
        output.latestDiaryRelay
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, data in
                owner.contentsView.diaryView.configureView(content: data.content, date: data.createdAt, image: data.image)
            }.disposed(by: disposeBag)
        
        output.dDayRelay
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, data in
                owner.contentsView.dDayView.configureDDayView(data.dDay)
            }.disposed(by: disposeBag)
    }
}
