//
//  MyPageView.swift
//  Lovechive
//
//  Created by 장상경 on 3/17/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

/// 마이 페이지 뷰
final class MyPageView: UIView {
    
    // MARK: -  UI Components
    
    private let titleView = UILabel()
    fileprivate let editButton = UIButton()
    
    private let firstSection = MyPageSectionView(title: AppConfig.SettingConfig.nameT, content: AppConfig.SettingConfig.name)
    private let secondSection = MyPageSectionView(title: AppConfig.SettingConfig.loverT, content: AppConfig.SettingConfig.lover)
    private let thirdSection = MyPageSectionView(title: AppConfig.SettingConfig.birth, content: AppConfig.SettingConfig.birthD)
    private let forthSection = MyPageSectionView(title: AppConfig.SettingConfig.anni, content: AppConfig.SettingConfig.anniV)
    
    private let sectionStackView = UIStackView()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 마이 페이지를 설정하는 메소드
    /// - Parameter data: 마이 페이지 데이터
    func configureMyPage(_ data: MyPageDataModel) {
        firstSection.configureSection(data.name)
        secondSection.configureSection(data.lover)
        thirdSection.configureSection(data.birthDay.formattedDateToString(.yearMonthDay))
        forthSection.configureSection(data.anniversary.formattedDateToString(.yearMonthDay))
    }
}

// MARK: - UI Setting Method

private extension MyPageView {
    
    func setupUI() {
        setupLabel()
        setupButton()
        setupStackView()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .white
        layer.cornerRadius = 16
        [titleView, editButton, sectionStackView].forEach {
            addSubview($0)
        }
    }
    
    func setupLayout() {
        titleView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(16)
            $0.height.equalTo(24)
        }
        
        editButton.snp.makeConstraints {
            $0.centerY.equalTo(titleView)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.height.equalTo(24)
        }
        
        sectionStackView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(16)
            $0.bottom.horizontalEdges.equalToSuperview().inset(16)
        }
    }
    
    func setupLabel() {
        titleView.text = AppConfig.SettingConfig.myInfo
        titleView.font = .systemFont(ofSize: 16, weight: .bold)
        titleView.textColor = .Personal.highlightPink
        titleView.numberOfLines = 1
        titleView.textAlignment = .left
        titleView.backgroundColor = .clear
    }
    
    func setupButton() {
        editButton.setTitle(AppConfig.SettingConfig.edit, for: .normal)
        editButton.setTitleColor(.Personal.highlightPink, for: .normal)
        editButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        editButton.backgroundColor = .clear
    }
    
    func setupStackView() {
        sectionStackView.axis = .vertical
        sectionStackView.spacing = 8
        sectionStackView.alignment = .fill
        sectionStackView.distribution = .fillEqually
        [firstSection, secondSection, thirdSection, forthSection].forEach {
            sectionStackView.addArrangedSubview($0)
        }
    }
    
}

// MARK: - Reactive Extension

extension Reactive where Base: MyPageView {
    /// 편집 버튼의 탭 이벤트를 방출하는 옵저버블
    var editButtonTapped: ControlEvent<Void> {
        base.editButton.rx.tap
    }
}
