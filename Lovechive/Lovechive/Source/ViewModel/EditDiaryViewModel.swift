//
//  EditDiaryViewModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/25/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxKeyboard

final class EditDiaryViewModel: ViewModelMethodManager, ViewModelType {
    
    struct Input {
        let editImageButtonTapped: ControlEvent<Void>
        let activeButtonTapped: ControlEvent<Void>
        let imageData: Observable<UIImage>
        let createdDate: ControlProperty<String>
        let titleData: ControlProperty<String>
        let contentData: ControlProperty<String>
        let diaryViewHeight: Observable<CGFloat>
        let editDiaryViewHeight: Observable<CGFloat>
    }
    
    struct Output {
        let scrollContentHeight: BehaviorRelay<CGFloat>
        let pushPhotoPicker: PublishRelay<Void>
        let changeState: PublishRelay<DiaryViewState>
        let diarySavedIsSuccess: PublishRelay<Bool>
    }
    
    private var disposeBag = DisposeBag()
    
    private let umd = UserDefaultsManager()
    private let alert = AlertManager.init(title: "경고", message: "모든 내용을 입력해 주세요!!", cancelTitle: "확인")
    private lazy var actionSheet = AlertManager(title: "알림", message: "", cancelTitle: "닫기")
    
    private var currentState: DiaryViewState
    private var diaryId: String
    private var imageData: UIImage? = nil
    private var createdDate: Date?
    private var titleData: String?
    private var contentData: String?
    private var diaryData: DiaryDataModel?
    
    private let scrollContentHeight = BehaviorRelay<CGFloat>(value: 0)
    private let keyboardHeight = BehaviorRelay<CGFloat>(value: 0)
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
            .flatMap { [weak self] data -> Observable<DiaryDataModel?> in
                guard let self else { return .just(nil) }
                let isEmpty = self.checkDataIsEmpty()
                
                if isEmpty {
                    return self.alert.showAlert(.alert).map { _ in nil }
                } else {
                    return .just(data)
                }
            }
            .flatMap { [weak self] data -> Single<Bool> in
                guard let self, let data else { return .just(false) }
                return self.saveDiaryData(data)
            }
            .asSignal(onErrorJustReturn: false)
            .emit { [weak self] isSuccess in
                if isSuccess {
                    guard let self, let data = self.diaryData else { return }
                    self.changeState.accept(.view(data: data))
                    self.currentState = .view(data: data)
                    self.diarySavedIsSuccess.accept(true)
                    self.umd.saveToUserDefaults(self.diaryId, forKey: AppConfig.UserDefaultsConfig.diaryId)
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
        
        RxKeyboard.instance.visibleHeight
            .asObservable()
            .distinctUntilChanged()
            .bind(to: keyboardHeight)
            .disposed(by: disposeBag)
        
        keyboardHeight
            .withUnretained(self)
            .map { owner, height in
                if height > 0 {
                    let scrollSize = owner.scrollContentHeight.value
                    let totalHeight = scrollSize + height
                    return totalHeight
                } else {
                    let scrollSize = owner.scrollContentHeight.value
                    return scrollSize - 336
                }
            }
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
    
    func checkDataIsEmpty() -> Bool {
        guard let titleData,
              let contentData
        else { return true }
        
        if titleData.isEmpty || contentData.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    func mappingDiaryDataModel(_ data: DiaryDataModel?) -> DiaryDataModel? {
        if let data {
            guard let title = titleData,
                  let date = createdDate,
                  let content = contentData
            else { return nil }
            
            var imagePath: String = ""
            
            if imageData != nil {
                ImageManager.shared.saveImage(image: imageData) { path in
                    if let path {
                        if path == data.image {
                            imagePath = data.image
                        } else {
                            imagePath = path
                        }
                    }
                }
            } else if !data.image.isEmpty {
                imagePath = data.image
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
