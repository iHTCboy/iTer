//
//  ITFeatchITJsonFile.swift
//  iTalker
//
//  Created by HTC on 2017/4/9.
//  Copyright © 2017年 ihtc.cc @iHTCboy. All rights reserved.
//

import UIKit

class ITFeatchITJsonFile: NSObject {
    
    var languageDic = ["Object-C":"10",
                       "Swift":"19",
                       "Java":"11",
                       "C&C++":"12",
                       "PHP":"13",
                       "JavaScript":"14",
                       "Python":"15",
                       "SQL":"16",
                       "C#":"17",
                       "HTML5":"18",
                       "Ruby":"20",
                       "R":"21",
                       "Linux":"22",
                       "BigData":"23",
                       "Algorithm":"24"]
    
    
    var professionDic = ["iOS Developer":"Object-C,Swift",
                        "Web Developer":"JavaScript,HTML5",
                        "Java Developer":"Java",
                        "Android Developer":"Java",
                        "PHP Engineer":"PHP",
                        "Python Engineer":"Python",
                        "Game Developer":"JavaScript,C#",
                        "Database Engineer":"SQL",
                        "BigData Engineer":"R,BigData",
                        "Linux Engineer":"Linux",
                        "Algorithm Engineer":"Algorithm"]
    
    
    override init() {
        super.init()
        
        for (key, value) in languageDic {
            downloadData(typeId: value, jsonName: key)
        }
    }
    
    
    private func downloadData(typeId: String, jsonName: String) {
        
        var request = URLRequest(url: URL(string: "http://api.codertopic.com/itapi/questionsapi/questions.php?typeID=" + typeId)!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if json is [String: Any] {
                        // json is a dictionary
                        //print(object)
                        
                        let jsonFilePath = "/Users/HTC/Desktop/iTalkerDocument/jsonFiles/" + jsonName + ".json"
                        do {
                            
                            try data.write(to: URL.init(fileURLWithPath: jsonFilePath))
                            
                        } catch let error as NSError {
                            print("Couldn't write \(jsonName + ".json") to file: \(error.localizedDescription)")
                        }
                        
                    } else if let object = json as? [Any] {
                        // json is an array
                        print(object)
                        
                    } else {
                        print("JSON is invalid")
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
            
        }.resume()
    }
    
}
