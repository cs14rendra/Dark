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
    case map
}
class PageViewController: ButtonBarPagerTabStripViewController  {

   var isLoadedFirstTime = false
    
    override func viewDidLoad() {
            settings.style.buttonBarBackgroundColor = DARKPINK
            settings.style.buttonBarItemBackgroundColor = DARKPINK
             settings.style.selectedBarHeight = 2.0

        super.viewDidLoad()
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .black;       newCell?.label.textColor = .white
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isLoadedFirstTime {
            moveToViewController(at: 1)
            self.isLoadedFirstTime = true
        }
    }
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let child_0 = UIStoryboard(name: storyBoardName, bundle: nil).instantiateViewController(withIdentifier: ControllerIdentifire.map.rawValue)
        let child_1 = UIStoryboard(name: storyBoardName, bundle: nil).instantiateViewController(withIdentifier: ControllerIdentifire.chat.rawValue)
        let child_2 = UIStoryboard(name: storyBoardName, bundle: nil).instantiateViewController(withIdentifier: ControllerIdentifire.main.rawValue)
        return [child_0,child_2,child_1]
    }
}
