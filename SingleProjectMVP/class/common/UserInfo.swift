//
//  UserInfo.swift
//  Apponlease
//
//  Created by Dota on 5/8/16.
//  Copyright © 2016 ZealotSystem. All rights reserved.
//

import UIKit

class UserInfo: NSObject {
    
    var locationTracker : LocationTracker!
    
    var curLocation : CLLocation!
    var desLocation : CLLocation!
    
    var distance : CLLocationDistance = 0
    
    var completedDate = NSMutableArray()
    var sqliteDataPath : String!
        
    class var getInstance : UserInfo
    {
        struct Static{
            static var instance : UserInfo?
            static var token : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token){
            Static.instance = UserInfo()
        }
        
        return Static.instance!
    }
}
