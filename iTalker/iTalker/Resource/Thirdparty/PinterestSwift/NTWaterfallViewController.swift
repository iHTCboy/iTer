//
//  ViewController.swift
//  PinterestSwift
//
//  Created by Nicholas Tau on 6/30/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

import UIKit
import Kingfisher

let waterfallViewCellIdentify = "waterfallViewCellIdentify"

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?{
        
        let fromVCConfromA = (fromVC as? NTTransitionProtocol)
        let fromVCConfromB = (fromVC as? NTWaterFallViewControllerProtocol)
        let fromVCConfromC = (fromVC as? NTHorizontalPageViewControllerProtocol)
        
        let toVCConfromA = (toVC as? NTTransitionProtocol)
        let toVCConfromB = (toVC as? NTWaterFallViewControllerProtocol)
        let toVCConfromC = (toVC as? NTHorizontalPageViewControllerProtocol)
        if((fromVCConfromA != nil)&&(toVCConfromA != nil)&&(
            (fromVCConfromB != nil && toVCConfromC != nil)||(fromVCConfromC != nil && toVCConfromB != nil))){
            let transition = NTTransition()
            transition.presenting = operation == .pop
            return  transition
        }else{
            return nil
        }
        
    }
}

class NTWaterfallViewController:UICollectionViewController {
//    class var sharedInstance: NSInteger = 0 Are u kidding me?
    
    var sizeLayout : Array <CGSize> = []
    let delegateHolder = NavigationControllerDelegate()
    lazy var listModel: ITPictureQuestionListModel = {
        return self.getModel(title: "PictureQuestion")
    }()
    
    lazy var rightItem :UIBarButtonItem = {
        let item = UIBarButtonItem.init(title: "关闭", style: .plain, target: self, action:#selector(didCloseVC))
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in self.listModel.result {
            sizeLayout.append(CGSize.init(width: gridWidth, height: gridWidth))
        }
        
        self.navigationController!.delegate = delegateHolder
        
        navigationItem.rightBarButtonItem = self.rightItem
        self.view.backgroundColor = kColorCellBg
        
        let collection :UICollectionView = collectionView!;
        collection.frame = screenBounds
        collection.setCollectionViewLayout(CHTCollectionViewWaterfallLayout(), animated: false)
        collection.backgroundColor = kColorCellBg
        if #available(iOS 10.0, tvOS 10.0, *) {
            collection.prefetchDataSource = self
        }
        collection.register(NTWaterfallViewCell.self, forCellWithReuseIdentifier: waterfallViewCellIdentify)
        collection.reloadData()
    }
    
