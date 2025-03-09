//
//  PlanViewCell.swift
//  Lovechive
//
//  Created by 장상경 on 3/9/25.
//

import UIKit
import SnapKit

final class PlanViewCell: UITableViewCell {
    
    static let id: String = "PlanViewCell"
    
    private lazy var circleView = createCircleView()
    private lazy var titleView = createLabelView("", 16, .medium, .Gray.naturalBlack)
    private lazy var dateView = createLabelView("", 14, .regular, .Gray.unSelected)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        configureReused()
    }
}

private extension PlanViewCell {
    
    func setupUI() {
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .clear
        [circleView, titleView, dateView].forEach {
            addSubview($0)
        }
    }
    
    func setupLayout() {
        circleView.snp.makeConstraints {
            $0.width.height.equalTo(16)
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        titleView.snp.makeConstraints {
            $0.leading.equalTo(circleView.snp.trailing).offset(12)
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(24)
        }
        
        dateView.snp.makeConstraints {
            $0.leading.equalTo(circleView.snp.trailing).offset(12)
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(24)
        }
    }
    
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
