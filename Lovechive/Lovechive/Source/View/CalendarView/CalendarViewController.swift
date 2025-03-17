//
//  CalendarViewController.swift
//  Lovechive
//
//  Created by 장상경 on 3/11/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

/// 캘린더 뷰 컨트롤러
final class CalendarViewController: UIViewController {
    
    // MARK: - Rx Properties
    
    private var disposeBag = DisposeBag()
    private let fetchTrigger = PublishRelay<Void>()
    
    // MARK: - Properties
    
    private let viewModel = CalendarViewModel()
    
    // MARK: - UI Components
    
    private let headerView = CalendarHeaderView()
    private let calendarView = CalendarView()
    private let scheduleView = ScheduleView()
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        fetchTrigger.accept(())
    }
    
}

// MARK: - UI Setting Method

private extension CalendarViewController {
    
    func setupUI() {
        configureSelf()
        setupLayout()
        bind()
    }
    
    func configureSelf() {
        view.backgroundColor = .Personal.backgroundPink
        [headerView, calendarView, scheduleView].forEach {
            view.addSubview($0)
        }
    }
    
    func setupLayout() {
        headerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(60)
        }
        
        calendarView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(336) // TODO: 스케줄 리스트 뷰 구현 후 수정
        }
        
        scheduleView.snp.makeConstraints {
            $0.top.equalTo(calendarView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(100) // TODO: 동적으로 변하도록 수정
        }
    }
    
    func bind() {
        let input = CalendarViewModel.Input(fetchTrigger: fetchTrigger,
                                            previousButtonTapped: headerView.rx.previousButtonTapped,
                                            nextButtonTapped: headerView.rx.nextButtonTapped,
                                            addButtonTapped: scheduleView.rx.addButtonTapped,
                                            selectedDate: calendarView.rx.selectedDate,
                                            tableViewItemDeleted: scheduleView.scheduleTableView.rx.itemDeleted,
                                            tableViewItemEdited: scheduleView.scheduleTableView.rx.itemSelected
        )
        
        let output = viewModel.transform(input: input)
        
        // 캘린더 이벤트 설정
        output.eventsRelay
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, events in
                owner.calendarView.setupEvents(events)
            }
            .disposed(by: disposeBag)
        
        // 캘린더 페이지 변경
        output.changeCurrentDatePage
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, date in
                owner.calendarView.changeCurrentPage(date)
                owner.headerView.configureHeaderView(date)
                owner.fetchTrigger.accept(())
            }
            .disposed(by: disposeBag)
        
        // 캘린더 스케줄 뷰 타이틀 변경
        output.selectedDate
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, date in
                owner.scheduleView.configureTitleDate(date)
            }
            .disposed(by: disposeBag)
        
        // 캘린더 스케줄 뷰 섹션 변경
        output.scheduleSection
            .bind(to: scheduleView.scheduleTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        // 캘린더 스케줄 뷰 사이즈 변경
        output.scheduleSection
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, data in
                let isEmpty = data.first?.items.isEmpty ?? true
                owner.scheduleView.updateTableViewSize(isEmpty)
                
                if isEmpty {
                    owner.scheduleView.snp.updateConstraints {
                        $0.height.equalTo(100)
                    }
                } else {
                    owner.scheduleView.snp.updateConstraints {
                        $0.height.equalTo(owner.scheduleView.scheduleTableView.contentSize.height + 60)
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
}
