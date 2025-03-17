//
//  CalendarView.swift
//  Lovechive
//
//  Created by 장상경 on 3/11/25.
//

import UIKit
import FSCalendar
import SnapKit
import RxSwift
import RxCocoa

/// 캘린더 뷰
final class CalendarView: UIView {
    
    // MARK: - Properties
    
    private var eventDates: [Date] = []
    
    // MARK: - Rx Properties
    
    fileprivate let selectedDate = BehaviorRelay<Date>(value: Date())
    
    // MARK: - UI Components
    
    private let calendar = FSCalendar()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 이벤트를 설정하는 메소드
    /// - Parameter events: 이벤트가 담긴 Date 배열
    func setupEvents(_ events: [Date]) {
        eventDates = events
        calendar.reloadData()
    }
    
    /// 현재 캘린더의 페이지를 변경하는 메소드
    /// - Parameter date: 변경할 날짜
    func changeCurrentPage(_ date: Date) {
        calendar.scrollEnabled = true
        calendar.setCurrentPage(date, animated: true)
        calendar.select(date)
        selectedDate.accept(date)
        calendar.scrollEnabled = false
    }
}

// MARK: - UI Setting Method

private extension CalendarView {
    
    func setupUI() {
        setupCalendar()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .white
        clipsToBounds = true
        layer.cornerRadius = 16
        addSubview(calendar)
    }
    
    func setupLayout() {
        calendar.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
    }
    
    func setupCalendar() {
        calendar.backgroundColor = .clear
        calendar.setCurrentPage(Date(), animated: false)
        calendar.firstWeekday = 1
        calendar.select(Date())
        calendar.allowsMultipleSelection = false
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.formatter.timeZone = TimeZone(identifier: "Asiz/Seoul")
        calendar.placeholderType = .fillHeadTail
        calendar.scrollEnabled = false
        calendar.headerHeight = 0
        calendar.appearance.headerMinimumDissolvedAlpha = 0
        calendar.rowHeight = 48
        calendar.weekdayHeight = 48
        calendar.delegate = self
        calendar.dataSource = self
        
        calendar.appearance.weekdayFont = .myoyaFont(20)
        calendar.appearance.weekdayTextColor = .Personal.deepPink
        
        calendar.appearance.titleFont = .myoyaFont(16)
        calendar.appearance.titleDefaultColor = .Personal.highlightPink
        calendar.appearance.titleTodayColor = .Personal.lightPink
        
        calendar.appearance.selectionColor = .Personal.highlightPink
        calendar.appearance.borderRadius = 0.5
        
        calendar.appearance.todayColor = .clear
        calendar.appearance.todaySelectionColor = .Personal.highlightPink
        
        calendar.appearance.eventDefaultColor = .Personal.pointPink
        calendar.appearance.eventSelectionColor = .Personal.pointPink
    }
    
}

// MARK: - FSCalendarDelegate Method

extension CalendarView: FSCalendarDelegate {
    // 특정 날짜를 선택했을 때 발생하는 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate.accept(date)
    }
}

// MARK: - FSCalendarDataSource Method

extension CalendarView: FSCalendarDataSource {
    // 이벤트 UI를 설정하는 메소드
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let events = eventDates.filter { Calendar.current.isDate($0, equalTo: date, toGranularity: .day) }
        
        return events.isEmpty ? 0 : min(3, events.count)
    }
}

// MARK: - Reactive Extension

extension Reactive where Base: CalendarView {
    /// 특정 날짜를 선택했을 때 날짜에 대한 이벤트를 방출하는 옵저버블
    var selectedDate: BehaviorRelay<Date> {
        base.selectedDate
    }
}
