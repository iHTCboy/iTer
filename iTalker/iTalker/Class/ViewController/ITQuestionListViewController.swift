//
//  ITQuestionListViewController.swift
//  iTalker
//
//  Created by HTC on 2017/4/9.
//  Copyright © 2017年 ihtc.cc @iHTCboy. All rights reserved.
//

import UIKit

class ITQuestionListViewController: UIViewController {

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let refreshControl = UIRefreshControl.init()
    var selectedCell: ITQuestionListViewCell!
    
    // MARK:- 懒加载
    lazy var tableView: UITableView = {
        var tableView = UITableView.init(frame: CGRect.zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 40 + 58, right: 0) //tabBarHeight
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 80
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.register(UINib.init(nibName: "ITQuestionListViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ITQuestionListViewCell")
        self.refreshControl.addTarget(self, action: #selector(randomRefresh(sender:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(self.refreshControl)
        return tableView
    }()
    
    lazy var listModel: ITModel = {
        if let file = Bundle.main.url(forResource: self.title!, withExtension: "json") {
            return self.getModel(title: self.title!)
        } else {
            
            let professionArray = Array(self.titles.keys)
            let companyArr = Array(self.companys.keys)
            if professionArray.contains(self.title!) {
                let titleString = self.titles[self.title!]
                let titleArray = titleString?.components(separatedBy: ",")
                let sumModel = ITModel()
                for title in titleArray! {
                    let model = self.getModel(title: title)
                    sumModel.result.append(contentsOf: model.result)
                    sumModel.total += model.total
                    sumModel.success = model.success==1 ? 1 : sumModel.success
                }
                return sumModel
                
            } else if companyArr.contains(self.title!) {
                let titleString = self.companys[self.title!]
                let titleArray = titleString?.components(separatedBy: ",")
                let sumModel = ITModel()
                for title in titleArray! {
                    let titleName = self.title! + "-" + title
                    let model = self.getModel(title: titleName)
                    sumModel.result.append(contentsOf: model.result)
                    sumModel.total += model.total
                    sumModel.success = model.success==1 ? 1 : sumModel.success
                }
                return sumModel
                
            } else {
                print("no featch title")
            }
        }
        return ITModel()
    }()
    
    fileprivate var titles = ITModel.shared.professionSkillsDict
    
    fileprivate var companys = ITModel.shared.companysDict
}


// MARK:- Prive mothod
extension ITQuestionListViewController {
    fileprivate func setUpUI() {
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
        
        // 判断系统版本，必须iOS 9及以上，同时检测是否支持触摸力度识别
        if #available(iOS 9.0, *), traitCollection.forceTouchCapability == .available {
            // 注册预览代理，self监听，tableview执行Peek
            registerForPreviewing(with: self, sourceView: tableView)
        }
    }
    
    @objc public func randomRefresh(sender: AnyObject) {
        self.listModel.result.shuffle()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    public func getModel(title: String) -> ITModel {
        
        if let file = Bundle.main.url(forResource: title, withExtension: "json") {
            do {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    // json is a dictionary
                    
                    let model = ITModel.init(dictionary: object, language: title)
                    model.result.shuffle()
                    return model
                    
                } else {
                    print("JSON is invalid")
                    return ITModel()
                }
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("no file")
            return ITModel()
        }
        return ITModel()
    }
}

// MARK: Tableview Delegate
extension ITQuestionListViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listModel.result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ITQuestionListViewCell = tableView.dequeueReusableCell(withIdentifier: "ITQuestionListViewCell") as! ITQuestionListViewCell
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        cell.tagLbl.layer.cornerRadius = 3
        cell.tagLbl.layer.masksToBounds = true
        cell.langugeLbl.layer.cornerRadius = 3
        cell.langugeLbl.layer.masksToBounds = true
        cell.langugeLbl.backgroundColor = kColorAppBlue
        cell.knowledgeLbl.layer.cornerRadius = 3
        cell.knowledgeLbl.layer.masksToBounds = true
        
        #if targetEnvironment(macCatalyst)
        cell.questionLbl.font = UIFont.systemFont(ofSize: 20)
        #endif
        
        let questionModle = self.listModel.result[indexPath.row]
        cell.tagLbl.text =  " " + self.title! + "   "
        
        var secondaryLabel = UIColor.darkGray
        if #available(iOS 13.0, *) {
            secondaryLabel = UIColor.secondaryLabel
        }
        
        if questionModle.hasOptionQuestion {
            let text = questionModle.question + "\n\n  A: " + questionModle.optionA + " \n  B: " + questionModle.optionB + " \n  C: " + questionModle.optionC + " \n  D: " + questionModle.optionD + " "
            cell.questionLbl.attributedText = getTextAttributedText(text: text, fontSize: 17, color: secondaryLabel, option: .backwards,styleText: [" \(questionModle.optionA) ", " \(questionModle.optionB) ", " \(questionModle.optionC) ", " \(questionModle.optionD) "])
        }
        else {
            cell.questionLbl.text = questionModle.question
        }
        
        if self.title == questionModle.lauguage {
            // 判断当前是语言tabbar 也可以用 self.tabBarController?.selectedIndex 判断，但兼容性不好
            cell.tagLbl.backgroundColor = kColorAppBlue
            cell.langugeLbl.isHidden = true
        }
        else{
            
            cell.tagLbl.backgroundColor = kColorAppOrange
            cell.langugeLbl.isHidden = false
            cell.langugeLbl.text = " " + questionModle.lauguage + "   "
        }
        
        cell.knowledgeLbl.isHidden = questionModle.knowledge.count>0 ? false : true
        cell.knowledgeLbl.text = " " + questionModle.knowledge + "   "
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.selectedCell = (tableView.cellForRow(at: indexPath) as! ITQuestionListViewCell)
    
        let question = self.listModel.result[indexPath.row]
        let questionVC = ITQuestionDetailViewController()
        questionVC.title = self.title
        questionVC.questionModle = question
        questionVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(questionVC, animated: true)
    }
}


// MARK: 随机数
extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            self.swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}


// MARK: - UIViewControllerPreviewingDelegate
@available(iOS 9.0, *)
extension ITQuestionListViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        // 模态弹出需要展现的控制器
        //        showDetailViewController(viewControllerToCommit, sender: nil)
        // 通过导航栏push需要展现的控制器
        show(viewControllerToCommit, sender: nil)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        // 获取indexPath和cell
        guard let indexPath = tableView.indexPathForRow(at: location), let cell = tableView.cellForRow(at: indexPath) else { return nil }
        // 设置Peek视图突出显示的frame
        previewingContext.sourceRect = cell.frame
        
        self.selectedCell = (tableView.cellForRow(at: indexPath) as! ITQuestionListViewCell)
        
        let question = self.listModel.result[indexPath.row]
        let questionVC = ITQuestionDetailViewController()
        questionVC.title = self.title
        questionVC.questionModle = question
        questionVC.hidesBottomBarWhenPushed = true
        
        // 返回需要弹出的控制权
        return questionVC
    }
}


