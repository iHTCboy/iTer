//
//  ITQuestionListViewController.swift
//  iTalker
//
//  Created by HTC on 2017/4/9.
//  Copyright © 2017年 ihtc.cc @iHTCboy. All rights reserved.
//

import UIKit

class ITQuestionListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    lazy var tableView: UITableView = {
        var tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH-64-58), style: .plain)
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 40, right: 0)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.estimatedRowHeight = 80
        tableView.register(UINib.init(nibName: "ITQuestionListViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ITQuestionListViewCell")
        self.refreshControl.addTarget(self, action: #selector(randomRefresh(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(self.refreshControl)
        return tableView
    }()
    
    let refreshControl = UIRefreshControl.init()
    
    lazy var listModel: ITModel = {
        
        if let file = Bundle.main.url(forResource: self.title!, withExtension: "json") {
            return self.getModel(title: self.title!)
        } else {
            
            let array = Array(self.titles.keys)
            if array.contains(self.title!) {
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
                
            } else {
                print("no featch title")
            }
        }
        
        return ITModel()
       
    }()
    
    public func randomRefresh(sender: AnyObject) {
        self.listModel.result.shuffle()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func getModel(title: String) -> ITModel {
        
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
    
    // MARK:- 懒加载
    fileprivate var titles = ["iOS Developer":"Object-C,Swift",
                              "Web Developer":"JavaScript,HTML5",
                              "Java Developer":"Java",
                              "Android Developer":"Java",
                              "PHP Engineer":"PHP",
                              "Python Engineer":"Python",
                              "Game Developer":"JavaScript,C#",
                              "Database Engineer":"SQL",
                              "BigData Engineer":"R,BigData",
                              "Linux Engineer":"Linux",
                              "Algorithm Engineer":"Algorithm"]
}


extension ITQuestionListViewController {
    fileprivate func setUpUI() {
    
        view.addSubview(tableView)
        tableView.delegate = self;
        tableView.dataSource = self;
    }
    
}


extension ITQuestionListViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listModel.total
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ITQuestionListViewCell = tableView.dequeueReusableCell(withIdentifier: "ITQuestionListViewCell") as! ITQuestionListViewCell
        cell.accessoryType = .disclosureIndicator
        cell.tagLbl.layer.cornerRadius = 3
        cell.tagLbl.layer.masksToBounds = true
        cell.langugeLbl.layer.cornerRadius = 3
        cell.langugeLbl.layer.masksToBounds = true
        cell.langugeLbl.backgroundColor = kColorAppBlue
        
        let question = self.listModel.result[indexPath.row]
        cell.questionLbl.text = question.question
        cell.tagLbl.text =  " \(self.title!) "
        
        if self.title == question.lauguage {
            // 判断当前是语言tabbar 也可以用 self.tabBarController?.selectedIndex 判断，但兼容性不好
            cell.tagLbl.backgroundColor = kColorAppBlue
            cell.langugeLbl.isHidden = true
        }else{
            
            cell.tagLbl.backgroundColor = kColorAppOrange
            cell.langugeLbl.isHidden = false
            cell.langugeLbl.text = " \(question.lauguage) "
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let question = self.listModel.result[indexPath.row]
        let questionVC = ITQuestionDetailViewController()
        questionVC.title = self.title
        questionVC.questionModle = question
        questionVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(questionVC, animated: true)
        
    }
}


extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
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


