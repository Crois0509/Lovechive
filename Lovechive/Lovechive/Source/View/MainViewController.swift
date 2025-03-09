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

class MainViewController: UIViewController {
    
    private let viewModel = MainViewModel()
    private var disposeBag = DisposeBag()
    
    private let tabBarView = TabBarView()
    private let currentPageViewController = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }

}

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
    
    func bind() {
        let input = MainViewModel.Input(firstButtonTapped: tabBarView.rx.firstButtonTapped,
                                        secondButtonTapped: tabBarView.rx.secondButtonTapped,
                                        thirdButtonTapped: tabBarView.rx.thirdButtonTapped,
                                        forthButtonTapped: tabBarView.rx.forthButtonTapped,
                                        changedPage: currentPageViewController.rx.currentPage)
        
        let output = viewModel.transform(input: input)
        
        output.changedCurretPage
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] state in
                self?.tabBarView.changeButtonState(state: state)
                self?.currentPageViewController.changePage(to: state)
            }.disposed(by: disposeBag)
        
        output.scrollToPage
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] state in
                self?.tabBarView.changeButtonState(state: state)
            }.disposed(by: disposeBag)
    }
}
