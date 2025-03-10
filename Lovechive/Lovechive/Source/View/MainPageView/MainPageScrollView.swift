//
//  MainPageScrollView.swift
//  Lovechive
//
//  Created by 장상경 on 3/10/25.
//

import UIKit
import SnapKit

/// 메인 페이지의 뷰들을 담아두는 스크롤 뷰
final class MainPageScrollView: UIView {
        
    // MARK: - UI Components
    
    private(set) var dDayView = DDayView()
    private(set) var planerView = PlanView()
    private(set) var diaryView = LatestDiaryView()
    
    private let contentView = UIView()
    private let contentsScrollView = UIScrollView()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 0.5초 후 테이블뷰의 높이를 업데이트 하는 메소드
    func updateTableViewData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateTableViewSize()
        }
    }
    
}

// MARK: - UI Setting Method

private extension MainPageScrollView {
    
    func setupUI() {
        configureSelf()
        setupScrollView()
        setupContentView()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .clear
        addSubview(contentsScrollView)
    }
    
    func setupLayout() {
        contentsScrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        dDayView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(120)
        }
        
        planerView.snp.makeConstraints {
            $0.top.equalTo(dDayView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(100)
        }
        
        diaryView.snp.makeConstraints {
            $0.top.equalTo(planerView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(148)
        }
    }
    
    func setupContentView() {
        contentView.backgroundColor = .clear
        [dDayView, planerView, diaryView].forEach {
            contentView.addSubview($0)
        }
    }
    
    func setupScrollView() {
        contentsScrollView.backgroundColor = .clear
        contentsScrollView.showsVerticalScrollIndicator = false
        contentsScrollView.showsHorizontalScrollIndicator = false
        contentsScrollView.alwaysBounceVertical = true
        contentsScrollView.contentInset.bottom = 50
        contentsScrollView.layoutMargins = .zero
        contentsScrollView.addSubview(contentView)
    }
    
    /// 테이블 뷰의 사이즈를 업데이트 하는 메소드
    func updateTableViewSize() {
        planerView.planView.layoutIfNeeded()
        let tableHeight = planerView.planView.contentSize.height
        
        if tableHeight == 0 {
            planerView.tableViewIsNoItem(true)
        } else {
            planerView.tableViewIsNoItem(false)
            planerView.snp.updateConstraints {
                $0.height.equalTo(tableHeight + 50)
            }
        }
    }

}
