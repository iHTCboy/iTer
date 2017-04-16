//
//  AppDelegate.swift
//  iTalker
//
//  Created by HTC on 2017/4/8.
//  Copyright © 2017年 iHTCboy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        startBaiduMobStat()
        
        setupBaseUI()
        
        checkAppUpdate()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

// MARK: Prive method
extension AppDelegate {
    
    func startBaiduMobStat() {
        
        let statTracker = BaiduMobStat.default()
        #if DEBUG
            statTracker?.channelId = "Debug"
        #else
            statTracker?.channelId = "AppStore"
        #endif
        statTracker?.shortAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        statTracker?.start(withAppId: "0f4db57bb7")
        //         statTracker.enableDebugOn = true;
        
    }
    
    func setupBaseUI() {
        let ui = UINavigationBar.appearance()
        ui.tintColor = UIColor.white
        ui.barTintColor = kColorAppBlue
        
        UIApplication.shared.setStatusBarHidden(false, with: .none)
    }
    
    func checkAppUpdate() {
        
        var request = URLRequest(url: URL(string: "https://itunes.apple.com/lookup?id=" + kAppAppleId)!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: request) {data, response, err in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let responseObject = json as? [String: Any] {
                        // json is a dictionary
                        //print(responseObject)
                        let resultCount = responseObject["resultCount"] as! Int
                        if resultCount == 0 {
                            return
                        }
                        
                        let serverVersionArr = responseObject["results"] as! NSArray
                        let serverVersionDic = serverVersionArr[0] as! NSDictionary
                        let serverVersion = serverVersionDic["version"] as! NSString
                        let localVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! NSString
                        
                        //以"."分隔数字然后分配到不同数组
                        let serverArray = serverVersion.components(separatedBy: ".")
                        let localArray = localVersion.components(separatedBy: ".")
                        let counts = min(serverArray.count, localArray.count)
                        for i in (0..<counts) {
                            //判断本地版本位数小于服务器版本时，直接返回（并且判断为新版本，比如 本地为1.5 服务器1.5.1）
                            if localArray.count < serverArray.count {
                                self.showNewVersion(version: serverVersion , resultDic: serverVersionDic)
                                break
                            }
                            
                            //有新版本，服务器版本对应数字大于本地
                            if  Int(serverArray[i])! >  Int(localArray[i])! {
                                self.showNewVersion(version: serverVersion , resultDic: serverVersionDic)
                                break
                            }else if Int(serverArray[i])! < Int(localArray[i])! {
                                break;
                            }
                            
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
    
    func showNewVersion(version: NSString, resultDic: NSDictionary) {
        print(version)
        
        let title = "发现新版本v" + (version as String)
        
        let alert = UIAlertController(title: title,
                                      message: "赶快体验最新版本吧！是否前往AppStore更新？",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction.init(title: "OK", style: .default) { (action: UIAlertAction) in
            UIApplication.shared.openURL(URL(string: "https://itunes.apple.com/cn/app/yi-mei-yun/id" + kAppAppleId + "?l=zh&ls=1&mt=8")!)
        }
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel) { (action: UIAlertAction) in
            
        }
        alert.addAction(cancelAction)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let vc = UIApplication.shared.keyWindow?.rootViewController;
            vc?.present(alert, animated: true, completion: {
                //print("UIAlertController present");
            })
        }
    }

}


