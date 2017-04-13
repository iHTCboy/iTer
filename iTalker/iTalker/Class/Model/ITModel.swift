//
//  ITModel.swift
//  iTalker
//
//  Created by HTC on 2017/4/9.
//  Copyright © 2017年 ihtc.cc @iHTCboy. All rights reserved.
//

import UIKit

class ITModel: NSObject {
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
