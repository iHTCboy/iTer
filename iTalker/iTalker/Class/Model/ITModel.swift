//
//  ITModel.swift
//  iTalker
//
//  Created by HTC on 2017/4/9.
//  Copyright © 2017年 ihtc.cc @iHTCboy. All rights reserved.
//

import UIKit

class ITModel: NSObject {
    static let shared = ITModel()
    final let languageArray = ["Object-C",
                  "Swift",
                  "Java",
                  "C&C++",
                  "PHP",
                  "JavaScript",
                  "Python",
                  "SQL",
                  "C#",
                  "HTML5",
                  "Ruby",
                  "R",
                  "Linux",
                  "BigData",
                  "Algorithm",
                  "NetworkSecurity"]
    
    final let professionArray = ["iOS Developer",
                                 "Android Developer",
                                 "Java Developer",
                                 "Web Developer",
                                 "PHP Engineer",
                                 "Python Engineer",
                                 "Game Developer",
                                 "Database Engineer",
                                 "BigData Engineer",
                                 "Linux Engineer",
                                 "Algorithm Engineer",
                                 "Network Engineer"]
    
    final let professionSkillsDict = ["iOS Developer":"Object-C,Swift",
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
    
    final let companyNameArray = ["Google",
                               "Microsoft",
                               "Baidu",
                               "Tencent",
                               "Alibaba",
                               "JD",
                               "360",
                               "NetEase",
                               "RenRen",
                               "Xunlei",
                               "sogou",
                               "other"]
    
    final let companysDict  = ["Google":"2013笔试卷,2012笔试卷,2011笔试卷",
                                "Microsoft":"研发工程师笔试卷A,研发工程师笔试卷B,2014校园招聘笔试题",
                             "Baidu":"2016研发工程师在线模拟笔试,2015大数据云计算研发笔试卷,研发工程师2015深圳笔试卷,2015安全研发笔试卷,2015前端研发笔试卷,2013研发工程师笔试卷A,2013研发工程师笔试卷B,2012研发工程师笔试卷,2011研发工程师笔试卷,2007面试笔试题,2005面试笔试题",
                             "Tencent":"2016研发工程师笔试真题（一）,2016研发工程师笔试真题（二）,2016研发工程师笔试真题（三）,2016研发工程师在线模拟笔试题,2015春招pc客户端开发练习卷,2015春招测试工程师练习卷,2015春招后台开发练习卷,2014研发笔试卷,Java工程师笔试卷,研发工程师B笔试卷,研发工程师笔试卷,研发工程师A笔试卷",
                             "Alibaba":"2016研发工程师笔试选择题（一）,2016研发工程师笔试选择题（二）,2016研发工程师笔试选择题（三）,2016研发工程师笔试选择题（四）,2016数据挖掘工程师笔试,2016前端开发工程师笔试(一),2016前端开发工程师笔试(二),2015研发工程师A笔试卷,2015研发工程师B笔试卷,2015系统工程师研发笔试题,2015基础平台研发工程师实习生笔试卷,2015算法工程师实习生笔试卷,2015实习生笔试真题,2013研发工程师笔试卷,2010搜索研发C++工程师笔试卷",
                             "JD":"2015校园招聘技术类笔试题,2014研发工程师校招笔试题,2013研发笔试卷",
                             "360":"2016Java研发工程师内推笔试题,2016C++研发工程师内推笔试题,2015软件测试工程师笔试题,2015校招研发在线笔试题,2014校招笔试卷",
                             "NetEase":"2015校招Java工程师笔试题,2015校园招聘运维开发岗笔试题,2013研发工程师笔试卷",
                             "RenRen":"2015研发笔试卷A,2015研发笔试卷B,2015研发笔试卷C,2015研发笔试卷D,2015研发笔试卷E",
                             "Xunlei":"2014C++笔试卷A,2014C++笔试卷B,2014C++研发笔试卷C",
                             "sogou":"2015C++工程师笔试题,2015前端工程师笔试题",
                             "other":"创新工场2015校招研发在线笔试题,浙江大华2015届校园招聘笔试题,YY2015年校园招聘Java笔试题目,滴滴2016校招在线测评,英特尔2016软件类研发在线测评"]
    
    var success = 0
    var total = 0
    
    lazy var result: Array<ITQuestionModel> = {
        return Array()
    }()
    
    override init() {
        super.init()
    }
    
    init(dictionary: Dictionary<String, Any> , language: String) {
        super.init()
        
        guard !dictionary.isEmpty else {
            print("dictionary can't nil !")
            return
        }
        
        success = dictionary["success"] as! Int
        total = dictionary["total"] as! Int
        let resultArray = dictionary["result"] as! Array<Any>
        for dic in resultArray {
            let questionModel = ITQuestionModel.init(dictionary: dic as! Dictionary<String, Any>);
            questionModel.lauguage = language
            result.append(questionModel)
        }
        
    }
    
}
