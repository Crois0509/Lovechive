//
//  MyPageSectionView.swift
//  Lovechive
//
//  Created by 장상경 on 3/17/25.
//

import UIKit
import SnapKit

/// 내 프로필 섹션 뷰
final class MyPageSectionView: UIView {
    
    // MARK: -  UI Components
    
    private lazy var titleView = createdLabel(AppConfig.SettingConfig.nameT, color: .Personal.highlightPink, alignment: .left)
    private lazy var contentView = createdLabel(AppConfig.SettingConfig.name, color: .Gray.naturalBlack, alignment: .right)
    
    // MARK: - Initializer
    
    init(title: String, content: String) {
        super.init(frame: .zero)
        titleView.text = title
        contentView.text = content
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 섹션뷰를 설정하는 메소드
    /// - Parameter text: 텍스트필드에 입력할 텍스트
    func configureSection(_ text: String) {
        contentView.text = text
    }
    
}

// MARK: - UI Setting Method

private extension MyPageSectionView {
    
    func setupUI() {
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .clear
        [titleView, contentView].forEach { addSubview($0) }
    }
    
    func setupLayout() {
        titleView.snp.makeConstraints {
            $0.leading.verticalEdges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.trailing.verticalEdges.equalToSuperview()
        }
    }
    
    func createdLabel(_ text: String, color: UIColor, alignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = color
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 1
        label.textAlignment = alignment
        
        return label
    }
    
}
