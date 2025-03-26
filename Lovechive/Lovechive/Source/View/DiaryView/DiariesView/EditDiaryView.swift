//
//  EditDiaryView.swift
//  Lovechive
//
//  Created by 장상경 on 3/24/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class EditDiaryView: UIView {
    
    fileprivate let editImageButton = UIButton()
    fileprivate let imageView = UIImageView()
    fileprivate let editDateView = AlertMyTextFieldView(.calendar, title: "작성일자", text: "날짜를 선택해 주세요")
    fileprivate let titleView = AlertMyTextFieldView(.limit(value: 10), title: "제목", text: "일기의 제목을 입력해 주세요")
    fileprivate let contentsView = EditMyTextFieldView(title: "내용", text: "내용을 입력해 주세요")
    
    fileprivate let sendImageData = PublishRelay<UIImage>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        endEditing(true)
    }
    
    func insertImage(_ image: UIImage) {
        setupImage(image)
        sendImageData.accept(image)
    }
    
    func configureDiary(_ data: DiaryDataModel?) {
        guard let data else { return }
        let image = ImageManager.shared.loadImage(path: data.image)
        
        editDateView.configureTextField(data.createdAt.formattedDateToString(.yearMonthDay))
        titleView.configureTextField(data.title)
        contentsView.configureTextField(data.content)
        
        if let image {
            setupImage(image)
        }
    }
    
}

// MARK: - UI Setting Method

private extension EditDiaryView {
    
    func setupUI() {
        setupButton()
        setupImageView()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .white
        layer.cornerRadius = 16
        [editImageButton, imageView, editDateView, titleView, contentsView].forEach {
            addSubview($0)
        }
    }
    
    func setupLayout() {
        editImageButton.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(80)
        }
        
        imageView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(80)
        }
        
        editDateView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(16)
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
        editImageButton.semanticContentAttribute = .spatial
        editImageButton.backgroundColor = .clear
        editImageButton.layer.cornerRadius = 8
        editImageButton.layer.borderColor = UIColor.Personal.highlightPink.cgColor
        editImageButton.layer.borderWidth = 1
    }
    
    func setupImageView() {
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.borderColor = UIColor.Personal.highlightPink.cgColor
        imageView.layer.borderWidth = 1
    }
    
    func setupImage(_ image: UIImage) {
        DispatchQueue.main.async {
            let aspectRatio = image.size.height / image.size.width
            let newHeight = self.imageView.frame.width * aspectRatio
            
            self.imageView.image = image
            self.imageView.snp.updateConstraints {
                $0.height.equalTo(newHeight)
            }
            
            self.editImageButton.snp.updateConstraints {
                $0.height.equalTo(newHeight)
            }
        }
    }
    
}

// MARK: - Reactive Extension

extension Reactive where Base: EditDiaryView {
    var editImageButtonTapped: ControlEvent<Void> {
        base.editImageButton.rx.tap
    }
    
    var sendImageData: Observable<UIImage> {
        base.sendImageData.take(until: base.rx.deallocated)
    }
    
    var sendCreatedDate: ControlProperty<String> {
        base.editDateView.rx.editingTextField
    }
    
    var sendTitle: ControlProperty<String> {
        base.titleView.rx.editingTextField
    }
    
    var sendContent: ControlProperty<String> {
        base.contentsView.rx.editingTextField
    }
}
