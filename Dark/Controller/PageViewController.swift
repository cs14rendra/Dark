//
//  PageViewController.swift
//  Dark
//
//  Created by surendra kumar on 10/7/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit
import XLPagerTabStrip

private let storyBoardName = "Main"
private enum ControllerIdentifire : String{
    case main
    case chat
}
class PageViewController: ButtonBarPagerTabStripViewController  {

  let purpleInspireColor = UIColor(red:0.13, green:0.03, blue:0.25, alpha:1.0)
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = UIColor.darkText
        settings.style.buttonBarItemBackgroundColor = DARKPINK
        settings.style.selectedBarBackgroundColor = purpleInspireColor
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = UIColor.white
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        super.viewDidLoad()
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .black;       newCell?.label.textColor = .white
        }
    }
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = UIStoryboard(name: storyBoardName, bundle: nil).instantiateViewController(withIdentifier: ControllerIdentifire.chat.rawValue)
        let child_2 = UIStoryboard(name: storyBoardName, bundle: nil).instantiateViewController(withIdentifier: ControllerIdentifire.main.rawValue)
        return [child_2,child_1]
    }
}
