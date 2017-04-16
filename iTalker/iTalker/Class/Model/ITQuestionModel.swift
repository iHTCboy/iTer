//
//  ITQuestionModel.swift
//  iTalker
//
//  Created by HTC on 2017/4/9.
//  Copyright © 2017年 ihtc.cc @iHTCboy. All rights reserved.
//

import UIKit

class ITQuestionModel: NSObject {
    var ID = ""
    var typeID = ""
    var answer = ""
    var question = ""
    var lauguage = ""
    var type = ""
    var optionA = ""
    var optionB = ""
    var optionC = ""
    var optionD = ""
    var optionAnswer = ""
    var hasOptionQuestion = false
    
    
    init(dictionary: Dictionary<String, Any>) {
        
        ID = dictionary["ID"] as! String
        typeID = dictionary["typeID"] as! String
        answer = dictionary["answer"] as! String
        question = dictionary["question"] as! String
        let typeU = dictionary["type"] as? NSString
        if let typeQ = typeU?.intValue {
            type = dictionary["type"] as! String
            if typeQ == 1 {
                // 有选项
                hasOptionQuestion = true
                optionA = dictionary["optionA"] as! String
                optionB = dictionary["optionB"] as! String
                optionC = dictionary["optionC"] as! String
                optionD = dictionary["optionD"] as! String
                optionAnswer = dictionary["optionAnswer"] as! String
            }
        }else{
            type = "0"
        }
    }
}

/*
"ID" : "9e95419af51311e5adff00163e0021c8",
"typeID" : "ee460ff8f18a11e5b71300163e0021c8",
"optionD" : "查出已感染的任何病毒，清除部分已感染的病毒",
"optionC" : "检查计算机是否感染病毒，并清除部分已感染的病毒",
"optionAnswer" : "C",
"answer" : "",
"optionB" : "杜绝病毒对计算机的侵害",
"type" : "1",
"optionA" : "检查计算机是否感染病毒，并消除已感染的任何病毒",
"question" : "目前使用的防杀病毒软件的作用是 "
 */
 
