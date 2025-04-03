//
//  AppIntent.swift
//  LovechiveWidget
//
//  Created by 장상경 on 4/3/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "디데이 설정" }
    static var description: IntentDescription { "연애 기념일을 선택하세요." }
}
