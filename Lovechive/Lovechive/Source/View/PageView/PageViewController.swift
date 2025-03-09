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
    fileprivate let currentPageIndex = PublishRelay<Int>()
    
    // MARK: - Properties
    
    private let pages: [UIViewController] = [
        TestHomeViewController(),
        TestCalendarViewController(),
        TestDiaryViewController(),
        TestSettingViewController()
    ]
    
    // MARK: - VC LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        setViewControllers([pages[0]], direction: .forward, animated: false)
    }
    
    /// 현재 보여지는 페이지를 변경하는 메소드
    /// - Parameter state: 변경할 페이지의 state
    func changePage(to state: TabBarButtonState) {
        let index = Int(TabBarButtonState.allCases.firstIndex(of: state) ?? 0)
        guard let currentVC = viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentVC),
              index != currentIndex else { return }
        
        let direction: UIPageViewController.NavigationDirection = (index > currentIndex) ? .forward : .reverse
        setViewControllers([pages[index]], direction: direction, animated: true, completion: nil)
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

// MARK: - UIPageViewControllerDelegate Method

extension PageViewController: UIPageViewControllerDelegate {
    // 페이지 변환이 완료되면 호출되는 메소드
    // 편경된 페이지의 인덱스를 이벤트로 전달
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentVC = viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentVC)
        else { return }
        
        currentPageIndex.accept(currentIndex)
    }
}

// MARK: - Reactive Extension

extension Reactive where Base: PageViewController {
    // 현재 페이지 인덱스를 이벤트로 전달
    var currentPage: PublishRelay<Int> {
        base.currentPageIndex
    }
}

// MARK: - TestViewControllers

final class TestHomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
}
final class TestCalendarViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
    }
}
final class TestDiaryViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
    }
}
final class TestSettingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
    }
}
