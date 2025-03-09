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
    private let planView = UITableView()
    
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
            $0.width.equalTo(100).priority(.low)
        }
        
        calendarImageView.snp.makeConstraints {
            $0.centerY.equalTo(titleView)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.height.equalTo(20).priority(.high)
        }
        
        planView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(16)
            $0.bottom.horizontalEdges.equalToSuperview().inset(16)
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
        planView.rowHeight = 48
        planView.backgroundColor = .clear
        planView.separatorStyle = .none
        planView.showsVerticalScrollIndicator = false
        planView.showsHorizontalScrollIndicator = false
        planView.dequeueReusableCell(withIdentifier: PlanViewCell.id)
    }
    
}
