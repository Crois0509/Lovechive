//
//  EditDiaryViewModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/25/25.
//

import UIKit
import RxSwift
import RxCocoa

final class EditDiaryViewModel: ViewModelMethodManager, ViewModelType {
    
    struct Input {
        let editImageButtonTapped: ControlEvent<Void>
        let activeButtonTapped: ControlEvent<Void>
        let imageData: PublishRelay<UIImage>
        let createdDate: ControlProperty<String>
        let titleData: ControlProperty<String>
        let contentData: ControlProperty<String>
        let diaryViewHeight: Observable<CGFloat>
        let editDiaryViewHeight: Observable<CGFloat>
    }
    
    struct Output {
        let scrollContentHeight: PublishRelay<CGFloat>
        let pushPhotoPicker: PublishRelay<Void>
        let changeState: PublishRelay<DiaryViewState>
        let diarySavedIsSuccess: PublishRelay<Bool>
    }
    
    private var disposeBag = DisposeBag()
    
    private let umd = UserDefaultsManager()
    
    private var currentState: DiaryViewState
    private var diaryId: String
    private var imageData: UIImage? = nil
    private var createdDate: Date?
    private var titleData: String?
    private var contentData: String?
    private var diaryData: DiaryDataModel?
    
    private let scrollContentHeight = PublishRelay<CGFloat>()
    private let pushPhotoPicker = PublishRelay<Void>()
    
    private let changeState = PublishRelay<DiaryViewState>()
    private let saveDiaryData = PublishRelay<DiaryDataModel?>()
    
    private let diarySavedIsSuccess = PublishRelay<Bool>()
    
    init(_ type: DiaryViewState, _ diaryId: String) {
        self.currentState = type
        self.diaryId = diaryId
    }
    
    func transform(input: Input) -> Output {
        
        input.editImageButtonTapped
            .bind(to: pushPhotoPicker)
            .disposed(by: disposeBag)
        
        input.activeButtonTapped
            .withUnretained(self)
            .map { owner, _  -> DiaryViewState in
                return owner.currentState
            }
            .asSignal(onErrorSignalWith: .empty())
            .emit { [weak self] state in
                switch state {
                case .view(data: let data):
                    self?.changeState.accept(.edit(data: data))
                    self?.currentState = .edit(data: data)
                case .edit(data: let data):
                    self?.saveDiaryData.accept(data)
                }
            }
            .disposed(by: disposeBag)
        
        input.imageData
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, image in
                owner.imageData = image
            }
            .disposed(by: disposeBag)
        
        input.createdDate
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, dateString in
                let date = dateString.formattedStringToDate(.yearMonthDay)
                owner.createdDate = date
            }
            .disposed(by: disposeBag)
        
        input.titleData
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, title in
                owner.titleData = title
            }
            .disposed(by: disposeBag)
        
        input.contentData
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, content in
                owner.contentData = content
            }
            .disposed(by: disposeBag)
        
        saveDiaryData
            .withUnretained(self)
            .compactMap { owner, data in
                owner.mappingDiaryDataModel(data)
            }
            .flatMap { [weak self] data -> Single<Bool> in
                guard let self else { return .just(false) }
                return self.saveDiaryData(data)
            }
            .asSignal(onErrorJustReturn: false)
            .emit { [weak self] isSuccess in
                if isSuccess {
                    guard let self, let data = self.diaryData else { return }
                    self.changeState.accept(.view(data: data))
                    self.currentState = .view(data: data)
                    self.diarySavedIsSuccess.accept(true)
                    self.umd.saveToUserDefaults(self.diaryId, forKey: self.umd.diaryId)
                } else {
                    debugPrint("🚨 다이어리 저장 실패")
                    self?.diarySavedIsSuccess.accept(false)
                }
            }
            .disposed(by: disposeBag)
        
        input.diaryViewHeight
            .bind(to: scrollContentHeight)
            .disposed(by: disposeBag)
        
        input.editDiaryViewHeight
            .bind(to: scrollContentHeight)
            .disposed(by: disposeBag)
        
        return Output(scrollContentHeight: scrollContentHeight,
                      pushPhotoPicker: pushPhotoPicker,
                      changeState: changeState,
                      diarySavedIsSuccess: diarySavedIsSuccess
        )
    }
    
}

private extension EditDiaryViewModel {
    
    func saveDiaryData(_ data: DiaryDataModel) -> Single<Bool> {
        return FirestoreManager.shared.saveDiaries(data, diaryId, data.id)
    }
    
    func mappingDiaryDataModel(_ data: DiaryDataModel?) -> DiaryDataModel? {
        if let data {
            guard let title = titleData,
                  let date = createdDate,
                  let content = contentData
            else { return nil }
            
            var imagePath: String = ""
            
            ImageManager.shared.saveImage(image: imageData) { path in
                if let path {
                    imagePath = path
                }
            }
            
            let diaryData = DiaryDataModel(id: data.id,
                                           title: title,
                                           content: content,
                                           image: imagePath,
                                           createdAt: date,
                                           createdBy: umd.userId
            )
            
            self.diaryData = diaryData
            
            return diaryData
            
        } else {
            guard let title = titleData,
                  let date = createdDate,
                  let content = contentData
            else { return nil }
            
            var imagePath: String = ""
            
            ImageManager.shared.saveImage(image: imageData) { path in
                if let path {
                    imagePath = path
                }
            }
            
            let diaryData = DiaryDataModel(id: UUID().uuidString,
                                           title: title,
                                           content: content,
                                           image: imagePath,
                                           createdAt: date,
                                           createdBy: umd.userId
            )
            
            self.diaryData = diaryData
            
            return diaryData
        }
    }
    
}
