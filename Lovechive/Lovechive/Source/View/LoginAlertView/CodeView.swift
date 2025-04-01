//
//  CodeView.swift
//  Lovechive
//
//  Created by 장상경 on 3/31/25.
//

import UIKit
import SnapKit

final class CodeView: UIView {
    
    private let firstSection = UILabel()
    private let code = UILabel()
    private let secondSection = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UI Setting Method

private extension CodeView {
    
    func setupUI() {
        setupSections()
        setupCode()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .clear
        [firstSection, code, secondSection].forEach {
            addSubview($0)
        }
    }
    
    func setupLayout() {
        firstSection.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        code.snp.makeConstraints {
            $0.top.equalTo(firstSection.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
        }
        
        secondSection.snp.makeConstraints {
            $0.top.equalTo(code.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(20)
            $0.bottom.equalToSuperview().inset(8)
        }
    }
    
    func setupSections() {
        [firstSection, secondSection].forEach {
            $0.textColor = .Gray.naturalBlack
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.numberOfLines = 1
            $0.textAlignment = .center
            $0.backgroundColor = .clear
        }
        firstSection.text = "아래 코드를 연인에게 공유해 주세요!"
        secondSection.text = "연인이 코드를 입력하면 앱을 사용할 수 있습니다."
    }
    
    func setupCode() {
        code.text = UserDefaults.standard.string(forKey: AppConfig.UserDefaultsConfig.coupleId)
        code.textColor = .Personal.deepPink
        code.font = .boldSystemFont(ofSize: 20)
        code.numberOfLines = 1
        code.textAlignment = .center
        code.backgroundColor = .clear
    }
    
}
