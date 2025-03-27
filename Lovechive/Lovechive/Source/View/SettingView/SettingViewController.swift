//
//  SettingViewController.swift
//  TripLog
//
//  Created by 장상경 on 1/23/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

/// 설정탭 뷰 컨트롤러
final class SettingViewController: UIViewController {
    
    // MARK: - Rx Properties
    
    private let disposeBag = DisposeBag()
    
    private let fetchTrigger = PublishRelay<Void>()
    fileprivate let dataRelay = PublishRelay<Void>()
    
    // MARK: - Properties
    
    private let viewModel = SettingViewModel()
    
    // MARK: - UI Components
    
    private let myProfile = MyPageView()
    private let settingView = SettingView()
    
    // MARK: - UIViewController LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        fetchTrigger.accept(())
    }
    
}

// MARK: - UI Setting Method

private extension SettingViewController {
    
    func setupUI() {
        configureSelf()
        setupLayout()
        bind()
    }
    
    func configureSelf() {
        view.backgroundColor = .clear
        [myProfile, settingView].forEach {
            view.addSubview($0)
        }
    }
    
    func setupLayout() {
        myProfile.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(172)
        }
        
        settingView.snp.makeConstraints {
            $0.top.equalTo(myProfile.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.greaterThanOrEqualTo(32)
        }
    }
    
    /// 데이터 바인딩 메소드
    func bind() {
        
        let input = SettingViewModel.Input(fetchTrigger: fetchTrigger,
                                           editButtonTapped: myProfile.rx.editButtonTapped)
        
        let output: SettingViewModel.Output
        
        if UserDefaults.standard.bool(forKey: AppConfig.UserDefaultsConfig.guestMode) == true {
            output = viewModel.transformToGuestMode(input: input)
        } else {
            output = viewModel.transform(input: input)
        }
        
        // 설정 뷰 섹션 설정
        output.sections
            .bind(to: settingView.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.sections
            .skip(1)
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, items in
                debugPrint(items.count)
                owner.settingView.updateTableViewSize()
            }
            .disposed(by: disposeBag)
        
        // 마이 페이지 데이터 입력
        output.myPageDataRelay
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, data in
                owner.myProfile.configureMyPage(data)
                owner.dataRelay.accept(())
            }
            .disposed(by: disposeBag)

        
        // 설정뷰 아이템 선택시 이벤트
        settingView.tableView.rx.itemSelected
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, indexPath in
                
                guard
                    let cell = owner.settingView.tableView.cellForRow(at: indexPath) as? SetTableViewCell
                else { return }
                
                cell.action?()
                
            }.disposed(by: disposeBag)
    }
    
}

// MARK: - Reactive Extension

extension Reactive where Base: SettingViewController {
    var settingDataRelay: PublishRelay<Void> {
        base.dataRelay
    }
}
