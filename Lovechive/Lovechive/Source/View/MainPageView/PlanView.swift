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

/// 메인 페이지의 일정을 표현하는 UIView
final class PlanView: UIView {
    
    // MARK: - UI Components
    
    private let titleView = UILabel()
    private let calendarImageView = UIImageView()
    private let infoView = UILabel()
    private(set) var planView = UITableView()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 테이블뷰에 아이템이 없는지 확인하고, 정보 레이블의 표시를 결정하는 메소드
    /// - Parameter value: 테이블뷰에 아이템이 없는지 확인(Bool)
    func tableViewIsNoItem(_ value: Bool) {
        infoView.isHidden = !value
    }
}

// MARK: - UI Setting Method

private extension PlanView {
    
    func setupUI() {
        setupInfoView()
        setupTableView()
        setupTitleView()
        setupImageView()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .white
        layer.cornerRadius = 16
        [titleView, calendarImageView, infoView, planView].forEach {
            addSubview($0)
        }
    }
    
    func setupLayout() {
        titleView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().inset(16)
            $0.width.equalTo(100)
            $0.height.equalTo(24)
        }
        
        calendarImageView.snp.makeConstraints {
            $0.centerY.equalTo(titleView)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.height.equalTo(20)
        }
        
        infoView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(8)
        }
        
        planView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(8)
        }
    }
    
    func setupTitleView() {
        titleView.text = AppConfig.PlanerView.title
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
    
    func setupInfoView() {
        infoView.text = AppConfig.PlanerView.info
        infoView.font = .systemFont(ofSize: 14, weight: .regular)
        infoView.textColor = .Gray.unSelected
        infoView.numberOfLines = 1
        infoView.textAlignment = .left
    }
    
    func setupTableView() {
        planView.rowHeight = 64 // 기본 높이 설정
        planView.backgroundColor = .clear
        planView.separatorStyle = .none
        planView.isScrollEnabled = false
        planView.showsVerticalScrollIndicator = false
        planView.showsHorizontalScrollIndicator = false
        planView.register(PlanViewCell.self, forCellReuseIdentifier: AppConfig.PlanerView.cellId)
    }
    
}
