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
    fileprivate let dataRelay = PublishRelay<Void>()
    
    // MARK: - Properties
    
    private let viewModel = CalendarViewModel()
    
    // MARK: - UI Components
    
    private let headerView = CalendarHeaderView()
    private let calendarView = CalendarView()
    private let scheduleView = ScheduleView()
    
    private let containerView = UIView()
    private let scrollView = UIScrollView()
    
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
        setupScrollView()
        setupContainerView()
        configureSelf()
        setupLayout()
        bind()
    }
    
    func configureSelf() {
        view.backgroundColor = .Personal.backgroundPink
        view.addSubview(scrollView)
    }
    
    func setupLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.greaterThanOrEqualTo(500)
        }
        
        headerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(60)
        }
        
        calendarView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(336).priority(.high)
        }
        
        scheduleView.snp.makeConstraints {
            $0.top.equalTo(calendarView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.greaterThanOrEqualTo(92)
            $0.bottom.equalToSuperview()
        }
    }
    
    func setupContainerView() {
        containerView.backgroundColor = .clear
        [headerView, calendarView, scheduleView].forEach {
            containerView.addSubview($0)
        }
    }
    
    func setupScrollView() {
        scrollView.contentInset.bottom = 16
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.addSubview(containerView)
    }
    
    func bind() {
        let input = CalendarViewModel.Input(fetchTrigger: fetchTrigger,
                                            previousButtonTapped: headerView.rx.previousButtonTapped,
                                            nextButtonTapped: headerView.rx.nextButtonTapped,
                                            addButtonTapped: scheduleView.rx.addButtonTapped,
                                            selectedDate: calendarView.rx.selectedDate,
                                            tableViewItemDeleted: scheduleView.scheduleTableView.rx.itemDeleted,
                                            tableViewItemEdited: scheduleView.scheduleTableView.rx.itemSelected,
                                            containerViewHeight: containerView.rx.boundsHeight
        )
        
        let output: CalendarViewModel.Output
        
        if UserDefaults.standard.bool(forKey: AppConfig.UserDefaultsConfig.guestMode) == true {
            output = viewModel.transformToGuestMode(input: input)
        } else {
            output = viewModel.transform(input: input)
        }
        
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
            }
            .disposed(by: disposeBag)
        
        output.scrollViewHeight
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, height in
                owner.scrollView.contentSize.height = height
            }
            .disposed(by: disposeBag)
        
        output.editDataRelay
            .filter { $0 }
            .map { _ in () }
            .bind(to: dataRelay)
            .disposed(by: disposeBag)
    }
    
}

// MARK: - Reactive Extension

extension Reactive where Base: CalendarViewController {
    var calendarDataRelay: PublishRelay<Void> {
        base.dataRelay
    }
}
