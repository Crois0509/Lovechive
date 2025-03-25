//
//  DiarySettingAlertView.swift
//  Lovechive
//
//  Created by 장상경 on 3/23/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class DiarySettingAlertView: UIView {
    
    private let titleView = UILabel()
    fileprivate let cancelButton = UIButton()
    
    fileprivate let editButton = LabelButton(title: "편집하기")
    fileprivate let deleteButton = LabelButton(title: "삭제하기")
    fileprivate let sortButton = MenuButton(title: "정렬 방법", menus: ["List", "Collection"])
    fileprivate let sortOrderButton = MenuButton(title: "정렬 순서", menus: ["최신순", "오래된순"])
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UI Setting Method

private extension DiarySettingAlertView {
    
    func setupUI() {
        setupTitleView()
        setupCancelButton()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .white
        layer.cornerRadius = 16
        [titleView, cancelButton, editButton, deleteButton, sortButton, sortOrderButton].forEach {
            addSubview($0)
        }
    }
    
    func setupLayout() {
        titleView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().inset(16)
            $0.height.equalTo(30)
        }
        
        cancelButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalTo(titleView)
            $0.width.height.equalTo(20)
        }
        
        editButton.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(24)
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.equalTo(editButton.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(24)
        }
        
        sortButton.snp.makeConstraints {
            $0.top.equalTo(deleteButton.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(24)
        }
        
        sortOrderButton.snp.makeConstraints {
            $0.top.equalTo(sortButton.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(24)
            $0.bottom.equalToSuperview().inset(16)
        }
    }
    
    func setupTitleView() {
        titleView.text = "다이어리 설정"
        titleView.font = .systemFont(ofSize: 16, weight: .bold)
        titleView.textColor = .Gray.naturalBlack
        titleView.numberOfLines = 1
        titleView.textAlignment = .left
        titleView.backgroundColor = .clear
    }
    
    func setupCancelButton() {
        cancelButton.setTitle("X", for: .normal)
        cancelButton.setTitleColor(.Personal.deepPink, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        cancelButton.backgroundColor = .clear
    }
    
}

// MARK: - Reactive Extension

extension Reactive where Base: DiarySettingAlertView {
    var cancelButtonTapped: ControlEvent<Void> {
        base.cancelButton.rx.tap
    }
    
    var editButtonTapped: ControlEvent<Void> {
        base.editButton.rx.tap
    }
    
    var deleteButtonTapped: ControlEvent<Void> {
        base.deleteButton.rx.tap
    }
    
    var changedSortMethod: BehaviorRelay<String> {
        base.sortButton.rx.changedMenu
    }
    
    var changedSortOrder: BehaviorRelay<String> {
        base.sortOrderButton.rx.changedMenu
    }
}
