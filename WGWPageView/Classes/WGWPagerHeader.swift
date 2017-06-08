//
//  WGWPagerHeader.swift
//  WGWPager
//
//  Created by Matija Kruljac on 6/2/17.
//  Copyright © 2017 Matija Kruljac. All rights reserved.
//

import Foundation
import UIKit

protocol WGWPagerHeaderDelegate: class {
    
    func scrollOnHeaderTitleTap(to index: Int, in direction: UIPageViewControllerNavigationDirection)
    func syncCurrentViewControllerAndTitleHeader(for index: Int)
}

public struct WGWPagerHeaderTitleColors {
    public var selectedTitleColor: UIColor = .red
    public var unselectedTitleColor: UIColor = .black
    
    public init(withSelectedTitleColor selectedColor: UIColor, withUnselectedTitleColor unselectedColor: UIColor) {
        self.selectedTitleColor = selectedColor
        self.unselectedTitleColor = unselectedColor
    }
}

class WGWPagerHeader: UIScrollView, UIScrollViewDelegate {
    
    weak var wgwPagerHeaderDelegate: WGWPagerHeaderDelegate?
    
    private var finalWidth: CGFloat = 0.0
    private var titleLabels = [UILabel]()
    private var titleWidths = [CGFloat]()
    private(set) var currentTitleLabelIndex = 0
    
    var wgwPagerHeaderTitleColors: WGWPagerHeaderTitleColors!
    var font: UIFont?
    var dataSource: [String]? {
        didSet {
            guard let dataSource = dataSource,
                  let font = font
            else { return }
            for title in dataSource {
                titleWidths.append(title.width(withConstrainedHeight: frame.size.height, font: font))
            }
            guard let longestTitleString = titleWidths.max() else { return }
            generateTitleViewsForPages(with: longestTitleString)
            addBottomBorder()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isScrollEnabled = false
        canCancelContentTouches = false
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isScrollEnabled = false
        canCancelContentTouches = false
        delegate = self
    }
    
    private func addBottomBorder() {
        let bottomBorder = UIView(frame:
            CGRect(x: 0,
                   y: frame.origin.y+frame.size.height-1,
                   width: contentSize.width,
                   height: contentSize.height-1))
        bottomBorder.backgroundColor = .gray
        addSubview(bottomBorder)
    }
    
    func changeTitleColor(at index: Int) {
        for (loopIndex, titleLabel) in titleLabels.enumerated() {
            if loopIndex == index {
                titleLabel.textColor = wgwPagerHeaderTitleColors.selectedTitleColor
            } else {
                titleLabel.textColor = wgwPagerHeaderTitleColors.unselectedTitleColor
            }
        }
    }
    
    func scrollToTheTitle(at index: Int) {
        guard let dataSource = dataSource else { return }
        guard let longestTitleString = titleWidths.max() else { return }
        if frame.size.width > longestTitleString * CGFloat(dataSource.count) { return }

        if index == titleLabels.count - 1 {
            let bottomOffset = CGPoint(x: contentSize.width-bounds.size.width, y: frame.origin.y)
            setContentOffset(bottomOffset, animated: true)
        } else if (index == 0) {
            let titleLabel = titleLabels[index]
            scrollRectToVisible(titleLabel.frame, animated: true)
        } else if currentTitleLabelIndex > index {
            let titleLabel = titleLabels[index]
            let frame = CGRect(
                x: titleLabel.frame.origin.x-titleLabel.frame.size.width/1.5,
                y: frame.origin.y,
                width: titleLabel.frame.size.width,
                height: titleLabel.frame.size.height)
            scrollRectToVisible(frame, animated: true)
        } else {
            let titleLabel = titleLabels[index]
            let frame = CGRect(
                x: titleLabel.frame.origin.x+titleLabel.frame.size.width/1.5,
                y: frame.origin.y,
                width: titleLabel.frame.size.width,
                height: titleLabel.frame.size.height)
            scrollRectToVisible(frame, animated: true)
        }
        currentTitleLabelIndex = index
    }
    
    private func sumAllTitleLabelWidths() -> CGFloat {
        var sum: CGFloat = 0.0
        for titleLabel in titleLabels {
            sum += titleLabel.frame.size.width
        }
        return sum
    }
    
    private func generateTitleViewsForPages(with longestTitleString: CGFloat) {
        guard let dataSource = dataSource else { return }

        if frame.size.width > longestTitleString * CGFloat(dataSource.count) {
            finalWidth = frame.size.width / CGFloat(dataSource.count)
        } else {
            finalWidth = longestTitleString
        }
        contentSize = CGSize(width: finalWidth * CGFloat(dataSource.count), height: frame.size.height)
        
        for (index, title) in dataSource.enumerated() {
            let titleLabel = UILabel(frame: CGRect(
                x: CGFloat(index) * finalWidth,
                y: 0,
                width: finalWidth,
                height: frame.size.height))
            titleLabel.textAlignment = .center
            titleLabel.text = title
            titleLabel.tag = index
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleHeaderLabelTap(_:)))
            tapGestureRecognizer.numberOfTapsRequired = 1
            tapGestureRecognizer.numberOfTouchesRequired = 1
            titleLabel.isUserInteractionEnabled = true
            titleLabel.addGestureRecognizer(tapGestureRecognizer)
            
            titleLabels.append(titleLabel)
            addSubview(titleLabel)
        }
    }
    
    @objc func handleHeaderLabelTap(_ tapGestureRecognizer: UITapGestureRecognizer) {
        guard let titleLabel = tapGestureRecognizer.view else { return }
        if currentTitleLabelIndex > titleLabel.tag {
            wgwPagerHeaderDelegate?.scrollOnHeaderTitleTap(to: titleLabel.tag, in: .reverse)
        } else {
            wgwPagerHeaderDelegate?.scrollOnHeaderTitleTap(to: titleLabel.tag, in: .forward)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        wgwPagerHeaderDelegate?.syncCurrentViewControllerAndTitleHeader(for: currentTitleLabelIndex)
    }
}

extension String {
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.width + 40
    }
}

extension NSAttributedString {
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return boundingBox.width
    }
}
