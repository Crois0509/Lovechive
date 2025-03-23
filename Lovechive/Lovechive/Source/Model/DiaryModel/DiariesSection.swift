//
//  DiaryTableSection.swift
//  Lovechive
//
//  Created by 장상경 on 3/20/25.
//

import Foundation
import RxDataSources

struct DiariesSection: AnimatableSectionModelType {
    
    typealias Identity = String
    typealias Item = DiaryDataModel
    
    var identity: Identity {
        return self.items.description
    }
    
    var header: String
    var items: [Item]
    
    init(header: String, items: [Item]) {
        self.header = header
        self.items = items
    }
    
    init(original: DiariesSection, items: [DiaryDataModel]) {
        self = original
        self.items = items
    }
}
