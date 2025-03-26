//
//  SettingView.swift
//  TripLog
//
//  Created by 장상경 on 1/23/25.
//

import UIKit
import SnapKit

/// 설정 탭의 설정 뷰
final class SettingView: UIView {
        
    // MARK: - UI Components
    
    private(set) var tableView = UITableView()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTableViewSize() {
        tableView.layoutIfNeeded()
        tableView.snp.updateConstraints {
            $0.height.equalTo(tableView.contentSize.height)
        }
    }
    
}

// MARK: - UI Setting Method

private extension SettingView {
    
    func setupUI() {
        setupTableView()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .white
        layer.cornerRadius = 16
        addSubview(tableView)
    }
    
    func setupLayout() {
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(40)
            $0.bottom.equalToSuperview().inset(16)
        }
    }
    
    func setupTableView() {
        tableView.separatorStyle = .none
        tableView.rowHeight = 40
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.isScrollEnabled = false
        tableView.register(SetTableViewCell.self, forCellReuseIdentifier: AppConfig.SettingConfig.cellId)
    }
}
