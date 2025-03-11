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

final class CalendarView: UIView {
    
    private var eventDates: [Date] = []
    
    fileprivate let selectedDate = BehaviorRelay<Date>(value: Date())
    
    private let calendar = FSCalendar()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupEvents(_ events: [Date]) {
        eventDates = events
        calendar.reloadData()
    }
    
    func changeCurrentPage(_ date: Date) {
        calendar.scrollEnabled = true
        calendar.setCurrentPage(date, animated: true)
        calendar.scrollEnabled = false
    }
}

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

extension CalendarView: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate.accept(date)
    }
}

extension CalendarView: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let events = eventDates.filter { Calendar.current.isDate($0, equalTo: date, toGranularity: .day) }
        
        return events.isEmpty ? 0 : min(3, events.count)
    }
}

extension Reactive where Base: CalendarView {
    var selectedDate: BehaviorRelay<Date> {
        base.selectedDate
    }
}
