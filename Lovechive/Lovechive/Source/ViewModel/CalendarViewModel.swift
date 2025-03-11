//
//  CalendarViewModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/11/25.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseFirestore

final class CalendarViewModel: ViewModelType {
    
    struct Input {
        let fetchTrigger: PublishRelay<Void>
        let previousButtonTapped: ControlEvent<Void>
        let nextButtonTapped: ControlEvent<Void>
        let addButtonTapped: ControlEvent<Void>
        let selectedDate: BehaviorRelay<Date>
    }
    
    struct Output {
        let changeCurrentDatePage: BehaviorRelay<Date>
        let selectedDate: BehaviorRelay<Date>
        let scheduleSection: BehaviorRelay<[ScheduleModelSection]>
        let eventsRelay: BehaviorRelay<[Date]>
    }
    
    private var disposeBag = DisposeBag()
    
    private let changeCurrentDatePage = BehaviorRelay<Date>(value: Date())
    private let selectedDate = BehaviorRelay<Date>(value: Date())
    private let scheduleSection = BehaviorRelay<[ScheduleModelSection]>(value: [])
    private let eventsRelay = BehaviorRelay<[Date]>(value: [])
    
    func transform(input: Input) -> Output {
        
        input.fetchTrigger
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.fetchDate()
            }
            .map { [weak self] data in
                guard let self else { return [Date]() }
                return mappingScheduleDataToEventDates(data)
            }
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] dates in
                self?.eventsRelay.accept(dates)
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
            .flatMap { owner, _ in owner.fetchDate() }
            .map { [weak self] query in
                guard let self else { return [ScheduleModelSection]() }
                let date = self.selectedDate.value
                let data = self.filteredToDayDateToScheduleSection(date, query)
                
                return [data]
            }
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] data in
                self?.scheduleSection.accept(data)
            }
            .disposed(by: disposeBag)
        
        return Output(changeCurrentDatePage: changeCurrentDatePage,
                      selectedDate: selectedDate,
                      scheduleSection: scheduleSection,
                      eventsRelay: eventsRelay)
    }
    
    private func fetchDate() -> Single<[QueryDocumentSnapshot]> {
        return FirestoreManager.shared.readFromFirestore(type: .schedule(id: ""))
    }
    
    private func filteredToDayDateToScheduleSection(_ date: Date, _ query: [QueryDocumentSnapshot]) -> ScheduleModelSection {
        let filteredData = query.filter {
            let dataDate = ($0.data()[AppConfig.SchedulesModel.date] as? Timestamp)?.dateValue() ?? Date()
            
            return Calendar.current.isDate(date, inSameDayAs: dataDate)
        }.map {
            ScheduleDataModel(
                id: $0.data()[AppConfig.SchedulesModel.id] as? String ?? "",
                title: $0.data()[AppConfig.SchedulesModel.title] as? String ?? "",
                coupleId: $0.data()[AppConfig.SchedulesModel.coupleId] as? String ?? "",
                date: ($0.data()[AppConfig.SchedulesModel.date] as? Timestamp)?.dateValue() ?? Date(),
                createdBy: $0.data()[AppConfig.SchedulesModel.createdBy] as? String ?? ""
            )
        }.sorted(by: {
            $0.date < $1.date
        })
        
        let section = ScheduleModelSection(items: filteredData)
        
        return section
    }
    
    private func mappingScheduleDataToEventDates(_ query: [QueryDocumentSnapshot]) -> [Date] {
        let dates = query.map { data in
            let date = (data.data()[AppConfig.SchedulesModel.date] as? Timestamp)?.dateValue() ?? Date()
            
            return date
        }
        
        return dates
    }
}
