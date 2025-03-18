//
//  MyPageSectionView.swift
//  Lovechive
//
//  Created by 장상경 on 3/17/25.
//

import UIKit
import SnapKit

final class MyPageSectionView: UIView {
    
    private lazy var titleView = createdLabel("이름", color: .Personal.highlightPink, alignment: .left)
    private lazy var contentView = createdLabel("김남주", color: .Gray.naturalBlack, alignment: .right)
    
    init(title: String, content: String) {
        super.init(frame: .zero)
        titleView.text = title
        contentView.text = content
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSection(_ text: String) {
        contentView.text = text
    }
    
}

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
