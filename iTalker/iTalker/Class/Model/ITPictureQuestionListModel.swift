//
//  ITPictureQuestionListModel.swift
//  iTalker
//
//  Created by HTC on 2017/4/22.
//  Copyright © 2017年 ihtc.cc @iHTCboy. All rights reserved.
//

import UIKit

class ITPictureQuestionListModel: NSObject {
    var success = 0
    var total = 0
    
    lazy var result: Array<ITPictureModel> = {
        return Array()
    }()
    
    override init() {
        super.init()
    }
    
    init(dictionary: Dictionary<String, Any>) {
        super.init()
        
        guard !dictionary.isEmpty else {
            print("dictionary can't nil !")
            return
        }
        
        success = dictionary["success"] as! Int
        total = dictionary["total"] as! Int
        let resultArray = dictionary["result"] as! Array<Any>
        for dic in resultArray {
            let model = ITPictureModel.init(dictionary: dic as! Dictionary<String, Any>);
            result.append(model)
        }
        
    }
}
