//
//  ViewModelType.swift
//  Lovechive
//
//  Created by 장상경 on 3/9/25.
//

import Foundation
import RxSwift

/// 뷰 모델 타입을 정의하는 protocol
protocol ViewModelType: AnyObject {
    associatedtype Input
    associatedtype Output
        
    func transform(input: Input) -> Output
}
