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
        static let user1Id: String = "user1Id"
        static let user2Id: String = "user2Id"
        static let user1Name: String = "user1Name"
        static let user2Name: String = "user2Name"
    }
    
    enum DiariesModel {
        static let title: String = "title"
        static let createdBy: String = "createdBy"
        static let content: String = "content"
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
        static let id: String = "id"
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
        static let info: String = "아직 일정이 추가되지 않았어요"
        static let cellId: String = "PlanViewCell"
    }
    
    // MARK: - CalendarView에서 사용할 String 데이터
    
    enum CalendarViewConfig {
        static let cellId: String = "ScheduleViewCell"
        static let headerDate: String = "2000년 1월"
        static let cellDate: String = "오전 0시"
        static let cellTitle: String = "새로운 일정"
        static let title: String = "1월 1일 일정"
        static let info: String = "아직 일정이 없습니다."
    }
    
    // MARK: - SettingView에서 사용할 String 데이터
    enum SettingConfig {
        static let cellId = "SetTableViewCell"
        static let nameT = "이름"
        static let name = "김남주"
        static let loverT = "연인"
        static let lover = "김여주"
        static let birth = "생년월일"
        static let birthD = "2000년 1월 1일"
        static let anni = "연애 기념일"
        static let anniV = "2024년 1월 29일"
        static let myInfo = "내 정보"
        static let edit = "편집"
        
        static let alarm = "알림 설정"
        static let privacy = "개인정보처리방침"
        static let playInfo = "사용 방법"
        static let review = "앱 리뷰 남기기"
        static let bug = "버그 제보 / 문의"
        static let versionInfo = "앱 버전"
        static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        static let appstoreLink = "itms-apps://apps.apple.com/app/id6741835898"
    }
}
