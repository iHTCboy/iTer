//
//  ITLanguageViewController.swift
//  iTalker
//
//  Created by HTC on 2017/4/8.
//  Copyright © 2017年 ihtc.cc @iHTCboy. All rights reserved.
//

import UIKit

fileprivate let kTitleViewH : CGFloat = 40

class ITLanguageViewController: UIViewController {
    
    // MARK:- 懒加载
    fileprivate var titles = ["Object-C",
                              "Swift",
                              "Java",
                              "C&C++",
                              "PHP",
                              "JavaScript",
                              "Python",
                              "SQL",
                              "C#",
                              "HTML5",
                              "Ruby",
                              "R",
                              "Linux",
                              "BigData",
                              "Algorithm"]//["热门", "社林会", "科林可要技", "旅游", "社会", "林转基因要科技", "旅游", "社会", "科技", "旅ssssa游"]
    
    fileprivate lazy var pageTitleView: ITPageTitleView = {
        let titleFrame = CGRect(x: 0, y: kStatusBarH + kNavBarH, width: kScreenW, height: kTitleViewH)
        let titleView = ITPageTitleView(frame: titleFrame, titles: self.titles)
        titleView.delegate = self
        return titleView
    }()
    
    fileprivate lazy var pageContentView: ITPageContentView = {[weak self] in
        // 1. 确定内容 frame
        let contentH = kScreenH - kStatusBarH - kNavBarH
        let contentFrame = CGRect(x: 0, y: kStatusBarH + kNavBarH + kTitleViewH, width: kScreenW, height: contentH)
        // 2. 确定所有控制器
        let counts = 0
        var childVcs = [UIViewController]()
        if let counts = self?.titles.count {
            for i in 0..<counts {
                let vc = ITQuestionListViewController()
                vc.title = self?.titles[i]
                childVcs.append(vc)
            }
        }
        
        let contentView = ITPageContentView(frame: contentFrame, childVcs: childVcs, parentVc: self)
        contentView.delegate = self
        return contentView
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置 UI 界面
        setUpUI()
    }
    
}


// MARK:- 设置 UI
extension ITLanguageViewController {
    fileprivate func setUpUI() {
        // 0. 不允许系统调整 scrollview 内边距
        automaticallyAdjustsScrollViewInsets = false
        
        // 1. 添加 titleview
        view.addSubview(pageTitleView)
        
        // 2. 添加 contentview
        view.addSubview(pageContentView)
    }
}

// MARK:- pageTitleViewDelegate
extension ITLanguageViewController: ITPageTitleViewDelegate {
    func pageTitleView(pageTitleView: ITPageTitleView, didSelectedIndex index: Int) {
        pageContentView.scrollToIndex(index: index)
    }
}

// MARK:- pageContentViewDelegate
extension ITLanguageViewController: ITPageContentViewDelegate {
    func pageContentView(pageContentView: ITPageContentView, progress: CGFloat, sourceIndex: Int, targetIndex: Int) {
        pageTitleView.setTitleWithProgerss(sourceIndex: sourceIndex, targetIndex: targetIndex, progress: progress)
    }
}






