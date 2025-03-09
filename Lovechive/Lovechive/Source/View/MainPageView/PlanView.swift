//
//  PlanView.swift
//  Lovechive
//
//  Created by 장상경 on 3/9/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class PlanView: UIView {
    
    private let titleView = UILabel()
    private let calendarImageView = UIImageView()
    let planView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension PlanView {
    
    func setupUI() {
        setupTableView()
        setupTitleView()
        setupImageView()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .white
        layer.cornerRadius = 16
        [titleView, calendarImageView, planView].forEach {
            addSubview($0)
        }
    }
    
    func setupLayout() {
        titleView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().inset(16)
            $0.width.equalTo(100)
        }
        
        calendarImageView.snp.makeConstraints {
            $0.centerY.equalTo(titleView)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.height.equalTo(20)
        }
        
        planView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(8)
        }
    }
    
    func setupTitleView() {
        titleView.text = "다가오는 일정"
        titleView.textColor = .Personal.highlightPink
        titleView.font = .systemFont(ofSize: 16, weight: .bold)
        titleView.numberOfLines = 1
        titleView.textAlignment = .left
    }
    
    func setupImageView() {
        calendarImageView.image = .Icon.planIcon
        calendarImageView.contentMode = .scaleAspectFit
        calendarImageView.backgroundColor = .clear
    }
    
    func setupTableView() {
        planView.rowHeight = 64 // 기본 높이 설정
        planView.backgroundColor = .clear
        planView.separatorStyle = .none
        planView.isScrollEnabled = false
        planView.showsVerticalScrollIndicator = false
        planView.showsHorizontalScrollIndicator = false
        planView.register(PlanViewCell.self, forCellReuseIdentifier: PlanViewCell.id)
    }
    
}
