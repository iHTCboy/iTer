//
//  ITProgrammerVC.swift
//  iTalker
//
//  Created by HTC on 2017/4/22.
//  Copyright © 2017年 ihtc.cc @iHTCboy. All rights reserved.
//

import UIKit
import StoreKit
import SafariServices

class ITProgrammerVC: UIViewController {

    // MARK:- Lify Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var isNewVersion = false
    
    // MARK:- 懒加载
    lazy var tableView: UITableView = {
        var tableView = UITableView.init(frame: CGRect.zero, style: .grouped)
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: -49, right: 0)
        tableView.sectionFooterHeight = 0.1;
        tableView.estimatedRowHeight = 55
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    fileprivate var titles = ["0": "设置主题外观:暗黑or浅色",
        "1": "应用内评分:欢迎给\(kiTalker)打评分！,AppStore评价:欢迎给\(kiTalker)写评论!,分享给朋友:与身边的好友一起分享！",
        "2":"意见反馈:欢迎到AppStore提需求或bug问题,邮件联系:如有问题欢迎来信,隐私条款:用户使用服务协议,开源地址:现已公开代码，欢迎关注,感谢开源:参考和引用的项目,更多关注:欢迎访问作者博客,更多应用:更多开发者内容推荐,关于应用:\(kiTalker)"] as [String : String]

}


extension ITProgrammerVC
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
    
    func gotoAppstore(isAssessment: Bool) {
        if UIApplication.shared.canOpenURL(URL.init(string: kAppDownloadURl + (isAssessment ? kReviewAction: ""))!) {
            UIApplication.shared.openURL(URL.init(string: kAppDownloadURl + (isAssessment ? kReviewAction: ""))!)
        }
    }
}

// MARK: Tableview Delegate
extension ITProgrammerVC : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.titles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let string = self.titles["\(section)"]
        let titleArray = string?.components(separatedBy: ",")
        return (titleArray?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "ITProgrammerVCViewCell")
        if (cell  == nil) {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: "ITProgrammerVCViewCell")
            cell!.accessoryType = .disclosureIndicator
            cell!.selectedBackgroundView = UIView.init(frame: cell!.frame)
            cell!.selectedBackgroundView?.backgroundColor = kColorAppOrange.withAlphaComponent(0.7)
            cell?.textLabel?.font = UIFont.systemFont(ofSize: DeviceType.IS_IPAD ? 20:16.5)
            cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: DeviceType.IS_IPAD ? 16:12.5)
            cell?.detailTextLabel?.sizeToFit()
            #if targetEnvironment(macCatalyst)
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 20)
            #endif
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
        
        switch section {
        case 0:
            if row == 0 {
                let vc = IHTCAppearanceVC()
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 1:
            if row == 0 {
                if #available(iOS 10.3, *) {
                    SKStoreReviewController.requestReview()
                } else {
                    gotoAppstore(isAssessment: true)
                }
            }
            if row == 1 {
                gotoAppstore(isAssessment: false)
            }
            if row == 2 {

                let image = UIImage(named: "iTaler_shareIcon")
                let url = NSURL(string: kAppDownloadURl)
                let string = "Hello, iTalker! 这是IT学习、求职面试必备的好工具哦！" + "iOS下载链接：" + kAppDownloadURl
                let activityController = UIActivityViewController(activityItems: [image! ,url!,string], applicationActivities: nil)
                self.present(activityController, animated: true, completion: nil)
            }
            
            break
        case 2:
            if row == 0 {
                gotoAppstore(isAssessment: true)
            }
            if row == 1 {
                let message = "欢迎来信，写下你的问题吧" + "\n\n\n\n" + kMarginLine + "\n 当前\(kiTalker)版本：" + KAppVersion + "， 系统版本：" + String(Version.SYS_VERSION_FLOAT) + "， 设备信息：" + UIDevice.init().modelName
                
                ITCommonAPI.sharedInstance.sendEmail(recipients: [kEmail], messae: message, vc: self)
            }
            if row == 2 {
                IAppleServiceUtil.openWebView(url: kLicenseURL, tintColor: kColorAppOrange, vc: self)
            }
            if row == 3 {
                IAppleServiceUtil.openWebView(url: kGithubURL, tintColor: kColorAppOrange, vc: self)
            }
            if row == 4 {
                let vc = ITAdvancelDetailViewController()
                vc.title = "感谢开源"
                vc.advancelType = .Copyright
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if row == 5 {
                IAppleServiceUtil.openWebView(url: kiHTCboyURL, tintColor: kColorAppOrange, vc: self)
            }
            if row == 6 {
                let vc = ITAdvancelDetailViewController()
                vc.title = "更多学习"
                vc.advancelType = .iHTCboyApp
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if row == 7 {
                let vc = ITAboutAppVC()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
            
        default: break
            
        }
    }
}

