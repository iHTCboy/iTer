//
//  ITAdvanceLearningViewController.swift
//  iTalker
//
//  Created by HTC on 2019/4/22.
//  Copyright © 2019 ihtc.cc @iHTCboy. All rights reserved.
//

import UIKit

class ITAdvanceLearningViewController: UIViewController {
    
    // MARK:- Lify Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- 懒加载
    lazy var tableView: UITableView = {
        var tableView = UITableView.init(frame: CGRect.zero, style: .grouped)
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 20, right: 0)
        tableView.estimatedRowHeight = 55
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    
    lazy var titleArray: Array<String> = {
        return ["算法进阶", "iOS进阶", "练手项目","题目库"]
    }()
    
    lazy var titles: [String : String] = {
        return ["0": "力扣:提升你的算法水平最好的地方，为下一次面试做准备！,LeetCode:Level up your coding skills and quickly land a job.,iLeetCoder:一款精心的算法题目学习App，迅速找到工作。",
                "1": "Objc.io 期刊:关于iOS和macOS开发最佳实践和先进技术,NSHipster:关注被忽略的 Objective-C、Swift 和 Cocoa 特性",
                "2": "动手实践:GitHub开源最火的项目练习",
                "3": "图片题库:真实公司面试题目"
                ] as [String : String]
    }()
    
}


extension ITAdvanceLearningViewController
{
    func setupUI() {
        view.addSubview(tableView)
        let constraintViews = [
            "tableView": tableView
        ]
        let vFormat = "V:|-0-[tableView]-0-|"
        let hFormat = "H:|-0-[tableView]-0-|"
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: vFormat, options: [], metrics: [:], views: constraintViews)
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: hFormat, options: [], metrics: [:], views: constraintViews)
        view.addConstraints(vConstraints)
        view.addConstraints(hConstraints)
        view.layoutIfNeeded()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

// MARK: Tableview Delegate
extension ITAdvanceLearningViewController : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let string = titles["\(section)"]
        let titleArray = string?.components(separatedBy: ",")
        return (titleArray?.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleArray[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "ITAdvanceLearningViewCell")
        if (cell  == nil) {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: "ITAdvanceLearningViewCell")
            cell!.accessoryType = .disclosureIndicator
            cell!.selectedBackgroundView = UIView.init(frame: cell!.frame)
            cell!.selectedBackgroundView?.backgroundColor = kColorAppOrange.withAlphaComponent(0.7)
            cell?.textLabel?.font = UIFont.systemFont(ofSize: DeviceType.IS_IPAD ? 20:16.5)
            cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: DeviceType.IS_IPAD ? 16:11.5)
            cell?.detailTextLabel?.sizeToFit()
        }
        
        let string = self.titles["\(indexPath.section)"]
        let titleArray = string?.components(separatedBy: ",")
        let titles = titleArray?[indexPath.row]
        let titleA = titles?.components(separatedBy: ":")
        cell!.textLabel?.text = titleA?[0]
        cell?.detailTextLabel?.text = titleA?[1]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = indexPath.section;
        let row = indexPath.row;
        let titile = tableView.cellForRow(at: indexPath)?.textLabel?.text ?? ""
        
        switch section {
        case 0:
            if row == 0 {
                IAppleServiceUtil.openWebView(url: "https://leetcode-cn.com/problemset/all/", tintColor: kColorAppBlue, vc: self)
            }
            if row == 1 {
                IAppleServiceUtil.openWebView(url: "https://leetcode.com/problemset/all/", tintColor: kColorAppBlue, vc: self)
            }
            if row == 2 {
                IAppleServiceUtil.openAppstore(url: "https://itunes.apple.com/cn/app/iLeetCoder/id1458259471?l=zh&ls=1&mt=8", isAssessment: false)
            }
            break
        case 1:
            let vc = ITAdvancelDetailViewController()
            vc.title = titile
            if row == 0 {
                vc.advancelType = .Objc
            }
            if row == 1 {
                vc.advancelType = .NSHipster
            }
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 2:
            if row == 0 {
                let vc = ITAdvancelDetailViewController()
                vc.title = titile
                vc.advancelType = .PracticeProject
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 3:
            if row == 0 {
                let vc = NTWaterfallViewController.init(collectionViewLayout:CHTCollectionViewWaterfallLayout())
                let nav = NTNavigationController.init(rootViewController: vc)
                vc.title = "实拍面试题目"
                self.present(nav, animated: true, completion: nil);
            }
            break
            
        default: break
            
        }
    }
}


