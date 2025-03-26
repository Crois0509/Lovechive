//
//  PageViewController.swift
//  Lovechive
//
//  Created by 장상경 on 3/9/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

/// 현재 보여지는 페이지를 관리할 객체
final class PageViewController: UIPageViewController {
    
    // MARK: - Rx Properties
    
    private var disposeBag = DisposeBag()
    
    // MARK: - Properties
    
    fileprivate let mainPage = MainPageViewController()
    fileprivate let calendar = CalendarViewController()
    fileprivate let diary = DiaryListViewController()
    fileprivate let setting = SettingViewController()
    
    private lazy var pages: [UIViewController] = [
        mainPage,
        calendar,
        diary,
        setting
    ]
    
    private var isScrolling: Bool = false
    
    // MARK: - VC LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        
        setViewControllers([pages[0]], direction: .forward, animated: false)
        
        // 스와이프(스크롤) 비활성화
        if let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            scrollView.isScrollEnabled = false
        }
    }
    
    /// 현재 보여지는 페이지를 변경하는 메소드
    /// - Parameter state: 변경할 페이지의 state
    func changePage(to state: TabBarButtonState, _ completion: @escaping () -> Void) {
        guard !isScrolling,
              let index = TabBarButtonState.allCases.firstIndex(of: state),
              index < pages.count,
              let currentVC = viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentVC),
              index != currentIndex else { return }
        
        isScrolling = true
        
        let direction: UIPageViewController.NavigationDirection = (index > currentIndex) ? .forward : .reverse
        setViewControllers([pages[index]], direction: direction, animated: true) { completed in
            self.isScrolling = false
            completion()
        }
    }
    
    func mainPageFetch() {
        mainPage.fetch()
    }
}

// MARK: - UIPageViewControllerDataSource Method

extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
        return pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }
}

// MARK: - Reactive Extension

extension Reactive where Base: PageViewController {
    var calendarDataRelay: PublishRelay<Void> {
        base.calendar.rx.calendarDataRelay
    }
    
    var diaryDataRelay: PublishRelay<Void> {
        base.diary.rx.diaryDataRelay
    }
    
    var settingDataRelay: PublishRelay<Void> {
        base.setting.rx.settingDataRelay
    }
}
