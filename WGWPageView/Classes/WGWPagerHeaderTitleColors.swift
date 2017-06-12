//
//  WGWPagerHeaderTitleColors.swift
//  Pods
//
//  Created by Matija Kruljac on 6/12/17.
//
//

import Foundation
import UIKit

public struct WGWPagerHeaderTitleColors {
    public var selectedTitleColor: UIColor = .red
    public var unselectedTitleColor: UIColor = .black
    
    public init(withSelectedTitleColor selectedColor: UIColor, withUnselectedTitleColor unselectedColor: UIColor) {
        self.selectedTitleColor = selectedColor
        self.unselectedTitleColor = unselectedColor
    }
}
