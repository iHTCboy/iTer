//
//  ITPictureModel.swift
//  iTalker
//
//  Created by HTC on 2017/4/22.
//  Copyright © 2017年 ihtc.cc @iHTCboy. All rights reserved.
//

import UIKit

class ITPictureModel: NSObject {
    var ID = ""
    var addtime = ""
    var company = ""
    var pictureURL = ""
    var pictype = ""
    var reply = ""
    
    init(dictionary: Dictionary<String, Any>) {
        ID = dictionary["ID"] as! String
        addtime = dictionary["addtime"] as! String
        company = dictionary["company"] as! String
        pictureURL = dictionary["pic"] as! String
        pictype = dictionary["pictype"] as! String
        reply = dictionary["reply"] as! String
    }
}

/*
{
    "addtime": "2017-02-21 15:57:02",
    "approve": "1",
    "company": "武汉大工尹",
    "ID": "219",
    "loader": "草原狼",
    "openid": null,
    "pic": "http://api.codertopic.com/itapi/admin/uploadpic/uploadimages/1487663822up.png",
    "pictype": "Java",
    "reply": "无"
},
*/
