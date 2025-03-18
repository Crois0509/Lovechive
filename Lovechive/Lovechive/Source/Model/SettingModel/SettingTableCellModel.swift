//
//  SettingTableCellModel.swift
//  TripLog
//
//  Created by 장상경 on 1/23/25.
//

import UIKit
import RxSwift
import RxCocoa

/// 설정탭에서 사용할 테이블뷰의 Cell Model
struct SettingTableCellModel {
    let title: String
    let extraView: UIView?
    let action: (() -> Void)?
}
