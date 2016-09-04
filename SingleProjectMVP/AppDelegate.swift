//
//  AppDelegate.swift
//  SingleProjectMVP
//
//  Created by Nikita on 9/4/16.
//  Copyright © 2016 ksenia. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var usrInfo = UserInfo.getInstance
    var mySqliteDB : COpaquePointer = nil
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        if (NSProcessInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion: 8, minorVersion: 0, patchVersion: 0))){
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
        } else {
            if (application.respondsToSelector(#selector(UIApplication.registerUserNotificationSettings(_:)))){
                application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Badge, .Alert], categories: nil))
            }
        }
        
        
        self.copyFile()
        print(usrInfo.completedDate.count)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    func getPath(fileName: String) -> String {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileURL = documentsURL.URLByAppendingPathComponent(fileName)
        
        let dbPath = fileURL.path!
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(dbPath) {
            let documentsURL = NSBundle.mainBundle().resourceURL
            let fromPath = documentsURL!.URLByAppendingPathComponent(fileName as String)
            var error : NSError?
            do {
                try fileManager.copyItemAtPath(fromPath.path!, toPath: dbPath)
            } catch let error1 as NSError {
                error = error1
            }
            if (error != nil) {
                print(error?.localizedDescription)
            } else {
                print("Your database copy successfully")
            }
        }
        usrInfo.sqliteDataPath = dbPath
        return dbPath
    }
    
    
    func copyFile() {
        let dbPath: String = getPath("DateTimeList.db")
        var statemnet : COpaquePointer = nil
        let sql = "SELECT * FROM TimeList"
        
        if sqlite3_open(dbPath.cStringUsingEncoding(NSUTF8StringEncoding)!, &mySqliteDB) == SQLITE_OK {
            if sqlite3_prepare_v2(mySqliteDB, sql.cStringUsingEncoding(NSUTF8StringEncoding)!, -1, &statemnet, nil) == SQLITE_OK {
                while sqlite3_step(statemnet) == SQLITE_ROW {
                    let date   = String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(statemnet, 1)))!
                    usrInfo.completedDate.addObject(date)
                }
            }
            
            sqlite3_finalize(statemnet)
            sqlite3_close(mySqliteDB)
        }
    }

    
}

