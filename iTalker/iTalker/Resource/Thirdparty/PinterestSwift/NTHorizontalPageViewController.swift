//
//  NTHorizontalPageViewController.swift
//  PinterestSwift
//
//  Created by Nicholas Tau on 7/1/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

import Foundation
import UIKit

let horizontalPageViewCellIdentify = "horizontalPageViewCellIdentify"

class NTHorizontalPageViewController : UICollectionViewController
{
    
    var imagesModel : ITPictureQuestionListModel = ITPictureQuestionListModel()
    var pullOffset = CGPoint.zero
    var rightItem :UIBarButtonItem = {
        let item = UIBarButtonItem.init(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        item.isEnabled = false
        return item
    }()
    
    init(collectionViewLayout layout: UICollectionViewLayout!, currentIndexPath indexPath: IndexPath){
        super.init(collectionViewLayout:layout)
        let collectionView :UICollectionView = self.collectionView!;
        collectionView.isPagingEnabled = true
        collectionView.contentInset = UIEdgeInsetsMake(-64, 0, -44, 0)
        collectionView.register(NTHorizontalPageViewCell.self, forCellWithReuseIdentifier: horizontalPageViewCellIdentify)
        collectionView.setToIndexPath(indexPath)
        collectionView.performBatchUpdates({collectionView.reloadData()}, completion: { finished in
            if finished {
                collectionView.scrollToItem(at: indexPath,at:.centeredHorizontally, animated: false)
            }});
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.rightBarButtonItem = self.rightItem
    }
    
}

extension NTHorizontalPageViewController
{
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "保存失败", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "保存成功!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true, completion: nil)
        }
    }
}


extension NTHorizontalPageViewController: NTTransitionProtocol ,NTHorizontalPageViewControllerProtocol
{
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let collectionCell: NTHorizontalPageViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: horizontalPageViewCellIdentify, for: indexPath) as! NTHorizontalPageViewCell
        //        collectionCell.imageName = self.imageNameList[indexPath.row] as String
        let model = self.imagesModel.result[indexPath.row]
        collectionCell.imageURL = model.pictureURL
        collectionCell.tappedAction = { isScale in
            //显示或隐藏导航栏
            if let nav = self.navigationController {
                if isScale {
                    nav.setNavigationBarHidden(isScale, animated: true)
                }else{
                    nav.setNavigationBarHidden(!nav.isNavigationBarHidden, animated: true)
                }
            }
        }
        collectionCell.longTappedAction = { image in
            
            let ac = UIAlertController(title: "保存照片到相册", message: "保存这张图片吗", preferredStyle: .alert)
            ac.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { (action) in
                
            }))
            ac.addAction(UIAlertAction.init(title: "保存", style: .default, handler: { (action) in
                
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }))
            
            self.present(ac, animated: true, completion: nil)
        }
        collectionCell.pullAction = { offset in
            self.pullOffset = offset
            self.navigationController!.popViewController(animated: true)
        }
        collectionCell.setNeedsLayout()
        return collectionCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return imagesModel.result.count;
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        let cell = cell as! NTHorizontalPageViewCell
        cell.resetSize()
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.title = self.imagesModel.result[indexPath.row].pictype
        self.rightItem.title = "\(indexPath.row+1)/\(self.imagesModel.result.count)"
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = Int(scrollView.contentOffset.x / screenWidth)
        self.rightItem.title = "\(offset+1)/\(self.imagesModel.result.count)"
    }
    
    func transitionCollectionView() -> UICollectionView!{
        return collectionView
    }
    
    func pageViewCellScrollViewContentOffset() -> CGPoint{
        return self.pullOffset
    }
}
