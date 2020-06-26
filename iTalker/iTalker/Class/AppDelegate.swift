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


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        startBaiduMobStat()
        
        setupBaseUI()
        
        ITCommonAPI.sharedInstance.checkAppUpdate(newHandler: nil)
        
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        if shortcutItem.type.contains("iTer://search") {
            AppDelegate.showSearchVC()
        }
        
        if shortcutItem.type.contains("iTer://star") {
            IAppleServiceUtil.inAppRating(url: kAppDownloadURl)
        }
        
        if shortcutItem.type.contains("iTer://love") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                IAppleServiceUtil.openAppstore(url: kAppDownloadURl, isAssessment: false)
            })
        }
    }
    
    open class func showSearchVC() {
        let vc = IHTCSearchViewController()
        let navi = UINavigationController.init(rootViewController: vc)
        navi.navigationBar.isHidden = true
        UIViewController.keyWindowHTC()?.rootViewController!.present(navi, animated: true, completion: nil)
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
        
        #if !targetEnvironment(macCatalyst)
        #if DEBUG
            print("Debug modle")
            //statTracker?.channelId = "Debug"
        #else
            let statTracker = BaiduMobStat.default()
            statTracker?.channelId = "AppStore"
            statTracker?.shortAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            statTracker?.start(withAppId: "0f4db57bb7")
            
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let currentDate = formatter.string(from: Date())
        
            // 自定义事件
            statTracker?.logEvent("usermodelName", eventLabel: UIDevice.init().modelName)
            statTracker?.logEvent("systemVersion", eventLabel: UIDevice.current.systemVersion)
            statTracker?.logEvent("DateSystemVersion", eventLabel: currentDate + " " + UIDevice.current.systemVersion)
            statTracker?.logEvent("DateAndDeviceName", eventLabel: currentDate + " " + UIDevice.current.name)
            statTracker?.logEvent("Devices", eventLabel:UIDevice.current.name)
            statTracker?.logEvent("AppName", eventLabel:( Bundle.main.infoDictionary?["CFBundleName"] as! String))
        #endif
        #endif
        //         statTracker.enableDebugOn = true;
        
    }
    
    func setupBaseUI() {
        let ui = UINavigationBar.appearance()
        ui.tintColor = UIColor.white
        ui.barTintColor = kColorAppBlue
        ui.barStyle = .black
        UIApplication.shared.setStatusBarHidden(false, with: .none)
        
        
        #if targetEnvironment(macCatalyst)
        let tabbar = UITabBarItem.appearance()
        let font = UIFont.systemFont(ofSize: 18)
        tabbar.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        #endif
    }
    
}


// MARK: macOS method
#if targetEnvironment(macCatalyst)
extension AppDelegate {
    
    override func buildMenu(with builder: UIMenuBuilder) {
          guard builder.system == .main else {
              return
          }

          builder.remove(menu: .edit)
          builder.remove(menu: .format)
          builder.remove(menu: .toolbar)
    }
    
    @IBAction func showHelp(_ sender: Any) {
        IAppleServiceUtil.openWebView(url: kGithubURL, tintColor: kColorAppOrange, vc: (UIViewController.keyWindowHTC()?.rootViewController)!)
    }
    
}
#endif


// ref: https://www.avanderlee.com/swift/uikeycommand-keyboard-shortcuts/
// MARK: - Keyboard Shortcuts
extension UITabBarController {

    /// Adds keyboard shortcuts for the tabs.
    /// - Shift + Tab Index for the simulator
    open override var keyCommands: [UIKeyCommand]? {
        let tabCommand = tabBar.items?.enumerated().map { (index, item) -> UIKeyCommand in
            let keyCommand = UIKeyCommand.init(input: "\(index + 1)", modifierFlags: .command, action: #selector(selectTab))
            keyCommand.discoverabilityTitle = item.title ?? "Tab \(index + 1)"
            return keyCommand
        }

        #if !targetEnvironment(macCatalyst)
        let searchKeyCommand = UIKeyCommand.init(input: "F", modifierFlags: [.command], action: #selector(searchCommand))
        searchKeyCommand.discoverabilityTitle = HTCLocalized("Search")
        return tabCommand! + [searchKeyCommand]
        #else
        return tabCommand! //+ [searchKeyCommand]
        #endif
    }

    @objc private func selectTab(sender: UIKeyCommand) {
        UITabBarController.lastSender = sender
        guard let input = sender.input, let newIndex = Int(input), newIndex >= 1 && newIndex <= (tabBar.items?.count ?? 0) else { return }
        selectedIndex = newIndex - 1
    }

    @objc private func searchCommand(sender: UIKeyCommand) {
        AppDelegate.showSearchVC()
    }


    open override var canBecomeFirstResponder: Bool {
        return true
    }


    /// fix bug：临时修复快捷键点击后，action循环调用问题
    static var lastSender: UIKeyCommand?

    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if let sd = sender as? UIKeyCommand {
            return UITabBarController.lastSender != sd
        }
        
        return super.canPerformAction(action, withSender: sender)
    }

    @IBAction func showSearch(_ sender: Any) {
        AppDelegate.showSearchVC()
    }
}



// MARK: - Keyboard Shortcuts
extension UINavigationController {

    /*
     Adds keyboard shortcuts to navigate back in a navigation controller.
     - Shift + left arrow on the simulator
     */
    override public var keyCommands: [UIKeyCommand]? {
        guard viewControllers.count > 1 else { return [] }
        let backKeyCommand = UIKeyCommand.init(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(backCommand))
        backKeyCommand.discoverabilityTitle = HTCLocalized("Back")
        
        return [backKeyCommand]
    }

    @objc private func backCommand() {
        popViewController(animated: true)
    }
    
    open override var canBecomeFirstResponder: Bool {
        return true
    }
}


