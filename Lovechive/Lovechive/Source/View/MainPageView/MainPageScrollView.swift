//
//  MainPageScrollView.swift
//  Lovechive
//
//  Created by 장상경 on 3/10/25.
//

import UIKit
import SnapKit

final class MainPageScrollView: UIView {
    
    private let dDayView = DDayView()
    private(set) var planerView = PlanView()
    private(set) var diaryView = LatestDiaryView()
    
    private let contentView = UIView()
    private let contentsScrollView = UIScrollView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTableViewSize() {
        planerView.planView.layoutIfNeeded()
        let tableHeight = planerView.planView.contentSize.height
        planerView.snp.updateConstraints {
            $0.height.equalTo(tableHeight + 50)
        }
        
    }
}

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
            $0.height.equalTo(50)
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

}
