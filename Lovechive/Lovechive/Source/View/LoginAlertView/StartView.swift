//
//  StartView.swift
//  Lovechive
//
//  Created by 장상경 on 3/31/25.
//

import UIKit
import SnapKit

final class StartView: UILabel {
    
    private let startText: String = "앱을 처음 사용하신다면\n새로 시작하기\n버튼을 클릭해 주세요!\n\n연인에게 코드를 받았다면\n코드 입력하기\n버튼을 클릭해 주세요!"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UI Setting Method

private extension StartView {
    
    func setupUI() {
        configureSelf()
    }
    
    func configureSelf() {
        backgroundColor = .clear
        font = .systemFont(ofSize: 14, weight: .regular)
        textColor = .Gray.naturalBlack
        textAlignment = .center
        numberOfLines = 0
        attributedText = makeBoldAttributedText(for: startText)
    }
    
    func makeBoldAttributedText(for text: String) -> NSMutableAttributedString {
        let boldParts = ["새로 시작하기", "코드 입력하기"]
        let attributedString = NSMutableAttributedString(string: text)
        let boldFont = UIFont.boldSystemFont(ofSize: 14)
        let boldColor = UIColor.Personal.deepPink

        boldParts.forEach { boldPart in
            let range = (text as NSString).range(of: boldPart)
            if range.location != NSNotFound { // 존재하는 경우에만 적용
                attributedString.addAttribute(.font, value: boldFont, range: range)
                attributedString.addAttribute(.foregroundColor, value: boldColor, range: range)
            }
        }

        return attributedString
    }
    
}
