//
//  ITQuestionDetailViewController.swift
//  iTalker
//
//  Created by HTC on 2017/4/9.
//  Copyright © 2017年 ihtc.cc @iHTCboy. All rights reserved.
//

import UIKit

class ITQuestionDetailViewController: ITBasePopTransitionVC {
 
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var selectedCell: ITQuestionListViewCell!
    
    var questionModle : ITQuestionModel?
    var isShowAnswer : Bool = false
    
    lazy var tableView: UITableView = {
        var tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH), style: .plain)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.estimatedRowHeight = 80
        tableView.estimatedSectionHeaderHeight = 80
        tableView.register(UINib.init(nibName: "ITQuestionListViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ITQuestionListViewCell")
        tableView.register(UINib.init(nibName: "ITQuestionDetailViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ITQuestionDetailViewCell")
        // 调试
        //        tableView.fd_debugLogEnabled = true
        return tableView
    }()
}


extension ITQuestionDetailViewController {
    fileprivate func setUpUI() {
        view.addSubview(tableView)
        tableView.delegate = self;
        tableView.dataSource = self;
    }
}


extension ITQuestionDetailViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = UINib(nibName: "ITQuestionListViewCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ITQuestionListViewCell
        cell.backgroundColor = UIColor.white
        cell.accessoryType = .none
        cell.selectionStyle = .none
        cell.tagLbl.layer.cornerRadius = 3
        cell.tagLbl.layer.masksToBounds = true
        cell.langugeLbl.layer.cornerRadius = 3
        cell.langugeLbl.layer.masksToBounds = true
        cell.langugeLbl.backgroundColor = kColorAppBlue
        
        cell.tagLbl.text =  " " + self.title! + "   "
        if questionModle!.hasOptionQuestion {
            cell.questionLbl.text = questionModle!.question + "\n  A: " + questionModle!.optionA + "\n  B: " + questionModle!.optionB + "\n  C: " + questionModle!.optionC + "\n  D: " + questionModle!.optionD
        }else{
            
            cell.questionLbl.text = questionModle!.question
        }
        
        if self.title == questionModle?.lauguage {
            // 判断当前是语言tabbar 也可以用 self.tabBarController?.selectedIndex 判断，但兼容性不好
            cell.tagLbl.backgroundColor = kColorAppBlue
            cell.langugeLbl.isHidden = true
        }else{
            
            cell.tagLbl.backgroundColor = kColorAppOrange
            cell.langugeLbl.isHidden = false
            cell.langugeLbl.text =   " " + questionModle!.lauguage + "   "            
        }
        self.selectedCell = cell;
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell: ITQuestionDetailViewCell = tableView.dequeueReusableCell(withIdentifier: "ITQuestionDetailViewCell") as! ITQuestionDetailViewCell
        cell.accessoryType = .none
        cell.selectionStyle = .none
        cell.answerLbl.text = getAnswer(textLbl: cell.answerLbl)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(textTapped(gestureReconizer:)))
        cell.answerLbl.addGestureRecognizer(tap)
        
        return cell
    }
    
    func getAnswer(textLbl: UILabel) -> String {
        var answer = ""
        if isShowAnswer {
            if questionModle!.hasOptionQuestion {
                answer = "答案：" + questionModle!.optionAnswer + "\n\n" + questionModle!.answer
            }else{
                answer = questionModle!.answer
            }
            textLbl.textAlignment = .left
        }else{
            answer = "\n\n\n\n\n\n\n轻点显示答案\n长按文字可以复制答案\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
            textLbl.textAlignment = .center
        }
        return answer
    }
    
    @objc func textTapped(gestureReconizer: UITapGestureRecognizer) {
        isShowAnswer = !isShowAnswer
        
        let lbl = gestureReconizer.view as! UILabel
        lbl.text = getAnswer(textLbl: lbl)
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

