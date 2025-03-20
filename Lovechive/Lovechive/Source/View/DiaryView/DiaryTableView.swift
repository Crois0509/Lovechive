//
//  DiaryTableView.swift
//  Lovechive
//
//  Created by 장상경 on 3/20/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class DiaryTableView: UIView {
    
    private(set) var tableView = UITableView(frame: .zero, style: .plain)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UI Setting Method

private extension DiaryTableView {
    
    func setupUI() {
        setupTableView()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .clear
        addSubview(tableView)
    }
    
    func setupLayout() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = 40
        tableView.sectionHeaderHeight = 40
        tableView.sectionHeaderTopPadding = 16
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.register(DiaryTableCell.self, forCellReuseIdentifier: AppConfig.DiaryConfig.tableCellId)
    }
    
}
