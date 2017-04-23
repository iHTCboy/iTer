//
//  NTWaterfallViewCell.swift
//  PinterestSwift
//
//  Created by Nicholas Tau on 6/30/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

import UIKit

class NTWaterfallViewCell :UICollectionViewCell, NTTansitionWaterfallGridViewProtocol{
    var imageName : String?
    var imageViewContent : UIImageView = UIImageView()
    lazy var typeLbl : UILabel = {
        let lbl = UILabel.init()
        lbl.textAlignment = .right
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textColor = kColorAppOrange
        return lbl
    }()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = kColorAppBlue.withAlphaComponent(0.3)//UIColor.lightGray
        contentView.addSubview(imageViewContent)
        imageViewContent.addSubview(self.typeLbl)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageViewContent.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        imageViewContent.contentMode = .scaleAspectFit
        imageViewContent.layer.masksToBounds = true
        typeLbl.frame = CGRect.init(x: 10, y: 0, width: frame.size.width-20, height: 20)
        //imageViewContent.image = UIImage(named: imageName!)
    }
    
    func snapShotForTransition() -> UIView! {
        let snapShotView = UIImageView(image: self.imageViewContent.image)
        snapShotView.frame = imageViewContent.frame
        return snapShotView
    }
}
