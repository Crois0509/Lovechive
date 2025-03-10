//
//  MainPageViewModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/9/25.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseFirestore

/// 메인 페이지 VC의 ViewModel
final class MainPageViewModel: ViewModelType {
    
    struct Input {
        let fetchTrigger: PublishRelay<Void>
    }
    
    struct Output {
        let sections: BehaviorRelay<[PlanTableViewSection]>
        let latestDiaryRelay: PublishRelay<DiaryDataModel>
        let dDayRelay: PublishRelay<CoupleDataModel>
    }
    
    private var disposeBag = DisposeBag()
    
    private let sections = BehaviorRelay<[PlanTableViewSection]>(value: [])
    private let latestDiaryRelay = PublishRelay<DiaryDataModel>()
    private let dDayRelay = PublishRelay<CoupleDataModel>()
    
    func transform(input: Input) -> Output {
        input.fetchTrigger
            .withUnretained(self)
            .flatMap { (owner, _) -> Single<[QueryDocumentSnapshot]> in
                owner.fetchData(type: .schedule(id: ""))
            }
            .map { [weak self] data in
                guard let self else { return PlanTableViewSection.init(items: []) }
                return self.mappingQueryDataToSectionData(data)
            }
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] section in
                self?.sections.accept([section])
            }
            .disposed(by: disposeBag)
        
        input.fetchTrigger
            .withUnretained(self)
            .flatMap { (owner, _) -> Single<[QueryDocumentSnapshot]> in
                owner.fetchData(type: .diary(id: ""))
            }
            .map { [weak self] data in
                guard let self else { return [DiaryDataModel]() }
                return self.mappingQueryDataToDiaryData(data)
            }
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] diaries in
                guard let latestDiaryData = diaries.last else { return }
                self?.latestDiaryRelay.accept(latestDiaryData)
            }
            .disposed(by: disposeBag)
        
        input.fetchTrigger
            .withUnretained(self)
            .flatMap { (owner, _) -> Single<[QueryDocumentSnapshot]> in
                owner.fetchData(type: .couple)
            }
            .map { [weak self] data in
                guard let self else { return [CoupleDataModel]() }
                return self.mappingQueryDataToUserData(data)
            }
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] couples in
                guard let coupleData = couples.last else { return }
                self?.dDayRelay.accept(coupleData)
            }
            .disposed(by: disposeBag)
        
        return Output(sections: sections,
                      latestDiaryRelay: latestDiaryRelay,
                      dDayRelay: dDayRelay
        )
    }
    
    /// Firestore에서 데이터를 가져오는 메소드
    /// - Parameter type: 가져올 데이터의 타입
    /// - Returns: 가져온 데이터 목록
    private func fetchData(type: FirestoreDataTypes) -> Single<[QueryDocumentSnapshot]> {
        return FirestoreManager.shared.readFromFirestore(type: type)
    }
    
    /// Query 데이터를 PlanTableViewSection 타입으로 변환하는 메소드
    /// - Parameter data: Query 데이터
    /// - Returns: 변환된 PlanTableViewSection 데이터
    private func mappingQueryDataToSectionData(_ data: [QueryDocumentSnapshot]) -> PlanTableViewSection {
        let filteredData = data.filter {
            let date = ($0.data()[AppConfig.SchedulesModel.date] as? Timestamp)?.dateValue() ?? Date()
            
            return Date() <= date
        }.map {
            ScheduleDataModel(
                id: $0.data()[AppConfig.SchedulesModel.id] as? String ?? "",
                title: $0.data()[AppConfig.SchedulesModel.title] as? String ?? "",
                coupleId: $0.data()[AppConfig.SchedulesModel.coupleId] as? String ?? "",
                date: ($0.data()[AppConfig.SchedulesModel.date] as? Timestamp)?.dateValue() ?? Date(),
                createdBy: $0.data()[AppConfig.SchedulesModel.createdBy] as? String ?? ""
            )
        }
        
        let sortedData = Array(filteredData.sorted(by: {
            $0.date < $1.date
        }).prefix(3))
        
        let section = PlanTableViewSection(items: sortedData)
        
        return section
    }
    
    /// Query 데이터를 DiaryDataModel 타입으로 가공하는 메소드
    /// - Parameter data: Query 데이터
    /// - Returns: 변환된 DiaryDataModel 데이터 배열
    private func mappingQueryDataToDiaryData(_ data: [QueryDocumentSnapshot]) -> [DiaryDataModel] {
        let data = data.map {
            DiaryDataModel(id: $0.data()[AppConfig.DiariesModel.id] as? String ?? "",
                           author: $0.data()[AppConfig.DiariesModel.author] as? String ?? "",
                           coupleId: $0.data()[AppConfig.DiariesModel.coupleId] as? String ?? "",
                           content: $0.data()[AppConfig.DiariesModel.content] as? String ?? "",
                           image: $0.data()[AppConfig.DiariesModel.image] as? String ?? "",
                           createdAt: ($0.data()[AppConfig.DiariesModel.createdAt] as? Timestamp)?.dateValue() ?? Date()
            )
        }.sorted(by: {
            $0.createdAt < $1.createdAt
        })
        
        return data
    }
    
    /// Query 데이터를 CoupleDataModel 타입으로 가공하는 메소드
    /// - Parameter data: Query 데이터
    /// - Returns: 변환된 CoupleDataModel 배열
    private func mappingQueryDataToUserData(_ data: [QueryDocumentSnapshot]) -> [CoupleDataModel] {
        let data = data.map {
            CoupleDataModel(user1: $0.data()[AppConfig.CouplesModel.user1] as? String ?? "",
                            user2: $0.data()[AppConfig.CouplesModel.user2] as? String ?? "",
                            dDay: ($0.data()[AppConfig.CouplesModel.dDay] as? Timestamp)?.dateValue() ?? Date()
            )
        }
        
        return data
    }
}