    //视图显示时
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //隐藏导航栏
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension NTWaterfallViewController
{
    @objc func didCloseVC() {
        self.dismiss(animated: true, completion: nil);
    }
    
    public func getModel(title: String) -> ITPictureQuestionListModel {
        if let file = Bundle.main.url(forResource: title, withExtension: "json") {
            do {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    // json is a dictionary
                    
                    let model = ITPictureQuestionListModel.init(dictionary: object)
                    return model
                    
                } else {
                    print("JSON is invalid")
                    return ITPictureQuestionListModel();
                }
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("no file")
            return ITPictureQuestionListModel()
        }
        return ITPictureQuestionListModel()
    }
    
    override func scrollViewWillBeginDecelerating(_ scrollView : UIScrollView){
        

    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < KColseVCMaginHeight{
            didCloseVC()
        }
    }
    
}

extension NTWaterfallViewController: CHTCollectionViewDelegateWaterfallLayout, NTTransitionProtocol, NTWaterFallViewControllerProtocol
{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize{
        //        let image:UIImage! = UIImage(named: self.imageNameList[indexPath.row] as String)
        //let imageHeight = image.size.height * gridWidth/image.size.width
        //        let diceRoll = CGFloat(arc4random_uniform(UInt32(gridWidth)) + UInt32(gridWidth))
        let size = self.sizeLayout[indexPath.row]
        return CGSize(width: gridWidth, height: size.height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // This will cancel all unfinished downloading task when the cell disappearing.
        (cell as! NTWaterfallViewCell).imageViewContent.kf.cancelDownloadTask()
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    
        collectionView.collectionViewLayout.invalidateLayout()
        
        let model = self.listModel.result[indexPath.row]
        let url = URL(string: model.pictureURL)!
        (cell as! NTWaterfallViewCell).typeLbl.text = model.pictype
        
        _ = (cell as! NTWaterfallViewCell).imageViewContent.kf.setImage(with: url, placeholder: UIImage.init(named: "iTalker_TextLogo"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
            
        }, completionHandler: { image, error, cacheType, imageURL in
            
            if let size = image?.size {
                let imageHeight = size.height * gridWidth/size.width
                let size1 = CGSize.init(width: gridWidth, height: imageHeight)
                let size2 = self.sizeLayout[indexPath.row]
                if !__CGSizeEqualToSize(size1, size2) {
                    
                    self.sizeLayout[indexPath.row] = CGSize.init(width: gridWidth, height: imageHeight)
                    collectionView.collectionViewLayout.invalidateLayout()
                    
                }
                
            }
            
            //self.displayCellAnimation(cell.contentView)
        })
    }
    
    //动画
    func displayCellAnimation(_ view:UIView){
        view.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 7, options: UIView.AnimationOptions.curveEaseIn, animations: { () -> Void in
            view.transform = CGAffineTransform.identity
            
        }) { (success) -> Void in
            
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: NTWaterfallViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: waterfallViewCellIdentify, for: indexPath) as! NTWaterfallViewCell
        cell.imageViewContent.kf.indicatorType = .activity
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.listModel.result.count;
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        let pageViewController =
            NTHorizontalPageViewController(collectionViewLayout: pageViewControllerLayout(), currentIndexPath:indexPath)
        pageViewController.imagesModel = self.listModel
        collectionView.setToIndexPath(indexPath)
        pageViewController.title = self.listModel.result[indexPath.row].pictype
        navigationController!.pushViewController(pageViewController, animated: true)
    }
    
    func pageViewControllerLayout () -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        let itemSize  = self.navigationController!.isNavigationBarHidden ?
            CGSize(width: screenWidth, height: screenHeight) : CGSize(width: screenWidth, height: screenHeight)
        flowLayout.itemSize = itemSize
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        return flowLayout
    }
    
    func viewWillAppearWithPageIndex(_ pageIndex: NSInteger) {
        var position: UICollectionView.ScrollPosition =
            UICollectionView.ScrollPosition.centeredHorizontally.intersection(.centeredVertically)
        var image: UIImage? = nil
        // cell reuse
        if let cell = self.collectionView?.cellForItem(at: IndexPath.init(row: pageIndex, section: 0)) as? NTWaterfallViewCell {
            image = cell.imageViewContent.image
        }else{
            let model = self.listModel.result[pageIndex]
            let url = URL(string: model.pictureURL)!
            KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil, completionHandler: { (images, error, CacheType, URL) in
                if let img = images{
                    image = img
                }
            })
        }
        
        if image == nil {
            image = UIImage.init(named: "iTalker_TextLogo")
        }
        
        let imageHeight = image!.size.height*gridWidth/image!.size.width
        if imageHeight > 400 {//whatever you like, it's the max value for height of image
            position = .top
        }
        let currentIndexPath = IndexPath(row: pageIndex, section: 0)
        let collectionView = self.collectionView!;
        collectionView.setToIndexPath(currentIndexPath)
        if pageIndex < 2 {
            collectionView.setContentOffset(CGPoint.zero, animated: false)
        } else {
            collectionView.scrollToItem(at: currentIndexPath, at: position, animated: false)
        }
    }
    
    func transitionCollectionView() -> UICollectionView!{
        return collectionView
    }
    
}

extension NTWaterfallViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap {
            URL(string: self.listModel.result[$0.row].pictureURL as String)
        }
        ImagePrefetcher(urls: urls).start()
    }
}

