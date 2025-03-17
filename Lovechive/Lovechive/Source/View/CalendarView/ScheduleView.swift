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

final class ScheduleView: UIView {
    
    private let titleView = UILabel()
    fileprivate let addButton = UIButton()
    private let infoLabel = UILabel()
    private(set) var scheduleTableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureTitleDate(_ date: Date) {
        titleView.text = date.formattedDateToString(.yearMonthDayHourMinute)
    }
    
    func updateTableViewSize(_ isEmpty: Bool) {
        if isEmpty {
            infoLabel.isHidden = false
            scheduleTableView.isHidden = true
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
            $0.bottom.horizontalEdges.equalToSuperview().inset(16)
        }
        
        scheduleTableView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(28)
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

extension Reactive where Base: ScheduleView {
    var addButtonTapped: ControlEvent<Void> {
        base.addButton.rx.tap
    }
}
