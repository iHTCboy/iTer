//
//  ITQuestionDetailViewController.swift
//  iTalker
//
//  Created by HTC on 2017/4/9.
//  Copyright © 2017年 ihtc.cc @iHTCboy. All rights reserved.
//

import UIKit

class ITQuestionDetailViewController: UIViewController {
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.delegate = self
        
        //手势监听器
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.edgePanGesture(_:)))
        edgePan.edges = UIRectEdge.left
        self.view.addGestureRecognizer(edgePan)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate var percentDrivenTransition: UIPercentDrivenInteractiveTransition?
    var selectedCell: ITQuestionListViewCell!
    
    var questionModle : ITQuestionModel?
    var isShowAnswer : Bool = false
    
    lazy var tableView: UITableView = {
        var tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH), style: .plain)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.estimatedRowHeight = 80
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
    
    func edgePanGesture(_ edgePan: UIScreenEdgePanGestureRecognizer) {
        let progress = edgePan.translation(in: self.view).x / self.view.bounds.width
        
        if edgePan.state == UIGestureRecognizerState.began {
            self.percentDrivenTransition = UIPercentDrivenInteractiveTransition()
            self.navigationController?.popViewController(animated: true)
        } else if edgePan.state == UIGestureRecognizerState.changed {
            self.percentDrivenTransition?.update(progress)
        } else if edgePan.state == UIGestureRecognizerState.cancelled || edgePan.state == UIGestureRecognizerState.ended {
            if progress > 0.5 {
                self.percentDrivenTransition?.finish()
            } else {
                self.percentDrivenTransition?.cancel()
            }
            self.percentDrivenTransition = nil
        }
    }
}


extension ITQuestionDetailViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        switch indexPath.row {
        case 0:
            let cell: ITQuestionListViewCell = tableView.dequeueReusableCell(withIdentifier: "ITQuestionListViewCell") as! ITQuestionListViewCell
            cell.accessoryType = .none
            cell.selectionStyle = .none
            cell.tagLbl.layer.cornerRadius = 3
            cell.tagLbl.layer.masksToBounds = true
            cell.langugeLbl.layer.cornerRadius = 3
            cell.langugeLbl.layer.masksToBounds = true
            cell.langugeLbl.backgroundColor = kColorAppBlue
            
            cell.questionLbl.text = questionModle!.question
            cell.tagLbl.text =  " \(self.title!) "
            
            if self.title == questionModle?.lauguage {
                // 判断当前是语言tabbar 也可以用 self.tabBarController?.selectedIndex 判断，但兼容性不好
                cell.tagLbl.backgroundColor = kColorAppBlue
                cell.langugeLbl.isHidden = true
            }else{
                
                cell.tagLbl.backgroundColor = kColorAppOrange
                cell.langugeLbl.isHidden = false
                cell.langugeLbl.text = " \(questionModle!.lauguage) "
                
            }
            self.selectedCell = cell;
            return cell
        default:
            let cell: ITQuestionDetailViewCell = tableView.dequeueReusableCell(withIdentifier: "ITQuestionDetailViewCell") as! ITQuestionDetailViewCell
            cell.accessoryType = .none
            cell.selectionStyle = .none
            cell.answerLbl.text = isShowAnswer ? questionModle?.answer : "\n\n\n\n\n\n\n轻点显示答案\n长按答案可以复制\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(textTapped(gestureReconizer:)))
            cell.answerLbl.addGestureRecognizer(tap)
            
            return cell
        }
    }
    
    func textTapped(gestureReconizer: UITapGestureRecognizer) {
        isShowAnswer = !isShowAnswer
        
        let lbl = gestureReconizer.view as! UILabel
        if lbl.text != questionModle?.answer {
            lbl.textAlignment = .left
            lbl.text = questionModle?.answer
        }else{
            lbl.textAlignment = .center
            lbl.text = "\n\n\n\n\n\n\n轻点显示答案\n长按答案可以复制\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
        }
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
}

extension ITQuestionDetailViewController : UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == UINavigationControllerOperation.pop {
            return ITScalePopTransition()
        } else {
            return nil
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if animationController is ITScalePopTransition {
            return self.percentDrivenTransition
        } else {
            return nil
        }
    }
}

