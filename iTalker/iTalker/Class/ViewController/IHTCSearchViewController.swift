//
//  iHTCSearchViewController.swift
//  iWuBi
//
//  Created by HTC on 2019/4/12.
//  Copyright © 2019 HTC. All rights reserved.
//

import UIKit

class IHTCSearchViewController: UIViewController {

    @IBOutlet weak var naviBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var optionItem: UIBarButtonItem!
    

    @IBAction func clickedCancelItem(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickedOptionItem(_ item: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "提示",
                                      message: "请选择要搜索的题目范围",
                                      preferredStyle: UIAlertController.Style.alert)
        
        let allAction = UIAlertAction.init(title: "全部", style: .default) { (action: UIAlertAction) in
            item.title = action.title
            self.searchWordList(words: self.searchBar.text ?? "")
        }
        alert.addAction(allAction)
        
        let companysAction = UIAlertAction.init(title: "企业试题", style: .default) { (action: UIAlertAction) in
            item.title = action.title
            self.searchWordList(words: self.searchBar.text ?? "")
        }
        alert.addAction(companysAction)
        
        for key in ITModel.shared.languageArray {
            let zhProblemsAction = UIAlertAction.init(title: key, style: .default) { (action: UIAlertAction) in
                item.title = action.title
                self.searchWordList(words: self.searchBar.text ?? "")
            }
            alert.addAction(zhProblemsAction)
        }
        
        let cancelAction = UIAlertAction.init(title: "取消", style: .destructive) { (action: UIAlertAction) in
            
        }
        alert.addAction(cancelAction)
        UIApplication.shared.keyWindow!.rootViewController!.presentedViewController!.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    var selectedCell: ITQuestionListViewCell!
    var isShowZH: Bool = false
    private var listModel: ITModel = ITModel.init(dictionary: [:], language: "")
    
    lazy var companyQuestion: Array<String> = {
        var question = Array<String>()
        let companys = ITModel.shared.companysDict
        for (key, titleString) in companys {
            let titleArray = titleString.components(separatedBy: ",")
            for title in titleArray {
                let titleName = key + "-" + title
                question.append(titleName)
            }
        }
        return question
    }()
    
    var jsonData: Dictionary<String, Array<Dictionary<String, String>>> = Dictionary<String, Array<Dictionary<String, String>>>()
}


extension IHTCSearchViewController {
    func setupUI() {
        self.searchBar.tintColor = kColorAppBlue
        self.searchBar.becomeFirstResponder()
        self.searchBar.delegate = self
        
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 40, right: 0)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "ITQuestionListViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ITQuestionListViewCell")
        
