//
//  SetTableViewCell.swift
//  TripLog
//
//  Created by 장상경 on 1/23/25.
//

import UIKit
import SnapKit

/// 설정 탭의 테이블뷰 셀 UI
final class SetTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    
    private let title = UILabel()
    
    private(set) var extraView: UIView?
    
    // Cell Selected Action
    private(set) var action: (() -> Void)?
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 셀 재사용 옵션
    override func prepareForReuse() {
        super.prepareForReuse()
        
        reusedCell()
    }
    
    /// 셀의 UI를 설정하는 메소드
    /// - Parameter model: 셀 모델 데이터
    func configureCell(model: SettingTableCellModel) {
        self.title.text = model.title
        self.extraView = model.extraView
        self.action = model.action
        
        setupUI()
    }
    
}

// MARK: - UI Setting Method

private extension SetTableViewCell {
    
    func setupUI() {
        setupLabel()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        if self.extraView != nil {
            [title, extraView!].forEach { self.addSubview($0) }
        } else {
            [title].forEach { self.addSubview($0) }
        }
    }
   
    func setupLayout() {
        title.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        extraView?.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(2)
        }
        
    }
    
    func setupLabel() {
        title.font = .systemFont(ofSize: 16, weight: .regular)
        title.numberOfLines = 1
        title.textColor = .Gray.naturalBlack
        title.textAlignment = .left
        title.backgroundColor = .clear
    }
    
    /// 셀 재사용시 수행할 메소드
    func reusedCell() {
        self.title.text = nil
        self.extraView = nil
        self.action = nil
    }
    
}

