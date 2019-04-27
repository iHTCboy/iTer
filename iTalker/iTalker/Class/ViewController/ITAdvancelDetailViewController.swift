//
//  ITAdvancelDetailViewController.swift
//  iTalker
//
//  Created by HTC on 2019/4/24.
//  Copyright © 2019 ihtc.cc @iHTCboy. All rights reserved.
//

import UIKit


enum ITAdvancelType {
    case Objc
    case NSHipster
    case Awesome
    case PracticeProject
    case Gitbook
}

class ITAdvancelDetailViewController: UIViewController {

    // MARK:- Lify Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var advancelType: ITAdvancelType = .Objc
    var dataArray: Array<Dictionary<String, Any>> = Array()
    
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
    
    lazy var objcArray: Array<Dictionary<String, Any>> = {
        if let file = Bundle.main.url(forResource: "Objc.io", withExtension: "json") {
            do {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? Array<Dictionary<String, Any>> {
                    var array: Array<Dictionary<String, Any>> = Array()
                    for obj in object {
                        array.append(["title": obj["issue_title"] as! String, "subtitle": obj["issue_date_meta"] as! String, "data": obj["issue_list"] as Any])
                        array.append(["title": obj["issue_title_cn"] as! String, "subtitle": obj["issue_date_meta_cn"] as! String, "data": obj["issue_list_cn"] as Any])
                    }
                    return array
                } else {
                    print("JSON is invalid")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        print("no file")
        return Array()
    }()
    
    lazy var nshipsterArray: Array<Dictionary<String, Any>> = {
        if let file = Bundle.main.url(forResource: "NSHipster", withExtension: "json") {
            do {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? Dictionary<String, Dictionary<String, Any>> {
                    var array: Array<Dictionary<String, Any>> = Array()
                    for key in object.keys {
                        let dict = object[key]
                        array.append(["title": dict!["content_title"] as! String, "subtitle": "", "data": dict!["content_list"] as Any])
                        if let titile = dict!["content_title_cn"] {
                            array.append(["title": "\(titile) - 中文", "subtitle": "", "data": dict!["content_list_cn"] as Any])
                        }
                    }
                    return array
                } else {
                    print("JSON is invalid")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        print("no file")
        return Array()
    }()
}


extension ITAdvancelDetailViewController
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
        
        switch advancelType {
        case .Objc:
            dataArray = objcArray
            break
        case .NSHipster:
            dataArray = nshipsterArray
            break
        case .PracticeProject:
            dataArray = getJsonData(title: "PracticeProject")
            break
        case .Gitbook:
            dataArray = getJsonData(title: "Gitbook")
            break
        case .Awesome:
            dataArray = getJsonData(title: "Awesome")
        }
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func getJsonData(title: String) -> Array<Dictionary<String, Any>> {
        if let file = Bundle.main.url(forResource: title, withExtension: "json") {
            do {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? Array<Dictionary<String, Any>> {
                    var array: Array<Dictionary<String, Any>> = Array()
                    for obj in object {
                        array.append(["title": obj["issue_title"] as! String, "subtitle": obj["issue_subtitle"] ?? "", "data": obj["issue_list"] as Any])
                    }
                    return array
                } else {
                    print("JSON is invalid")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        print("no file")
        return Array()
    }

}

// MARK: Tableview Delegate
extension ITAdvancelDetailViewController : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dict = dataArray[section]
        let array = dict["data"] as! Array<Dictionary<String, String>>
        return array.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dict = self.dataArray[section]
        let titile = (dict["title"] as! String)
        let subtitle = dict["subtitle"] as! String
        let view = TableHeaderView.initView(title: titile, subtitle: subtitle, height: 40)
        view.backgroundColor = .clear
        return view
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCell(withIdentifier: "ITAdvanceLearningViewCell")
        if (cell  == nil) {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: "ITAdvanceLearningViewCell")
            cell!.accessoryType = .disclosureIndicator
            cell!.selectedBackgroundView = UIView.init(frame: cell!.frame)
            cell!.selectedBackgroundView?.backgroundColor = kColorAppOrange.withAlphaComponent(0.7)
            cell?.textLabel?.font = UIFont.systemFont(ofSize: DeviceType.IS_IPAD ? 20:16.5)
            cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: DeviceType.IS_IPAD ? 16:12.5)
            cell?.detailTextLabel?.sizeToFit()
        }

        let dict = dataArray[indexPath.section]
        let array = dict["data"] as! Array<Dictionary<String, String>>
        let data = array[indexPath.row]
        cell!.textLabel?.text = data["title"]
        
        if let subtitle = data["author"] {
            cell?.detailTextLabel?.text = subtitle
        }

        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let dict = dataArray[indexPath.section]
        let array = dict["data"] as! Array<Dictionary<String, String>>
        let data = array[indexPath.row]
        IAppleServiceUtil.openWebView(url: data["url"] ?? "", tintColor: kColorAppBlue, vc: self)
    }
}
