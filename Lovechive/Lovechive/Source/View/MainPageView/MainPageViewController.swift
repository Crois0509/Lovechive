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
    private let dDayView = DDayView()
    private let planerView = PlanView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        [logoView, dDayView, planerView].forEach {
            view.addSubview($0)
        }
    }

    func setupLayout() {
        logoView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(40)
        }
        
        dDayView.snp.makeConstraints {
            $0.top.equalTo(logoView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(120)
        }
        
        planerView.snp.makeConstraints {
            $0.top.equalTo(dDayView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(250)
        }
    }
    
    func bind() {
        let input = MainPageViewModel.Input(fetchTrigger: fetchTrigger)
        
        let output = viewModel.transform(input: input)
        
        output.sections
            .bind(to: planerView.planView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}
