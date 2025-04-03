//
//  LovechiveWidget.swift
//  LovechiveWidget
//
//  Created by 장상경 on 4/3/25.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 6 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct LovechiveWidgetEntryView : View {
    var entry: Provider.Entry
    var dDay: Int = UserDefaults.shared.integer(forKey: "dDay")

    var body: some View {
        
        ZStack {
            
            VStack(alignment: .center, spacing: 0) {
                Image("heartIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                
                Image("Lovechive")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 30)
            }
            
            Text("\(dDay)일")
                .font(.myoyaFont(32))
                .foregroundStyle(Color.white)
                .padding(.bottom, 35)
            
        }
        
    }
}

struct LovechiveWidget: Widget {
    let kind: String = "LovechiveWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: Provider()) { entry in
                
            LovechiveWidgetEntryView(entry: entry)
                .containerBackground(Color.Personal.backgroundPink, for: .widget)
                
        }
        .configurationDisplayName("디데이 위젯")
        .description("연인과 함께한 시간을 위젯에서 확인할 수 있습니다.")
        .supportedFamilies([.systemSmall])
    }
}

extension UserDefaults {
    static var shared: UserDefaults {
        let groupId: String = "group.lovechive"
        return UserDefaults(suiteName: groupId)!
    }
}

#Preview(as: .systemSmall) {
    LovechiveWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .init())
}
