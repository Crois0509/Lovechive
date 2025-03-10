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
    
    // MARK: - UI Components
    
    private let tabBarView = TabBarView()
    private let currentPageViewController = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)

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
        configureSelf()
        setupLayout()
        setupChildViewController()
        bind()
    }
    
    func configureSelf() {
        view.backgroundColor = .white
        [tabBarView].forEach {
            view.addSubview($0)
        }
    }
    
    /// 서브 뷰 컨트롤러를 설정하는 메소드
    func setupChildViewController() {
        addChild(currentPageViewController)
        view.addSubview(currentPageViewController.view)
        currentPageViewController.view.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(tabBarView.snp.top)
        }
        currentPageViewController.didMove(toParent: self)
        view.bringSubviewToFront(tabBarView)
    }
    
    func setupLayout() {
        tabBarView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(64)
        }
    }
    
    /// 데이터 바인딩 메소드
    func bind() {
        let input = MainViewModel.Input(firstButtonTapped: tabBarView.rx.firstButtonTapped,
                                        secondButtonTapped: tabBarView.rx.secondButtonTapped,
                                        thirdButtonTapped: tabBarView.rx.thirdButtonTapped,
                                        forthButtonTapped: tabBarView.rx.forthButtonTapped,
                                        changedPage: currentPageViewController.rx.currentPage)
        
        let output = viewModel.transform(input: input)
        
        // 버튼을 눌렀을 때 해당 페이지로 이동하는 이벤트
        output.changedCurretPage
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] state in
                self?.tabBarView.changeButtonState(state: state)
                self?.currentPageViewController.changePage(to: state)
            }.disposed(by: disposeBag)
        
        // 페이지를 스와이프 했을 때 해당 페이지로 이동하는 이벤트
        output.scrollToPage
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] state in
                self?.tabBarView.changeButtonState(state: state)
            }.disposed(by: disposeBag)
    }
}
