//
//  EditDiaryViewController.swift
//  Lovechive
//
//  Created by 장상경 on 3/24/25.
//

import UIKit
import PhotosUI
import SnapKit
import RxSwift
import RxCocoa

final class EditDiaryViewController: UIViewController {
    
    private var disposeBag = DisposeBag()
    fileprivate let diarySavedIsSuccess = PublishRelay<Void>()
    
    private let editDiaryView = EditDiaryView()
    private let diaryView = DiaryDetailView()
    private let activeButton = UIButton()
    private let scrollView = UIScrollView()
    private let activityIndicator = UIActivityIndicatorView()
    
    private lazy var photoPicker = PHPickerViewController(configuration: createdPhotoPickerConfiguration())
    
    private let viewModel: EditDiaryViewModel
    
    private var currentState: DiaryViewState
    
    init(_ title: String?, _ type: DiaryViewState, _ diaryId: String) {
        self.currentState = type
        self.viewModel = EditDiaryViewModel(type, diaryId)
        super.init(nibName: nil, bundle: nil)
        
        createdNavigationTitle(title)
        changeCurrentState(type)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint(Self.self, "deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        disposeBag = DisposeBag()
        photoPicker.dismiss(animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        disposeBag = DisposeBag()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        editDiaryView.endEditing(true)
    }
}

// MARK: - UI Setting Method

private extension EditDiaryViewController {
    
    func setupUI() {
        setupScrollView()
        setupButton()
        setupPhotoPicker()
        setupActivityView()
        configureSelf()
        setupLayout()
        bind()
    }
    
    func configureSelf() {
        navigationController?.navigationBar.tintColor = .Personal.deepPink
        view.backgroundColor = .Personal.backgroundPink
        [scrollView, activeButton, activityIndicator].forEach {
            view.addSubview($0)
        }
    }
    
    func setupLayout() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(activeButton.snp.top).offset(-16)
            $0.width.equalToSuperview()
        }
        
        editDiaryView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.greaterThanOrEqualTo(440)
            $0.width.equalToSuperview().inset(16)
        }
        
        diaryView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.greaterThanOrEqualTo(100)
            $0.width.equalToSuperview().inset(16)
        }
        
        activeButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(64)
        }
        
        activityIndicator.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setupPhotoPicker() {
        photoPicker.delegate = self
    }
    
    func setupButton() {
        activeButton.setTitle(currentState.buttonTitle, for: .normal)
        activeButton.setTitleColor(.white, for: .normal)
        activeButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        activeButton.titleLabel?.textAlignment = .center
        activeButton.backgroundColor = .Personal.highlightPink
        activeButton.layer.cornerRadius = 16
    }
    
    func setupScrollView() {
        scrollView.contentInset.bottom = 32
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        [editDiaryView, diaryView].forEach {
            scrollView.addSubview($0)
        }
    }
    
    func setupActivityView() {
        activityIndicator.alpha = 0
        activityIndicator.color = .white
        activityIndicator.style = .large
        activityIndicator.backgroundColor = .black.withAlphaComponent(0.3)
        activityIndicator.isHidden = true
    }
    
    func createdPhotoPickerConfiguration() -> PHPickerConfiguration {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        return config
    }
    
    func createdNavigationTitle(_ title: String?) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .Personal.highlightPink
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = .clear
        
        navigationItem.titleView = titleLabel
    }
    
    func changeCurrentState(_ state: DiaryViewState) {
        switch state {
        case .view(data: let data):
            diaryView.configureDiary(data)
            currentState = state
            scrollView.contentSize.height = diaryView.bounds.height
            
            UIView.animate(withDuration: 0.3) {
                self.diaryView.isHidden = false
                self.diaryView.alpha = 1
                self.editDiaryView.alpha = 0
                self.editDiaryView.isHidden = true
                self.activeButton.setTitle(state.buttonTitle, for: .normal)
            }
        case .edit(data: let data):
            editDiaryView.configureDiary(data)
            currentState = state
            scrollView.contentSize.height = editDiaryView.bounds.height
            
            UIView.animate(withDuration: 0.3) {
                self.editDiaryView.isHidden = false
                self.editDiaryView.alpha = 1
                self.diaryView.alpha = 0
                self.diaryView.isHidden = true
                self.activeButton.setTitle(state.buttonTitle, for: .normal)
            }
        }
    }
    
    func showActivityIndicator(_ isShowing: Bool) {
        UIView.animate(withDuration: 0.3) {
            if isShowing {
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
                self.activityIndicator.alpha = 1
                
            } else {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.alpha = 0
                self.activityIndicator.isHidden = true
                
            }
        }
    }
    
    func bind() {
        
        let input = EditDiaryViewModel.Input(editImageButtonTapped: editDiaryView.rx.editImageButtonTapped,
                                             activeButtonTapped: activeButton.rx.tap,
                                             imageData: editDiaryView.rx.sendImageData,
                                             createdDate: editDiaryView.rx.sendCreatedDate,
                                             titleData: editDiaryView.rx.sendTitle,
                                             contentData: editDiaryView.rx.sendContent,
                                             diaryViewHeight: diaryView.rx.boundsHeight,
                                             editDiaryViewHeight: editDiaryView.rx.boundsHeight
        )
        
        let output = viewModel.transform(input: input)
        
        output.pushPhotoPicker
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, _ in
                owner.present(owner.photoPicker, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.scrollContentHeight
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, height in
                owner.scrollView.contentSize.height = height
            }
            .disposed(by: disposeBag)
        
        output.changeState
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, state in
                owner.changeCurrentState(state)
            }
            .disposed(by: disposeBag)
        
        output.diarySavedIsSuccess
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, isSuccess in
                if isSuccess {
                    owner.diarySavedIsSuccess.accept(())
                } else {
                    debugPrint("다이어리 저장 실패...")
                }
            }
            .disposed(by: disposeBag)
        
        output.showActivityIndicator
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, showing in
                owner.showActivityIndicator(showing)
            }
            .disposed(by: disposeBag)
        
    }
}

extension EditDiaryViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let itemProvider = results.first?.itemProvider
        
        guard
            let itemProvider,
            itemProvider.canLoadObject(ofClass: UIImage.self)
        else { return }
        
        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] provider, error in
            
            if let error {
                debugPrint("🚨 이미지 추출 실패", error.localizedDescription)
            } else if let image = provider as? UIImage {
                debugPrint("✅ 이미지 추출 성공")
                self?.editDiaryView.insertImage(image)
            }
            
        }
    }
}

// MARK: - Reactive Extension

extension Reactive where Base: EditDiaryViewController {
    var diarySavedIsSuccess: PublishRelay<Void> {
        base.diarySavedIsSuccess
    }
}
