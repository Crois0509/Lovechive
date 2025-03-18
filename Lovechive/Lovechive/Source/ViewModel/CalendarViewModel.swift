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

final class CalendarViewModel: ViewModelType {
    
    struct Input {
        let fetchTrigger: PublishRelay<Void>
        let previousButtonTapped: ControlEvent<Void>
        let nextButtonTapped: ControlEvent<Void>
        let addButtonTapped: ControlEvent<Void>
        let selectedDate: BehaviorRelay<Date>
        let tableViewItemDeleted: ControlEvent<IndexPath>
        let tableViewItemEdited: ControlEvent<IndexPath>
    }
    
    struct Output {
        let changeCurrentDatePage: BehaviorRelay<Date>
        let selectedDate: BehaviorRelay<Date>
        let scheduleSection: BehaviorRelay<[ScheduleModelSection]>
        let eventsRelay: BehaviorRelay<[Date]>
    }
    
    private var disposeBag = DisposeBag()
    
    private var sections: [ScheduleModelSection] = []
    private var queryDatas: [QueryDocumentSnapshot] = []
    private let confirmAlert = AlertManager(title: "경고", message: "정말 삭제하시겠습니까?", cancelTitle: "취소", destructiveTitle: "삭제")
    
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
            .emit { isSuccess in
                if isSuccess {
                    input.fetchTrigger.accept(())
                } else {
                    debugPrint("❌ 일정 추가 실패")
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
            .emit { _ in
                input.fetchTrigger.accept(())
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
            .drive { _ in
                input.fetchTrigger.accept(())
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
    
    private func filteredToDayDateToScheduleSection(_ dates: [Date], _ query: [QueryDocumentSnapshot]) -> [ScheduleModelSection] {
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
    
    private func mappingScheduleDataToEventDates(_ query: [QueryDocumentSnapshot]) -> [Date] {
        queryDatas = query
        
        let dates = query.map { data in
            let date = (data.data()[AppConfig.SchedulesModel.date] as? Timestamp)?.dateValue() ?? Date()
            
            return date
        }.filter { [weak self] date in
            Calendar.current.isDate(self!.changeCurrentDatePage.value, equalTo: date, toGranularity: .month)
        }
        
        return dates
    }
    
    private func filteredSection(_ date: Date) -> ScheduleModelSection {
        let data = sections.flatMap { section in
            section.items.filter {
                Calendar.current.isDate($0.date, inSameDayAs: date)
            }
        }
        
        return ScheduleModelSection(items: data)
    }
    
    private func showAlertView(type: AlertTypes) -> PublishRelay<Bool> {
        let vc = AppHelpers.getTopViewController()
        let alert = LovechiveAlertViewController(type: type)
        vc?.addChild(alert)
        vc?.view.addSubview(alert.view)
        alert.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        alert.didMove(toParent: vc)
        
        return alert.rx.dataSavedRelay
    }
    
    private func searchItemId(_ indexPath: IndexPath) -> ScheduleDataModel {
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
