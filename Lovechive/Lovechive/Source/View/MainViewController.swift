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
    private let logoView = LogoView()
    private let backgroundView = UIView()
    private var currentPageViewController = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)

    // MARK: - VC LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "정렬 방법") == nil {
            defaults.set("List", forKey: "정렬 방법")
        }
        
        if defaults.object(forKey: "정렬 순서") == nil {
            defaults.set("최신순", forKey: "정렬 순서")
        }
        
        if defaults.bool(forKey: AppConfig.UserDefaultsConfig.ready) {
            Task {
                await AppHelpers.checkCoupleData()
            }
        }
        
        let authOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { res, error in
            DispatchQueue.main.async {
                UserDefaultsManager().saveToUserDefaults(res, forKey: "isNotificationEnabled")
            }
        }
        
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
        setupChildViewController()
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
    func setupChildViewController() {
        addChild(currentPageViewController)
        view.addSubview(currentPageViewController.view)
        
        currentPageViewController.view.snp.makeConstraints {
            $0.top.equalTo(logoView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(tabBarView.snp.top)
        }
        
        currentPageViewController.didMove(toParent: self)
        view.bringSubviewToFront(tabBarView)
        view.bringSubviewToFront(logoView)
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
                                        forthButtonTapped: tabBarView.rx.forthButtonTapped,
                                        calendarDataRelay: currentPageViewController.rx.calendarDataRelay,
                                        diaryDataRelay: currentPageViewController.rx.diaryDataRelay,
                                        settingDataRelay: currentPageViewController.rx.settingDataRelay
        )
        
        let output = viewModel.transform(input: input)
        
        // 버튼을 눌렀을 때 해당 페이지로 이동하는 이벤트
        output.changedCurretPage
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] state in
                self?.currentPageViewController.changePage(to: state, {
                    self?.tabBarView.changeButtonState(state: state)
                })
            }.disposed(by: disposeBag)
        
        output.updateMainPage
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, _ in
                owner.currentPageViewController.mainPageFetch()
            }
            .disposed(by: disposeBag)
    }
}
