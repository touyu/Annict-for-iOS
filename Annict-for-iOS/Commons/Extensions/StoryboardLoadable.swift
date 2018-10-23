//
//  UIStoryboard.swift
//  Annict-for-iOS
//
//  Created by Yuto Akiba on 2018/10/23.
//  Copyright © 2018 Yuto Akiba. All rights reserved.
//

import UIKit

extension UIViewController: StoryboardLoadable {}

public protocol StoryboardLoadable {}

public extension StoryboardLoadable where Self: UIViewController {

    static func loadStoryboard() -> Self {
        let storyboard = UIStoryboard(name: className, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: className) as! Self
    }

    static func loadStoryboard(storyboardName: String) -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: className) as! Self
    }
}

