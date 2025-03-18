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

final class MyPageView: UIView {
    
    private let titleView = UILabel()
    fileprivate let editButton = UIButton()
    
    private let firstSection = MyPageSectionView(title: "이름", content: "김남주")
    private let secondSection = MyPageSectionView(title: "연인", content: "김여주")
    private let thirdSection = MyPageSectionView(title: "생년월일", content: "2000.01.01")
    private let forthSection = MyPageSectionView(title: "연애 기념일", content: "2024.01.29")
    
    private let sectionStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureMyPage(_ data: MyPageDataModel) {
        firstSection.configureSection(data.name)
        secondSection.configureSection(data.lover)
        thirdSection.configureSection(data.birthDay.formattedDateToString(.yearMonthDay))
        forthSection.configureSection(data.anniversary.formattedDateToString(.yearMonthDay))
    }
}

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
        titleView.text = "내 정보"
        titleView.font = .systemFont(ofSize: 16, weight: .bold)
        titleView.textColor = .Personal.highlightPink
        titleView.numberOfLines = 1
        titleView.textAlignment = .left
        titleView.backgroundColor = .clear
    }
    
    func setupButton() {
        editButton.setTitle("편집", for: .normal)
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

extension Reactive where Base: MyPageView {
    var editButtonTapped: ControlEvent<Void> {
        base.editButton.rx.tap
    }
}
