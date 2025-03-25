//
//  ViewController.swift
//  Lovechive
//
//  Created by 장상경 on 3/5/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

/// 럽카이브 프로젝트의 메인 뷰 컨트롤러
final class MainViewController: UIViewController {
    
    // MARK: - Rx Properties
    
    private let viewModel = MainViewModel()
    private var disposeBag = DisposeBag()
    
    // MARK: - Properties
    
    private let pages: [UIViewController] = [
        MainPageViewController(),
        CalendarViewController(),
        DiaryListViewController(),
        SettingViewController()
    ]
    
    // MARK: - UI Components
    
    private let tabBarView = TabBarView()
    private let logoView = LogoView()
    private let backgroundView = UIView()
    private var currentPageViewController: UIViewController?

    // MARK: - VC LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }

}

// MARK: - UI Setting Method

private extension MainViewController {
    
    func setupUI() {
        setupBackgroundView()
        configureSelf()
        setupLayout()
        setupChildViewController(0)
        bind()
    }
    
    func configureSelf() {
        navigationItem.title = ""
        view.backgroundColor = .white
        [backgroundView, logoView, tabBarView].forEach {
            view.addSubview($0)
        }
    }
    
    /// 서브 뷰 컨트롤러를 설정하는 메소드
    func setupChildViewController(_ index: Int) {
        if let currentVC = self.currentPageViewController {
            currentVC.view.removeFromSuperview()
            currentVC.removeFromParent()
        }
        
        let selectedVC = pages[index]
        
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve) {
            self.addChild(selectedVC)
            self.view.addSubview(selectedVC.view)
            
            selectedVC.view.snp.makeConstraints {
                $0.top.equalTo(self.logoView.snp.bottom).offset(16)
                $0.horizontalEdges.equalToSuperview()
                $0.bottom.equalTo(self.tabBarView.snp.top)
            }
            
            selectedVC.didMove(toParent: self)
            self.currentPageViewController = selectedVC
            
            self.view.bringSubviewToFront(self.tabBarView)
            self.view.bringSubviewToFront(self.logoView)
        }
    }
    
    func setupLayout() {
        backgroundView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(64)
        }
        
        logoView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        tabBarView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(64)
        }
    }
    
    func setupBackgroundView() {
        backgroundView.backgroundColor = .Personal.backgroundPink
    }
    
    /// 데이터 바인딩 메소드
    func bind() {
        let input = MainViewModel.Input(firstButtonTapped: tabBarView.rx.firstButtonTapped,
                                        secondButtonTapped: tabBarView.rx.secondButtonTapped,
                                        thirdButtonTapped: tabBarView.rx.thirdButtonTapped,
                                        forthButtonTapped: tabBarView.rx.forthButtonTapped
        )
        
        let output = viewModel.transform(input: input)
        
        // 버튼을 눌렀을 때 해당 페이지로 이동하는 이벤트
        output.changedCurretPage
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] state in
                guard let self, let index = TabBarButtonState.allCases.firstIndex(of: state) else { return }
                self.setupChildViewController(index)
                self.tabBarView.changeButtonState(state: state)
            }.disposed(by: disposeBag)
    }
}
