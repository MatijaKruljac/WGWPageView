//
//  WGWPageViewController.swift
//  WGWPager
//
//  Created by Matija Kruljac on 6/1/17.
//  Copyright © 2017 Matija Kruljac. All rights reserved.
//

import Foundation
import UIKit

public class WGWPagerView: UIView, UIPageViewControllerDelegate, UIPageViewControllerDataSource, WGWPagerHeaderDelegate {

    private var pager: UIPageViewController!
    private var pagerHeader: WGWPagerHeader!
    
    private var pageViewControllerSupportedInterfaceOrientations: UIInterfaceOrientationMask?
    private var pageViewControllerPreferredInterfaceOrientationForPresentation: UIInterfaceOrientation?
    private var spineLocationForOrientation: UIPageViewControllerSpineLocation?
    private var indexOfNextTitle = 0
    private var indexOfViewController = 0
    private var isTransitionInProgress = false
    
    public var dataSource: [UIViewController]? {
        didSet {
            guard let dataSource = dataSource else { return }
            let currentViewController = dataSource[indexOfViewController]
            pager.setViewControllers([currentViewController],
                                     direction: .forward,
                                     animated: true,
                                     completion: nil)
            pagerHeader.changeTitleColor(at: 0)
        }
    }

    public init(with frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func setupPagerWithHeader(transitionStyle: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation,
                              options: [String : Any]?, headerHeight: CGFloat) {
        pagerHeader = WGWPagerHeader(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: headerHeight))
        addSubview(pagerHeader)
        
        pager = UIPageViewController(transitionStyle: transitionStyle, navigationOrientation: navigationOrientation, options: options)
        pager.view.frame = CGRect(x: 0, y: headerHeight, width: frame.size.width, height: frame.size.height - 40)
        pager.delegate = self
        pager.dataSource = self
        addSubview(pager.view)
        
        pagerHeader.wgwPagerHeaderDelegate = self
    }
    
    public func setupPagerHeder(titles: [String], with font: UIFont, andWith colors: WGWPagerHeaderTitleColors) {
        pagerHeader.font = font
        pagerHeader.dataSource = titles
        pagerHeader.wgwPagerHeaderTitleColors = colors
    }
    
    public func setupPageViewControllerSupportedInterfaceOrientations(_ interfaceOrientationMask: UIInterfaceOrientationMask) {
        pageViewControllerSupportedInterfaceOrientations = interfaceOrientationMask
    }
    
    public func setupPageViewControllerPreferredInterfaceOrientationForPresentation(_ interfaceOrientation: UIInterfaceOrientation) {
        pageViewControllerPreferredInterfaceOrientationForPresentation = interfaceOrientation
    }
    
    public func setupSpineLocationForOrientation(_ spineLocation: UIPageViewControllerSpineLocation) {
        spineLocationForOrientation = spineLocation
    }
    
    // mark: UIPageViewControllerDelegate
    
    public func pageViewControllerSupportedInterfaceOrientations(_ pageViewController: UIPageViewController) -> UIInterfaceOrientationMask {
        guard let pageViewControllerSupportedInterfaceOrientations = pageViewControllerSupportedInterfaceOrientations else { return .all }
        return pageViewControllerSupportedInterfaceOrientations
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                                     previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            pagerHeader.changeTitleColor(at: indexOfNextTitle)
            pagerHeader.scrollToTheTitle(at: indexOfNextTitle)
            indexOfViewController = indexOfNextTitle
            isTransitionInProgress = false
        }
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let dataSource = dataSource else { return }
        if let indexOfNextTitle = dataSource.index(of: pendingViewControllers[0]) {
            self.indexOfNextTitle = indexOfNextTitle
            isTransitionInProgress = true
        }
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        guard let spineLocationForOrientation = spineLocationForOrientation else { return .none }
        return spineLocationForOrientation
    }
    
    public func pageViewControllerPreferredInterfaceOrientationForPresentation(_ pageViewController: UIPageViewController) -> UIInterfaceOrientation {
        guard let pageViewControllerPreferredInterfaceOrientationForPresentation = pageViewControllerPreferredInterfaceOrientationForPresentation else { return .portrait }
        return pageViewControllerPreferredInterfaceOrientationForPresentation
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let dataSource = dataSource else { return nil }
        
        if indexOfViewController < dataSource.count-1 {
            return dataSource[indexOfViewController+1]
        }
        return nil
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let dataSource = dataSource else { return nil }

        if indexOfViewController > 0 {
            return dataSource[indexOfViewController-1]
        }
        return nil
    }

    // MARK: - WGWPagerHeaderDelegate
    
    func scrollOnHeaderTitleTap(to index: Int, in direction: UIPageViewControllerNavigationDirection) {
        guard let dataSource = dataSource else { return }
        indexOfViewController = index
        let currentViewController = dataSource[index]
        pager.setViewControllers([currentViewController],
                                 direction: direction,
                                 animated: true,
                                 completion: nil)
        pagerHeader.changeTitleColor(at: index)
        pagerHeader.scrollToTheTitle(at: index)
    }
    
    func syncCurrentViewControllerAndTitleHeader(for index: Int) {
        guard let dataSource = dataSource else { return }
        if isTransitionInProgress { return }
        
        let currentViewController = dataSource[indexOfViewController]
        pager.setViewControllers([currentViewController],
                                 direction: .reverse,
                                 animated: true,
                                 completion: nil)
        pagerHeader.changeTitleColor(at: index)
        pagerHeader.scrollToTheTitle(at: index)
    }
}
