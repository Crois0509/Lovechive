//
//  ScheduleView.swift
//  Lovechive
//
//  Created by 장상경 on 3/11/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

/// 캘린더 스케줄 뷰
final class ScheduleView: UIView {
    
    // MARK: - UI Components
    
    private let titleView = UILabel()
    fileprivate let addButton = UIButton()
    private let infoLabel = UILabel()
    private(set) var scheduleTableView = UITableView()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 타이틀을 설정하는 메소드
    /// - Parameter date: 타이틀로 설정할 날짜 데이터
    func configureTitleDate(_ date: Date) {
        titleView.text = date.formattedDateToString(.monthDay)
    }
    
    /// 스케줄뷰의 사이즈를 업데이트 하는 메소드
    /// - Parameter isEmpty: 섹션 아이템의 존재 여부
    func updateTableViewSize(_ isEmpty: Bool) {
        if isEmpty {
            infoLabel.isHidden = false
            scheduleTableView.isHidden = true
            scheduleTableView.snp.updateConstraints {
                $0.height.equalTo(28)
            }
        } else {
            infoLabel.isHidden = true
            scheduleTableView.isHidden = false
            scheduleTableView.layoutIfNeeded()
            scheduleTableView.snp.updateConstraints {
                $0.height.equalTo(scheduleTableView.contentSize.height)
            }
        }
    }
}

// MARK: - UI Setting Method

private extension ScheduleView {
    
    func setupUI() {
        setupTitle()
        setupInfoLabel()
        setupButton()
        setupTableView()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .white
        layer.cornerRadius = 16
        [titleView, addButton, infoLabel, scheduleTableView].forEach {
            addSubview($0)
        }
    }
    
    func setupLayout() {
        titleView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(16)
            $0.width.equalTo(200).priority(.high)
            $0.height.equalTo(28)
        }
        
        addButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(16)
            $0.width.height.equalTo(28)
        }
        
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(28)
        }
        
        scheduleTableView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(28)
            $0.bottom.equalToSuperview().inset(16)
        }
    }
    
    func setupTitle() {
        titleView.text = AppConfig.CalendarViewConfig.title
        titleView.textColor = .Personal.highlightPink
        titleView.font = .systemFont(ofSize: 16, weight: .bold)
        titleView.numberOfLines = 1
        titleView.textAlignment = .left
        titleView.backgroundColor = .clear
    }
    
    func setupInfoLabel() {
        infoLabel.text = AppConfig.CalendarViewConfig.info
        infoLabel.textColor = .Gray.unSelected
        infoLabel.font = .systemFont(ofSize: 14, weight: .regular)
        infoLabel.numberOfLines = 1
        infoLabel.textAlignment = .left
        infoLabel.backgroundColor = .clear
    }
    
    func setupButton() {
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.tintColor = .Personal.highlightPink
        addButton.backgroundColor = .clear
    }
    
    func setupTableView() {
        scheduleTableView.rowHeight = 36 // 기본 높이 설정
        scheduleTableView.backgroundColor = .clear
        scheduleTableView.separatorStyle = .none
        scheduleTableView.isScrollEnabled = false
        scheduleTableView.showsVerticalScrollIndicator = false
        scheduleTableView.showsHorizontalScrollIndicator = false
        scheduleTableView.register(ScheduleViewCell.self, forCellReuseIdentifier: AppConfig.CalendarViewConfig.cellId)
    }
    
}

// MARK: - Reactive Extension

extension Reactive where Base: ScheduleView {
    /// 만들기 버튼의 탭 이벤트를 방출하는 옵저버블
    var addButtonTapped: ControlEvent<Void> {
        base.addButton.rx.tap
    }
}
