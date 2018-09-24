//
//  NTHorizontalPageViewCell.swift
//  PinterestSwift
//
//  Created by Nicholas Tau on 7/1/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

import Foundation
import UIKit

class NTHorizontalPageViewCell : UICollectionViewCell {
    //var imageName : String?
    var imageURL: String = ""
    {
        didSet
        {
            let url = URL.init(string: imageURL)
            imageView.kf.setImage(with: url, placeholder: Image.init(named: "iTalker_TextLogo"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                
            }, completionHandler: { image, error, cacheType, imageURL in
                
            })
        }
    }
    var pullAction : ((_ offset : CGPoint) -> Void)?
    var tappedAction : ((_ isSacle : Bool) -> Void)?
    var longTappedAction : ((_ image : Image) -> Void)?
    lazy var imageView: UIImageView = {
        var imgView = UIImageView.init(frame: self.bounds)
        imgView.contentMode = .scaleAspectFit
        imgView.isUserInteractionEnabled = true
        //单击监听
        let tapSingle = UITapGestureRecognizer(target:self,
                                             action:#selector(tapSingleDid))
        tapSingle.numberOfTapsRequired = 1
        tapSingle.numberOfTouchesRequired = 1
        //双击监听
        let tapDouble = UITapGestureRecognizer(target:self,
                                             action:#selector(tapDoubleDid(_:)))
        tapDouble.numberOfTapsRequired = 2
        tapDouble.numberOfTouchesRequired = 1
        //声明点击事件需要双击事件检测失败后才会执行
        tapSingle.require(toFail: tapDouble)
        
        // 长按保留
        let tapLong = UILongPressGestureRecognizer.init(target: self, action: #selector(tapLongDid));
        
        imgView.addGestureRecognizer(tapSingle)
        imgView.addGestureRecognizer(tapDouble)
        imgView.addGestureRecognizer(tapLong)
        return imgView
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView.init(frame: self.bounds)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.maximumZoomScale = 3
        scrollView.backgroundColor = kColorCellBg
        scrollView.delegate = self
        return scrollView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = kColorCellBg
        scrollView.addSubview(self.imageView)
        contentView.addSubview(scrollView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
    }
    
}

extension NTHorizontalPageViewCell
{
    //重置单元格内元素尺寸
    func resetSize(){
        self.scrollView.zoomScale = 1.0
    }
    
    //图片单击事件响应
    @objc func tapSingleDid(_ ges:UITapGestureRecognizer){
        tappedAction?(false)
    }
    
    //图片双击事件响应
    @objc func tapDoubleDid(_ ges:UITapGestureRecognizer){

        //缩放视图（带有动画效果）
        UIView.animate(withDuration: 0.5, animations: {
            //如果当前不缩放，则放大到3倍。否则就还原
            if self.scrollView.zoomScale == 1.0 {
                //以点击的位置为中心，放大3倍
                let pointInView = ges.location(in: self.imageView)
                let newZoomScale:CGFloat = 3
                let scrollViewSize = self.scrollView.bounds.size
                let w = scrollViewSize.width / newZoomScale
                let h = scrollViewSize.height / newZoomScale
                let x = pointInView.x - (w / 2.0)
                let y = pointInView.y - (h / 2.0)
                let rectToZoomTo = CGRect(x:x, y:y, width:w, height:h)
                self.scrollView.zoom(to: rectToZoomTo, animated: true)
            }else{
                self.scrollView.zoomScale = 1.0
            }
        })
    }
    
    @objc func tapLongDid() {
        longTappedAction?(self.imageView.image!)
    }
    
}

extension NTHorizontalPageViewCell: UIScrollViewDelegate
{
    //缩放视图
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    //缩放响应，设置imageView的中心位置
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var centerX = scrollView.center.x
        var centerY = scrollView.center.y
        centerX = scrollView.contentSize.width > scrollView.frame.size.width ?
            scrollView.contentSize.width/2:centerX
        centerY = scrollView.contentSize.height > scrollView.frame.size.height ?
            scrollView.contentSize.height/2:centerY
        imageView.center = CGPoint(x: centerX, y: centerY)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView : UIScrollView){
        if scrollView.contentOffset.y < navigationHeight{
            pullAction?(scrollView.contentOffset)
        }
    }
    
}




