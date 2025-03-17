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

final class CalendarHeaderView: UIView {
    
    fileprivate lazy var previousButton = createButton(title: "<")
    fileprivate lazy var nextButton = createButton(title: ">")
    private let dateTitle = UILabel()
    private let headerStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureHeaderView(_ date: Date) {
        dateTitle.text = date.formattedDateToString(.yearMonth)
    }
}

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

extension Reactive where Base: CalendarHeaderView {
    var previousButtonTapped: ControlEvent<Void> {
        base.previousButton.rx.tap
    }
    
    var nextButtonTapped: ControlEvent<Void> {
        base.nextButton.rx.tap
    }
}
