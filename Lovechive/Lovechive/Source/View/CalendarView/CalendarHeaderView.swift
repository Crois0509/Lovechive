//
//  CalendarHeaderView.swift
//  Lovechive
//
//  Created by 장상경 on 3/11/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

/// 캘린더 헤더 뷰
final class CalendarHeaderView: UIView {
    
    // MARK: - UI Components
    
    fileprivate lazy var previousButton = createButton(title: "<")
    fileprivate lazy var nextButton = createButton(title: ">")
    private let dateTitle = UILabel()
    private let headerStackView = UIStackView()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 헤더뷰를 설정하는 메소드
    /// - Parameter date: 헤더뷰 타이틀에 들어갈 Date
    func configureHeaderView(_ date: Date) {
        dateTitle.text = date.formattedDateToString(.yearMonth)
    }
}

// MARK: - UI Setting Method

private extension CalendarHeaderView {
    
    func setupUI() {
        setupStackView()
        setupDateTitle()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .white
        layer.cornerRadius = 16
        addSubview(headerStackView)
    }
    
    func setupLayout() {
        headerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        previousButton.snp.makeConstraints {
            $0.width.height.equalTo(60)
        }
        
        nextButton.snp.makeConstraints {
            $0.width.height.equalTo(60)
        }
    }
    
    func createButton(title: String) -> UIButton {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle(title, for: .normal)
        button.setTitleColor(.Personal.highlightPink, for: .normal)
        button.titleLabel?.font = .myoyaFont(24)
        
        return button
    }
    
    func setupDateTitle() {
        dateTitle.text = AppConfig.CalendarViewConfig.headerDate
        dateTitle.font = .myoyaFont(24)
        dateTitle.textColor = .Personal.highlightPink
        dateTitle.numberOfLines = 1
        dateTitle.textAlignment = .center
    }
    
    func setupStackView() {
        headerStackView.spacing = 0
        headerStackView.axis = .horizontal
        headerStackView.alignment = .fill
        headerStackView.distribution = .fill
        headerStackView.backgroundColor = .clear
        [previousButton, dateTitle, nextButton].forEach {
            headerStackView.addArrangedSubview($0)
        }
    }
    
}

// MARK: - Reactive Extension

extension Reactive where Base: CalendarHeaderView {
    /// 이전 버튼의 탭 이벤트를 방출하는 옵저버블
    var previousButtonTapped: ControlEvent<Void> {
        base.previousButton.rx.tap
    }
    
    /// 다음 버튼의 탭 이벤트를 방출하는 옵저버블
    var nextButtonTapped: ControlEvent<Void> {
        base.nextButton.rx.tap
    }
}
