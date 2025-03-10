//
//  PlanViewCell.swift
//  Lovechive
//
//  Created by 장상경 on 3/9/25.
//

import UIKit
import SnapKit

/// 메인 페이지의 일정 테이블뷰의 커스텀 셀 UI
final class PlanViewCell: UITableViewCell {
    
    // MARK: - UI Components
    
    private lazy var circleView = createCircleView()
    private lazy var titleView = createLabelView("", 16, .medium, .Gray.naturalBlack)
    private lazy var dateView = createLabelView("", 14, .regular, .Gray.unSelected)
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 셀 재사용 옵션
    override func prepareForReuse() {
        super.prepareForReuse()
        
        configureReused()
    }
    
    /// 셀의 UI를 설정하는 메소드
    /// - Parameters:
    ///   - title: 일정의 title
    ///   - date: 일정의 Date
    func configureCell(title: String, date: Date) {
        titleView.text = title
        dateView.text = date.formattedDateAndTime()
    }
}

// MARK: - UI Setting Method

private extension PlanViewCell {
    
    func setupUI() {
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        [circleView, titleView, dateView].forEach {
            contentView.addSubview($0)
        }
    }
    
    func setupLayout() {
        circleView.snp.makeConstraints {
            $0.width.height.equalTo(16)
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        titleView.snp.makeConstraints {
            $0.leading.equalTo(circleView.snp.trailing).offset(12)
            $0.top.equalToSuperview().inset(8)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(24)
        }
        
        dateView.snp.makeConstraints {
            $0.leading.equalTo(circleView.snp.trailing).offset(12)
            $0.bottom.equalToSuperview().inset(8)
            $0.trailing.equalTo(titleView.snp.trailing)
            $0.height.equalTo(24)
        }
    }
    
    /// 셀이 재사용될 때 호출되는 메소드
    /// UI 설정을 초기화
    func configureReused() {
        titleView.text = ""
        dateView.text = ""
    }
    
    func createCircleView() -> UIView {
        let view = UIView()
        view.backgroundColor = .Personal.highlightPink
        view.layer.cornerRadius = 8
        
        return view
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
