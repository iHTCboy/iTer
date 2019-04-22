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
        var tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH-64-58), style: .plain)
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 40, right: 0)
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
    
    fileprivate var titles = ["iOS Developer":"Object-C,Swift",
                              "Web Developer":"JavaScript,HTML5",
                              "Java Developer":"Java",
                              "Android Developer":"Android,Java",
                              "PHP Engineer":"PHP",
                              "Python Engineer":"Python",
                              "Game Developer":"JavaScript,C#",
                              "Database Engineer":"SQL",
                              "BigData Engineer":"R,BigData",
                              "Linux Engineer":"Linux",
                              "Algorithm Engineer":"Algorithm",
                              "Network Engineer":"NetworkSecurity"]
    
    fileprivate var companys = ["Google":"2013笔试卷,2012笔试卷,2011笔试卷",
                              "Microsoft":"研发工程师笔试卷A,研发工程师笔试卷B,2014校园招聘笔试题",
                              "Baidu":"2016研发工程师在线模拟笔试,2015大数据云计算研发笔试卷,研发工程师2015深圳笔试卷,2015安全研发笔试卷,2015前端研发笔试卷,2013研发工程师A笔试卷,2013研发工程师笔试卷8,2012研发工程师笔试卷,2011研发工程师笔试卷,2007面试笔试题,2005面试笔试题",
                              "Tencent":"2016研发工程师笔试真题（一）,2016研发工程师笔试真题（二）,2016研发工程师笔试真题（三）,2016研发工程师在线模拟笔试题,2015春招pc客户端开发练习卷,2015春招测试工程师练习卷,2015春招后台开发练习卷,2014研发笔试卷,Java工程师笔试卷,研发工程师B笔试卷,研发工程师笔试卷,研发工程师A笔试卷",
                              "Alibaba":"2016研发工程师笔试选择题（一）,2016研发工程师笔试选择题（二）,2016研发工程师笔试选择题（三）,2016研发工程师笔试选择题（四）,2016数据挖掘工程师笔试,2016前端开发工程师笔试(一),2016前端开发工程师笔试(二),2015研发工程师A笔试卷,2015研发工程师B笔试卷,2015系统工程师研发笔试题,2015基础平台研发工程师实习生笔试卷,2015算法工程师实习生笔试卷,2015实习生笔试真题,2013研发工程师笔试卷,2010搜索研发C++工程师笔试卷",
                              "JD":"2015校园招聘技术类笔试题,2014研发工程师校招笔试题,2013研发笔试卷",
                              "360":"2016Java研发工程师内推笔试题,2016C++研发工程师内推笔试题,2015软件测试工程师笔试题,2015校招研发在线笔试题,2014校招笔试卷",
                              "NetEase":"2015校招Java工程师笔试题,2015校园招聘运维开发岗笔试题,2013研发工程师笔试卷",
                              "RenRen":"2015研发笔试卷A,2015研发笔试卷B,2015研发笔试卷C,2015研发笔试卷D,2015研发笔试卷E",
                              "Xunlei":"2014C++笔试卷A,2014C++笔试卷B,2014C++研发笔试卷C",
                              "sogou":"2015C++工程师笔试题,2015前端工程师笔试题",
                              "other":"创新工场2015校招研发在线笔试题,浙江大华2015届校园招聘笔试题,YY2015年校园招聘Java笔试题目,滴滴2016校招在线测评,英特尔2016软件类研发在线测评"]
}


// MARK:- Prive mothod
extension ITQuestionListViewController {
    fileprivate func setUpUI() {
        view.addSubview(tableView)
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        
//        let viewDict = [
//            "tableView": tableView
//            ]
//        
//        let vFormat = "V:|[tableView]|"
//        let hFormat = "H:|[tableView]|"
//        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: vFormat, options: [], metrics: nil, views: viewDict)
//        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: hFormat, options: [], metrics: nil, views: viewDict)
//        view.addConstraints(vConstraints)
//        view.addConstraints(hConstraints)
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
                    return model
                    
                } else {
                    print("JSON is invalid")
                    return ITModel();
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
//        cell.selectedBackgroundView = UIView.init(frame: cell.frame)
//        cell.selectedBackgroundView?.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.tagLbl.layer.cornerRadius = 3
        cell.tagLbl.layer.masksToBounds = true
        cell.langugeLbl.layer.cornerRadius = 3
        cell.langugeLbl.layer.masksToBounds = true
        cell.langugeLbl.backgroundColor = kColorAppBlue
        
        let question = self.listModel.result[indexPath.row]
        cell.tagLbl.text =  " " + self.title! + "   "
        
        if question.hasOptionQuestion {
            cell.questionLbl.text = question.question + "\n  A: " + question.optionA + "\n  B: " + question.optionB + "\n  C: " + question.optionC + "\n  D: " + question.optionD
        }else{
            
            cell.questionLbl.text = question.question
        }
        
        if self.title == question.lauguage {
            // 判断当前是语言tabbar 也可以用 self.tabBarController?.selectedIndex 判断，但兼容性不好
            cell.tagLbl.backgroundColor = kColorAppBlue
            cell.langugeLbl.isHidden = true
        }else{
            
            cell.tagLbl.backgroundColor = kColorAppOrange
            cell.langugeLbl.isHidden = false
            cell.langugeLbl.text = " " + question.lauguage + "   "
        }
        
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


