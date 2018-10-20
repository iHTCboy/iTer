//
//  NTNavigationController.swift
//  PinterestSwift
//
//  Created by Nicholas Tau on 7/2/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

import Foundation
import UIKit
class NTNavigationController : UINavigationController{
    override func popViewController(animated: Bool) -> UIViewController
    {
        //viewWillAppearWithPageIndex
        let childrenCount = self.viewControllers.count
        let toViewController = self.viewControllers[childrenCount-2] as! NTWaterFallViewControllerProtocol
        let toView = toViewController.transitionCollectionView()
        let popedViewController = self.viewControllers[childrenCount-1] as! UICollectionViewController
        let popView  = popedViewController.collectionView!;
        let indexPath = popView.fromPageIndexPath()
        toViewController.viewWillAppearWithPageIndex(indexPath.row)
        toView?.setToIndexPath(indexPath)
        return super.popViewController(animated: animated)!
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated);
        
        // set tint
        navigationBar.tintColor = UIColor.white
        if let view = navigationBar.subviews.first {
            view.alpha = 0.7
        }
        let titleDict = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationBar.titleTextAttributes = titleDict
    }
    
//    override func pushViewController(viewController: UIViewController!, animated: Bool) {
//        let childrenCount = self.viewControllers.count
//        let toView = viewController.view
//        let currentView = self.viewControllers[childrenCount-1].view
////        if toView is UICollectionView && currentView is UICollectionView{
////            let currentIndexPath = (currentView as UICollectionView).currentIndexPath()
////            (toView as UICollectionView).setCurrentIndexPath(currentIndexPath)
////        }
//        super.pushViewController(viewController, animated: animated)
//    }
}
