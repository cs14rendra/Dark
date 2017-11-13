//
//  segueAnimation.swift
//  Dark
//
//  Created by surendra kumar on 10/11/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit

class lefttoRight: UIStoryboardSegue {
    
    override func perform()
    {
        let src = self.source
        let dst = self.destination
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        
        dst.view.transform = CGAffineTransform(translationX: src.view.bounds.width, y: 0)
        
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        dst.view.transform = .identity
        },
                       completion: { finished in
                        src.present(dst, animated: false, completion: nil)
                        
        }
        )
    }
    
}
