//
//  IHTCSearchDetailVC.swift
//  iTalker
//
//  Created by HTC on 2019/4/27.
//  Copyright © 2019 ihtc.cc @iHTCboy. All rights reserved.
//

import UIKit

class IHTCSearchDetailVC: UIViewController {
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var selectedCell: ITQuestionListViewCell!
    
    var questionModle : ITQuestionModel?
    var isShowAnswer : Bool = false
    
    lazy var tableView: UITableView = {
        var tableView = UITableView.init(frame: CGRect.zero, style: .plain)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 80
        tableView.estimatedSectionHeaderHeight = 80
        tableView.register(UINib.init(nibName: "ITQuestionListViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ITQuestionListViewCell")
        tableView.register(UINib.init(nibName: "ITQuestionDetailViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ITQuestionDetailViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self;
        tableView.dataSource = self;
        return tableView
    }()
    
    @available(iOS 9.0, *)
    lazy var previewActions: [UIPreviewActionItem] = {
        let b = UIPreviewAction(title: "分享", style: .default, handler: { (action, vc) in
            self.sharedPageView(item: action)
        })
        return [b]
    }()
    
    @available(iOS 9.0, *)
    override var previewActionItems: [UIPreviewActionItem] {
        return previewActions
    }
}


extension IHTCSearchDetailVC {
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
        
        // UIBarButtonItem
        let shareItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharedPageView))
        navigationItem.rightBarButtonItems = [shareItem]
        
    }
    
    @objc func sharedPageView(item: Any) {
        //let headerImage = selectedCell.screenshot ?? UIImage.init(named: "App-share-Icon")
        let masterImage = tableView.screenshot ?? UIImage.init(named: "iTalker_TextLogo")!
        let footerImage = IHTCShareFooterView.footerView(image: UIImage.init(named: "iTaler_shareIcon_qrcode")!, title: kShareTitle, subTitle: kShareSubTitle).screenshot
        let image = ImageHandle.slaveImageWithMaster(masterImage: masterImage, headerImage: UIImage(), footerImage: footerImage!)
        IAppleServiceUtil.shareImage(image: image!, vc: UIApplication.shared.keyWindow!.rootViewController!.presentedViewController!)
    }
    
}


extension IHTCSearchDetailVC : UITableViewDelegate, UITableViewDataSource {
    
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
        
        cell.tagLbl.text =  " " + questionModle!.title + "   "
        if questionModle!.hasOptionQuestion {
            let text = questionModle!.question + "\n\n  A: " + questionModle!.optionA + "\n  B: " + questionModle!.optionB + "\n  C: " + questionModle!.optionC + "\n  D: " + questionModle!.optionD
            cell.questionLbl.attributedText = getTextAttributedText(text: text, fontSize: 17, color: .darkGray, option: .backwards, styleText: [questionModle!.optionA, questionModle!.optionB, questionModle!.optionC, questionModle!.optionD])
        }
        else {
            cell.questionLbl.text = questionModle!.question
        }
        
        cell.tagLbl.backgroundColor = kColorAppOrange
        cell.langugeLbl.isHidden = questionModle!.knowledge.count>0 ? false : true
        cell.langugeLbl.text = " " + questionModle!.knowledge + "   "
        
        self.selectedCell = cell;
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ITQuestionDetailViewCell = tableView.dequeueReusableCell(withIdentifier: "ITQuestionDetailViewCell") as! ITQuestionDetailViewCell
        cell.accessoryType = .none
        cell.selectionStyle = .none
        cell.answerLbl.textColor = .darkGray
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
            }
            else{
                answer = questionModle!.answer
            }
            textLbl.textAlignment = .left
        }else{
            answer = "\n\n\n\n\n\n\n轻点显示答案\n长按文字可以复制答案\n\n"
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
