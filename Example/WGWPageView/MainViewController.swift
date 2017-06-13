//
//  ViewController.swift
//  WGWPager
//
//  Created by Matija Kruljac on 6/1/17.
//  Copyright © 2017 Matija Kruljac. All rights reserved.
//

import UIKit
import WGWPageView

class MainViewController: UIViewController {
    
    @IBOutlet weak var wgwPagerView: WGWPagerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let wgwPagerView = WGWPagerView(with:
//            CGRect(
//                x: 0,
//                y: 100,
//                width: view.frame.size.width,
//                height: view.frame.size.height - 100))
        
        wgwPagerView.setupWith(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: [:],
            headerHeight: 60)
        
        let wgwPagerHeaderTitleColors = WGWPagerHeaderTitleColors(
            withSelectedTitleColor: UIColor(red: 0.0902, green: 0.5608, blue: 0.4667, alpha: 1.0),
            withUnselectedTitleColor: .black)
        
        guard let font = UIFont(name: "HelveticaNeue-Medium", size: 14) else { return }
        
        wgwPagerView.setupHeaderWith(
            titles: ["ViewController 1", "ViewController 2", "ViewController 3", "ViewController 4", "ViewController 5"],
            with: font,
            andWith: wgwPagerHeaderTitleColors)
        
        wgwPagerView.dataSource = generateViewControllers()
        
        view.addSubview(wgwPagerView)
    }
    
    private func generateViewControllers() -> [UIViewController] {
        var viewControllers = [UIViewController]()
        
        guard let storyboard = storyboard else { return [] }
        let firstViewController = storyboard.instantiateViewController(withIdentifier: "FirstViewController")
        let secondViewController = storyboard.instantiateViewController(withIdentifier: "SecondViewController")
        let thirdViewController = storyboard.instantiateViewController(withIdentifier: "ThirdViewController")
        let fourthViewController = storyboard.instantiateViewController(withIdentifier: "FourthViewController")
        let fifthViewController = storyboard.instantiateViewController(withIdentifier: "FifthViewController")
        
        viewControllers.append(firstViewController)
        viewControllers.append(secondViewController)
        viewControllers.append(thirdViewController)
        viewControllers.append(fourthViewController)
        viewControllers.append(fifthViewController)
        
        return viewControllers
    }
}