        // 判断系统版本，必须iOS 9及以上，同时检测是否支持触摸力度识别
        if #available(iOS 9.0, *), traitCollection.forceTouchCapability == .available {
            // 注册预览代理，self监听，tableview执行Peek
            registerForPreviewing(with: self, sourceView: tableView)
        }
        
    }

    func searchWordList(words: String) {
        if words.count == 0 {
            naviBar.topItem?.title = "Search"
            self.listModel.result.removeAll()
            self.tableView.reloadData()
            return
        }

        searchLeetCoder(words: words)
    }

    func searchLeetCoder(words: String) {
        // remove all data
        naviBar.topItem?.title = "Search"
        self.listModel.result.removeAll()

        let searchArray = ["question", "answer", "optionA", "optionB", "optionC", "optionD", "optionAnswer", "title", "knowledge"]
        var filterArray = Array<String>()
        if optionItem.title == "全部" {
            filterArray.append(contentsOf: ITModel.shared.languageArray)
            filterArray.append(contentsOf: companyQuestion)
        } else if optionItem.title == "企业试题"  {
            filterArray.append(contentsOf: companyQuestion)
        } else {
            filterArray = [optionItem.title!]
        }
        
        // 读取数据
        var dataArray = Array<Dictionary<String, String>>()
        for titile in filterArray {
            // 判断是否缓存数据读取
            if let data = jsonData[titile] {
                dataArray.append(contentsOf: data)
            }
            else {
                let json = getJsonData(title: titile)
                dataArray.append(contentsOf: json)
                jsonData.updateValue(json, forKey: titile)
            }
        }

        // Update the filtered array based on the search text.
        let searchResults = dataArray

        // Strip out all the leading and trailing spaces.
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let strippedString = words.trimmingCharacters(in: whitespaceCharacterSet)
        let searchItems = strippedString.components(separatedBy: " ") as [String]

        // Build all the "AND" expressions for each value in the searchString.
        let andMatchPredicates: [NSPredicate] = searchItems.map { searchString in
            // Each searchString creates an OR predicate for: name, yearIntroduced, introPrice.
            var searchItemsPredicate = [NSPredicate]()

            // Below we use NSExpression represent expressions in our predicates.
            // NSPredicate is made up of smaller, atomic parts: two NSExpressions (a left-hand value and a right-hand value).

            let searchStringExpression = NSExpression(forConstantValue: searchString)

            // Name field matching.
            for key in searchArray {
                let keyExpression = NSExpression(forKeyPath: key)
                let keySearchComparisonPredicate = NSComparisonPredicate(leftExpression: keyExpression, rightExpression: searchStringExpression, modifier: .direct, type: .contains, options: .caseInsensitive)
                searchItemsPredicate.append(keySearchComparisonPredicate)
            }

            // Add this OR predicate to our master AND predicate.
            let orMatchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates:searchItemsPredicate)

            return orMatchPredicate
        }

        // Match up the fields of the Product object.
        let finalCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: andMatchPredicates)

        let filteredResults = searchResults.filter { finalCompoundPredicate.evaluate(with: $0) }

        naviBar.topItem?.title = "Search(\(filteredResults.count))"
        
        // 转成模型
        let result = ["success":1,
                      "total": filteredResults.count,
                      "result": filteredResults] as [String : Any]
        
        self.listModel = ITModel.init(dictionary: result, language: optionItem.title ?? "")
        
        self.tableView.reloadData()
    }
    

    public func getJsonData(title: String) -> Array<Dictionary<String, String>> {
        
        if let file = Bundle.main.url(forResource: title, withExtension: "json") {
            do {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    // json is a dictionary
                    if let resultArray = object["result"] as? Array<Dictionary<String, String>> {
                        return resultArray
                    }
                } else {
                    print("JSON is invalid")
                    return Array()
                }
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("no file")
            return Array()
        }
        return Array()
    }
    
}

extension String {
    func subString(from: Int, to: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[startIndex..<endIndex])
    }
}

extension IHTCSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchWordList(words: searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWordList(words: searchBar.text ?? "")
    }
}


extension IHTCSearchViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}


// MARK: Tableview Delegate
extension IHTCSearchViewController : UITableViewDelegate, UITableViewDataSource {
    
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
        
        let questionModle = self.listModel.result[indexPath.row]
        cell.tagLbl.text =  " " + questionModle.title + "   "
        
        if questionModle.hasOptionQuestion {
            let text = questionModle.question + "\n\n  A: " + questionModle.optionA + "\n  B: " + questionModle.optionB + "\n  C: " + questionModle.optionC + "\n  D: " + questionModle.optionD
            cell.questionLbl.attributedText = getTextAttributedText(text: text, fontSize: 17, color: .darkGray, option: .backwards,styleText: [questionModle.optionA, questionModle.optionB, questionModle.optionC, questionModle.optionD])
        }
        else {
            cell.questionLbl.text = questionModle.question
        }
        
        cell.tagLbl.backgroundColor = kColorAppOrange
        cell.langugeLbl.isHidden = questionModle.knowledge.count>0 ? false : true
        cell.langugeLbl.text = " " + questionModle.knowledge + "   "
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.selectedCell = (tableView.cellForRow(at: indexPath) as! ITQuestionListViewCell)
        
        let question = self.listModel.result[indexPath.row]
        let questionVC = IHTCSearchDetailVC()
        questionVC.title = self.title
        questionVC.questionModle = question
        questionVC.hidesBottomBarWhenPushed = true
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(questionVC, animated: true)
    }
}



// MARK: - UIViewControllerPreviewingDelegate
@available(iOS 9.0, *)
extension IHTCSearchViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        searchBar.resignFirstResponder()
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
        
        let question = self.listModel.result[indexPath.row]
        let questionVC = IHTCSearchDetailVC()
        questionVC.title = self.title
        questionVC.questionModle = question
        questionVC.hidesBottomBarWhenPushed = true
        
        // 返回需要弹出的控制权
        return questionVC
    }
}
