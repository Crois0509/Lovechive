//
//  DDayView.swift
//  Lovechive
//
//  Created by 장상경 on 3/9/25.
//

import UIKit
import SnapKit

/// D-Day를 표현하는 UIView
final class DDayView: UIView {
    
    // MARK: - UI Components
    
    private lazy var dDayView = createLabelView("D + 0", 20, .bold, .Personal.deepPink)
    private lazy var titleTextView = createLabelView("우리의 시작", 14, .regular, .Personal.highlightPink)
    private lazy var infoLabel = createLabelView("2000.01.01부터", 14, .regular, .Personal.highlightPink)
    
    private let textStackView = UIStackView()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// D-Day Text를 설정하는 메소드
    /// - Parameter date: D-Day Date
    func configureDDayView(_ date: Date) {
        let dDay = Calendar.current.dateComponents([.day], from: date, to: Date()).day
        dDayView.text = "D + \(dDay ?? 0)"
        infoLabel.text = date.formattedDate()
    }
    
}

// MARK: - UI Setting Method

private extension DDayView {
    
    func setupUI() {
        setupStackView()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .Personal.pointPink
        layer.cornerRadius = 16
        addSubview(textStackView)
    }
    
    func setupLayout() {
        textStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
    }
    
    func setupStackView() {
        textStackView.axis = .vertical
        textStackView.spacing = 10
        textStackView.alignment = .fill
        textStackView.distribution = .fillEqually
        textStackView.backgroundColor = .clear
        [titleTextView, dDayView, infoLabel].forEach {
            textStackView.addArrangedSubview($0)
        }
    }
    
    func createLabelView(_ title: String, _ size: CGFloat, _ weight: UIFont.Weight, _ color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = title
        label.textColor = color
        label.numberOfLines = 1
        label.textAlignment = .left
        label.font = .systemFont(ofSize: size, weight: weight)
        
        return label
    }
    
}
