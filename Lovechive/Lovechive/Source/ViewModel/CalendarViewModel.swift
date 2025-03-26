//
//  CalendarViewModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/11/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import FirebaseFirestore

/// 캘린더뷰 뷰 모델
final class CalendarViewModel: ViewModelMethodManager, ViewModelType {
    
    // MARK: - Input & Output Type
    
    struct Input {
        let fetchTrigger: PublishRelay<Void>
        let previousButtonTapped: ControlEvent<Void>
        let nextButtonTapped: ControlEvent<Void>
        let addButtonTapped: ControlEvent<Void>
        let selectedDate: BehaviorRelay<Date>
        let tableViewItemDeleted: ControlEvent<IndexPath>
        let tableViewItemEdited: ControlEvent<IndexPath>
        let containerViewHeight: Observable<CGFloat>
    }
    
    struct Output {
        let changeCurrentDatePage: BehaviorRelay<Date>
        let selectedDate: BehaviorRelay<Date>
        let scheduleSection: BehaviorRelay<[ScheduleModelSection]>
        let eventsRelay: BehaviorRelay<[Date]>
        let scrollViewHeight: PublishRelay<CGFloat>
        let editDataRelay: PublishRelay<Bool>
    }
    
    // MARK: - Properties
    
    private var disposeBag = DisposeBag()
    
    private var sections: [ScheduleModelSection] = []
    private var queryDatas: [QueryDocumentSnapshot] = []
    private let confirmAlert = AlertManager(title: "경고", message: "정말 삭제하시겠습니까?", cancelTitle: "취소", destructiveTitle: "삭제")
    
    private let changeCurrentDatePage = BehaviorRelay<Date>(value: Date())
    private let selectedDate = BehaviorRelay<Date>(value: Date())
    private let scheduleSection = BehaviorRelay<[ScheduleModelSection]>(value: [])
    private let eventsRelay = BehaviorRelay<[Date]>(value: [])
    private let scrollViewHeight = PublishRelay<CGFloat>()
    private let editDataRelay = PublishRelay<Bool>()
    
    /// input을 output으로 변환하는 메소드
    /// - Parameter input: input 데이터
    /// - Returns: output 데이터
    func transform(input: Input) -> Output {
        
        input.fetchTrigger
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.fetchData(.schedule(id: ""))
            }
            .map { [weak self] data in
                guard let self else { return [Date]() }
                return self.mappingScheduleDataToEventDates(data)
            }
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] dates in
                self?.eventsRelay.accept(dates)
            }
            .disposed(by: disposeBag)
        
        eventsRelay
            .withUnretained(self)
            .compactMap { owner, data in
                return owner.filteredToDayDateToScheduleSection(owner.eventsRelay.value, owner.queryDatas)
            }
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] datas in
                guard let self else { return }
                self.sections = datas
                self.selectedDate.accept(self.selectedDate.value)
            }
            .disposed(by: disposeBag)
        
        input.previousButtonTapped
            .withUnretained(self)
            .map { owner, _ -> Date in
                let currentDate = owner.changeCurrentDatePage.value
                let previousDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
                return previousDate
            }
            .asObservable()
            .bind(to: changeCurrentDatePage)
            .disposed(by: disposeBag)
        
        input.nextButtonTapped
            .withUnretained(self)
            .map { owner, _ -> Date in
                let currentDate = owner.changeCurrentDatePage.value
                let nextDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                return nextDate
            }
            .asObservable()
            .bind(to: changeCurrentDatePage)
            .disposed(by: disposeBag)
        
        input.selectedDate
            .bind(to: selectedDate)
            .disposed(by: disposeBag)
        
        selectedDate
            .withUnretained(self)
            .map { owner, date in
                let data = owner.filteredSection(date)
                
                return [data]
            }
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] data in
                self?.scheduleSection.accept(data)
            }
            .disposed(by: disposeBag)
        
        input.addButtonTapped
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.showAlertView(type: .newSchedule(date: owner.selectedDate.value))
            }
            .asSignal(onErrorSignalWith: .empty())
            .emit { [weak self] isSuccess in
                if isSuccess {
                    input.fetchTrigger.accept(())
                    self?.editDataRelay.accept(isSuccess)
                } else {
                    debugPrint("❌ 일정 추가 실패")
                    self?.editDataRelay.accept(isSuccess)
                }
            }
            .disposed(by: disposeBag)
        
        input.tableViewItemEdited
            .withUnretained(self)
            .map { owner, indexPath in
                owner.searchItemId(indexPath)
            }
            .flatMap { [weak self] item in
                self!.showAlertView(type: .editSchedule(data: item))
            }
            .asSignal(onErrorSignalWith: .empty())
            .emit { [weak self] isSuccess in
                if isSuccess {
                    input.fetchTrigger.accept(())
                    self?.editDataRelay.accept(isSuccess)
                } else {
                    debugPrint("❌ 캘린더 일정 수정 실패")
                    self?.editDataRelay.accept(isSuccess)
                }
            }
            .disposed(by: disposeBag)
        
        input.tableViewItemDeleted
            .withUnretained(self)
            .flatMapLatest { owner, indexPath -> Observable<String> in
                let itemId = owner.searchItemId(indexPath).id
                
                return owner.confirmAlert.showAlert(.alert)
                    .filter { $0 }
                    .map { _ in itemId }
            }
            .flatMap {
                FirestoreManager.shared.deleteFromFirestore(type: .schedule(id: $0))
            }
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] isSuccess in
                if isSuccess {
                    input.fetchTrigger.accept(())
                    self?.editDataRelay.accept(isSuccess)
                } else {
                    debugPrint("❌ 캘린더 일정 삭제 실패")
                    self?.editDataRelay.accept(isSuccess)
                }
            }
            .disposed(by: disposeBag)
        
        input.containerViewHeight
            .bind(to: scrollViewHeight)
            .disposed(by: disposeBag)
        
        return Output(changeCurrentDatePage: changeCurrentDatePage,
                      selectedDate: selectedDate,
                      scheduleSection: scheduleSection,
                      eventsRelay: eventsRelay,
                      scrollViewHeight: scrollViewHeight,
                      editDataRelay: editDataRelay
        )
    }
}

