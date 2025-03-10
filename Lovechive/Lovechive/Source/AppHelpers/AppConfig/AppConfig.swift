//
//  AppConfig.swift
//  Lovechive
//
//  Created by 장상경 on 3/8/25.
//

import Foundation

enum AppConfig {
    // MARK: - UserDefaults에서 사용할 String 데이터
    
    enum UserDefaultsConfig {
        static let userId: String = "userId"
        static let coupleId: String = "coupleId"
    }
    
    // MARK: - FirestoreModel에서 사용할 String 데이터
    
    enum CouplesModel {
        static let dDay: String = "dDay"
        static let user1: String = "user1"
        static let user2: String = "user2"
    }
    
    enum DiariesModel {
        static let id: String = "id"
        static let author: String = "author"
        static let content: String = "content"
        static let coupleId: String = "coupleId"
        static let createdAt: String = "createdAt"
        static let image: String = "image"
    }
    
    enum SchedulesModel {
        static let id: String = "id"
        static let coupleId: String = "coupleId"
        static let createdBy: String = "createdBy"
        static let date: String = "date"
        static let title: String = "title"
    }
    
    enum UserModel {
        static let name: String = "name"
        static let email: String = "email"
        static let coupleId: String = "coupleId"
        static let birthDay: String = "birthDay"
        static let createdAt: String = "createdAt"
    }

    // MARK: - LatestDiaryView에서 사용할 String 데이터
    
    enum LatestDiary {
        static let title: String = "최근 작성한 일기"
        static let content: String = "아직 작성한 일기가 없습니다."
        static let date: String = "2000.01.01 오후 12시"
    }
    
    // MARK: - PlanerView에서 사용할 String 데이터
    
    enum PlanerView {
        static let title: String = "다가오는 일정"
        static let cellId: String = "PlanViewCell"
    }
}
