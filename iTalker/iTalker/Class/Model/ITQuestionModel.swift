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
    
    init(dictionary: Dictionary<String, Any>) {
        
        ID = dictionary["ID"] as! String
        typeID = dictionary["typeID"] as! String
        answer = dictionary["answer"] as! String
        question = dictionary["question"] as! String
        
    }
}
