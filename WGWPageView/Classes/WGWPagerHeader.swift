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

class WGWPagerHeader: UIScrollView, UIScrollViewDelegate {
    
    weak var wgwPagerHeaderDelegate: WGWPagerHeaderDelegate?
    
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
            generateTitleViewsForPages()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        canCancelContentTouches = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        canCancelContentTouches = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        delegate = self
    }
    
    func addBottomSeparator(with height: CGFloat? = nil, andWith color: UIColor? = nil) {
        var bottomSeparatorFrame: CGRect!
        if let height = height {
            bottomSeparatorFrame = CGRect(
                x: 0,
                y: frame.origin.y+frame.size.height-height,
                width: contentSize.width,
                height: height)
        } else {
            bottomSeparatorFrame = CGRect(
                x: 0,
                y: frame.origin.y+frame.size.height-1.0,
                width: contentSize.width,
                height: 1.0)
        }
        let bottomSeparator = UIView(frame: bottomSeparatorFrame)
        if let color = color {
            bottomSeparator.backgroundColor = color
        } else {
            bottomSeparator.backgroundColor = .gray
        }
        addSubview(bottomSeparator)
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
        if currentTitleLabelIndex == index { return }
        if frame.size.width > longestTitleString * CGFloat(dataSource.count) { return }
        
        if index >= titleLabels.count-2 {
            let bottomOffset = CGPoint(x: contentSize.width-bounds.size.width, y: frame.origin.y)
            setContentOffset(bottomOffset, animated: true)
        } else if (index == 0) {
            let offset = CGPoint(x: 0, y: frame.origin.y)
            setContentOffset(offset, animated: true)
        } else {
            let titleLabel = titleLabels[index]
            let offset = CGPoint(x: titleLabel.frame.origin.x, y: frame.origin.y)
            setContentOffset(offset, animated: true)
        }
        
        currentTitleLabelIndex = index
    }
    
    private func sumAllTitleLabelWidths() -> CGFloat {
        var sum: CGFloat = 0.0
        for titleWidth in titleWidths {
            sum += titleWidth
        }
        return sum
    }
    
    private func sumAllTitleLabelWidths(to index: Int) -> CGFloat {
        var sum: CGFloat = 0.0
        if index <= 0 { return sum }
        for counter in 0...index-1 {
            sum += titleWidths[counter]
        }
        return sum
    }
    
    private func generateTitleViewsForPages() {
        guard let dataSource = dataSource else { return }
        
        var finalWidth: CGFloat?
        if frame.size.width > sumAllTitleLabelWidths() {
            finalWidth = frame.size.width / CGFloat(dataSource.count)
            contentSize = CGSize(width: frame.size.width, height: frame.size.height)
        } else {
            contentSize = CGSize(width: sumAllTitleLabelWidths(), height: frame.size.height)
        }
        
        for (index, title) in dataSource.enumerated() {
            let titleLabel = UILabel(frame: generateFrameForTitleLabel(for: index, with: finalWidth))
            titleLabel.textAlignment = .center
            titleLabel.text = title
            titleLabel.tag = index
            titleLabel.font = font
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleHeaderLabelTap(_:)))
            tapGestureRecognizer.numberOfTapsRequired = 1
            tapGestureRecognizer.numberOfTouchesRequired = 1
            titleLabel.isUserInteractionEnabled = true
            titleLabel.addGestureRecognizer(tapGestureRecognizer)
            
            titleLabels.append(titleLabel)
            addSubview(titleLabel)
        }
    }
    
    private func generateFrameForTitleLabel(for index: Int, with finalWidth: CGFloat?) -> CGRect {
        if let finalWidth = finalWidth {
            return CGRect(
                x: CGFloat(index) * finalWidth,
                y: 0,
                width: finalWidth,
                height: frame.size.height)
        }
        return CGRect(
            x: sumAllTitleLabelWidths(to: index),
            y: 0,
            width: titleWidths[index],
            height: frame.size.height)
    }
    
    @objc func handleHeaderLabelTap(_ tapGestureRecognizer: UITapGestureRecognizer) {
        guard let titleLabel = tapGestureRecognizer.view else { return }
        if currentTitleLabelIndex > titleLabel.tag {
            wgwPagerHeaderDelegate?.scrollOnHeaderTitleTap(to: titleLabel.tag, in: .reverse)
        } else {
            wgwPagerHeaderDelegate?.scrollOnHeaderTitleTap(to: titleLabel.tag, in: .forward)
        }
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        contentOffset = CGPoint(x: contentOffset.x, y: 0)
        if contentOffset.x < 0 {
            contentOffset = CGPoint(x: 0, y: 0)
        }
        if contentOffset.x > contentSize.width-bounds.size.width {
            contentOffset = CGPoint(x: contentSize.width-bounds.size.width, y: 0)
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