// MARK: - ViewModel Private Method

private extension CalendarViewModel {
    
    /// Schedule 데이터를 필터링 하는 메소드
    /// - Parameters:
    ///   - dates: 필터링 기준이 되는 Date 목록
    ///   - query: 필터링할 데이터
    /// - Returns: 필터링 된 Schedule 데이터 배열
    func filteredToDayDateToScheduleSection(_ dates: [Date], _ query: [QueryDocumentSnapshot]) -> [ScheduleModelSection] {
        let filteredData = query.filter { item in
            let itemDate = (item.data()[AppConfig.SchedulesModel.date] as? Timestamp)?.dateValue() ?? Date()
            
            return dates.contains { date in
                Calendar.current.isDate(date, inSameDayAs: itemDate)
            }
        }.map {
            ScheduleDataModel(
                id: $0.data()[AppConfig.SchedulesModel.id] as? String ?? UUID().uuidString,
                title: $0.data()[AppConfig.SchedulesModel.title] as? String ?? "",
                coupleId: $0.data()[AppConfig.SchedulesModel.coupleId] as? String ?? "",
                date: ($0.data()[AppConfig.SchedulesModel.date] as? Timestamp)?.dateValue() ?? Date(),
                createdBy: $0.data()[AppConfig.SchedulesModel.createdBy] as? String ?? ""
            )
        }.sorted(by: {
            $0.date < $1.date
        })
        
        let groupedDate = Dictionary(grouping: filteredData) { item in
            return Calendar.current.startOfDay(for: item.date)
        }
        
        let sections = groupedDate.values.map {
            ScheduleModelSection(items: $0)
        }.sorted(by: {
            $0.items.first?.date ?? Date() < $1.items.first?.date ?? Date()
        })
        
        return sections
    }
    
    /// Schedule 데이터를 Date의 배열 타입으로 변환하는 메소드
    /// - Parameter query: 변환할 데이터
    /// - Returns: 변환된 Date 배열
    func mappingScheduleDataToEventDates(_ query: [QueryDocumentSnapshot]) -> [Date] {
        queryDatas = query
        
        let dates = query.map { data in
            let date = (data.data()[AppConfig.SchedulesModel.date] as? Timestamp)?.dateValue() ?? Date()
            
            return date
        }.filter { [weak self] date in
            Calendar.current.isDate(self!.changeCurrentDatePage.value, equalTo: date, toGranularity: .month)
        }
        
        return dates
    }
    
    /// 날짜를 기준으로 섹션 데이터를 필터링 하는 메소드
    /// - Parameter date: 필터링 기준 날짜
    /// - Returns: 필터링 된 Schedule 데이터
    func filteredSection(_ date: Date) -> ScheduleModelSection {
        let data = sections.flatMap { section in
            section.items.filter {
                Calendar.current.isDate($0.date, inSameDayAs: date)
            }
        }
        
        return ScheduleModelSection(items: data)
    }
    
    /// 특정 Schedule 데이터를 찾는 메소드
    /// - Parameter indexPath: 찾을 데이터의 indexPath
    /// - Returns: indexPath로 찾은 데이터
    func searchItemId(_ indexPath: IndexPath) -> ScheduleDataModel {
        let section = sections.filter {
            Calendar.current.isDate($0.items.first?.date ?? Date(), inSameDayAs: selectedDate.value)
        }.first
        
        let index = sections.firstIndex { sectionData in
            sectionData.identity == section?.identity
        }
        
        let item = sections[index ?? 0].items[indexPath.row]
        
        return item
    }
}
