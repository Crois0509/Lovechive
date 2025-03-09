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

final class PageViewController: UIPageViewController {
    private var disposeBag = DisposeBag()
    fileprivate let currentPageIndex = PublishRelay<Int>()
    
    private let pages: [UIViewController] = [
        TestHomeViewController(),
        TestCalendarViewController(),
        TestDiaryViewController(),
        TestSettingViewController()
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        setViewControllers([pages[0]], direction: .forward, animated: false)
    }
    
    func changePage(to state: TabBarButtonState) {
        let index = Int(TabBarButtonState.allCases.firstIndex(of: state) ?? 0)
        guard let currentVC = viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentVC),
              index != currentIndex else { return }
        
        let direction: UIPageViewController.NavigationDirection = (index > currentIndex) ? .forward : .reverse
        setViewControllers([pages[index]], direction: direction, animated: true, completion: nil)
    }
}

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

extension PageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentVC = viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentVC)
        else { return }
        
        currentPageIndex.accept(currentIndex)
    }
}

extension Reactive where Base: PageViewController {
    var currentPage: PublishRelay<Int> {
        base.currentPageIndex
    }
}

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
