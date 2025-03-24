//
//  EditDiaryView.swift
//  Lovechive
//
//  Created by 장상경 on 3/24/25.
//

import UIKit
import SnapKit

final class EditDiaryView: UIView {
    
    private let editImageButton = UIButton()
    private let editDateView = AlertMyTextFieldView(.calendar, title: "작성일자", text: "날짜를 선택해 주세요")
    private let titleView = AlertMyTextFieldView(.limit(value: 10), title: "제목", text: "일기의 제목을 입력해 주세요")
    private let contentsView = EditMyTextFieldView(title: "내용", text: "내용을 입력해 주세요")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureDiary(_ data: DiaryDataModel) {
        let image = ImageManager.shared.loadImage(path: data.image)
        
        editDateView.configureTextField(data.createdAt.formattedDateToString(.yearMonthDay))
        titleView.configureTextField(data.title)
        contentsView.configureTextField(data.content)
    }
    
}

// MARK: - UI Setting Method

private extension EditDiaryView {
    
    func setupUI() {
        setupButton()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .white
        layer.cornerRadius = 16
        [editImageButton, editDateView, titleView, contentsView].forEach {
            addSubview($0)
        }
    }
    
    func setupLayout() {
        editImageButton.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(16)
            $0.height.greaterThanOrEqualTo(80)
        }
        
        editDateView.snp.makeConstraints {
            $0.top.equalTo(editImageButton.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(64)
        }
        
        titleView.snp.makeConstraints {
            $0.top.equalTo(editDateView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(64)
        }
        
        contentsView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
        }
    }
    
    func setupButton() {
        editImageButton.setImage(UIImage(systemName: "plus"), for: .normal)
        editImageButton.tintColor = .Personal.highlightPink
        editImageButton.setTitle("사진을 추가해 보세요", for: .normal)
        editImageButton.setTitleColor(.Personal.highlightPink, for: .normal)
        editImageButton.titleLabel?.font = .myoyaFont(12)
        editImageButton.titleLabel?.textAlignment = .center
        editImageButton.backgroundColor = .clear
        editImageButton.layer.cornerRadius = 8
        editImageButton.layer.borderColor = UIColor.Personal.highlightPink.cgColor
        editImageButton.layer.borderWidth = 1
    }
    
}
