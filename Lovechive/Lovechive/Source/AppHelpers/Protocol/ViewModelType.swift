//
//  ViewModelType.swift
//  Lovechive
//
//  Created by 장상경 on 3/9/25.
//

import Foundation
import RxSwift

protocol ViewModelType: AnyObject {
    associatedtype Input
    associatedtype Output
        
    func transform(input: Input) -> Output
}
