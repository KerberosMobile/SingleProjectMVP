//
//  Tab_1_VC.swift
//  SingleProjectMVP
//
//  Created by Nikita on 9/4/16.
//  Copyright © 2016 ksenia. All rights reserved.
//

import UIKit
import MapKit


class Tab_1_VC: UIViewController, LocationTrackerDelegate, MKMapViewDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lbl_address: UILabel!
    
    var curLocationManager : LocationTracker!
    var usrInfo = UserInfo.getInstance
    var geoCodeResqust = false
    var mySqliteDB : COpaquePointer = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Tab_1_VC.showAlaert), name: "TravelCompletedAlarm", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Tab_1_VC.appWillForeground), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        curLocationManager = usrInfo.locationTracker
        if curLocationManager == nil {
            usrInfo.locationTracker = LocationTracker()
            curLocationManager = usrInfo.locationTracker
        }
        curLocationManager.delegate = self
        curLocationManager.startLocationTracking()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func appWillForeground() {
        if UIApplication.sharedApplication().applicationIconBadgeNumber == 1 {
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            
            let alert = UIAlertController(title: "Complete", message: "You travelled 50 meters", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,    handler:{(action:UIAlertAction) in
                self.usrInfo.curLocation = nil
                self.usrInfo.distance = 0
                self.curLocationManager.startLocationTracking()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func showAlaert() {
        self.curLocationManager.stopLocationTracking()
        
        if UIApplication.sharedApplication().applicationState == .Active
        {
            let alert = UIAlertController(title: "Complete", message: "You travelled 50 meters", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,    handler:{(action:UIAlertAction) in
                self.usrInfo.curLocation = nil
                self.usrInfo.distance = 0
                self.curLocationManager.startLocationTracking()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            let localNotification = UILocalNotification()
            localNotification.fireDate             = NSDate(timeIntervalSinceNow: 1)
            localNotification.alertBody            = "You travelled 50 meters";
            localNotification.timeZone             = NSTimeZone.defaultTimeZone()
            localNotification.soundName            = UILocalNotificationDefaultSoundName;
            
            localNotification.applicationIconBadgeNumber = 1
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            
        }
        
        
    }
    
    func InsertFile() {
        
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "YYYY/MM/dd HH:mm"
        let currentDate: NSString = formatter.stringFromDate(date)
        
        usrInfo.completedDate.addObject(currentDate)
        
        let dbPath = usrInfo.sqliteDataPath
        var statemnet : COpaquePointer = nil
        let sql = "INSERT INTO TimeList (date) VALUES (?);"
        
        if sqlite3_open(dbPath.cStringUsingEncoding(NSUTF8StringEncoding)!, &mySqliteDB) == SQLITE_OK {
            if sqlite3_prepare_v2(mySqliteDB, sql.cStringUsingEncoding(NSUTF8StringEncoding)!, -1, &statemnet, nil) == SQLITE_OK {
                sqlite3_bind_text(statemnet, 1, currentDate.UTF8String, -1, nil)
                
            }
            if sqlite3_step(statemnet) == SQLITE_DONE {
                print("Successfully insert row")
            } else {
                print("Could not insert row")
            }
            
            sqlite3_finalize(statemnet)
            sqlite3_close(mySqliteDB)
        } else {
            print("Insert statment could not be prepared")
        }
    }

    
    // Delegate LocationTracker
    func locationTracker(tracker: LocationTracker!, didStayedLocation stayedLocation: CLLocation!) {
        let geoCoder = CLGeocoder()
        if self.geoCodeResqust == false {
            self.geoCodeResqust = true
            geoCoder.reverseGeocodeLocation(stayedLocation, completionHandler: { (placemarks, error) -> Void in
                print(stayedLocation)
                if error == nil {
                    let placeArray = placemarks as [CLPlacemark]!
                    
                    var placeMark: CLPlacemark!
                    placeMark = placeArray?[0]
                    
                    print(placeMark.addressDictionary)
                    self.InsertFile()
                    self.lbl_address.text = "\((placeMark.addressDictionary!["Thoroughfare"])!), \((placeMark.addressDictionary!["City"])!)"
                }
                
            })
        }
        

        
        
    }
    func locationTracker(tracker: LocationTracker!, didUpdatedLocations lastLocation: CLLocation!) {
        
        let geoCoderRequestMeters = 10.0
        
        if usrInfo.curLocation == nil {
            usrInfo.curLocation = lastLocation
        }
        
        usrInfo.desLocation = lastLocation
        
        let distanceMeter = usrInfo.desLocation.distanceFromLocation(usrInfo.curLocation)
        usrInfo.distance = distanceMeter
        
        NSNotificationCenter.defaultCenter().postNotificationName("refreshDistance", object: nil, userInfo: nil)
        
        if distanceMeter > geoCoderRequestMeters {
            self.geoCodeResqust = false
        }
        
        let geoCoder = CLGeocoder()
        if self.geoCodeResqust == false {
            self.geoCodeResqust = true
            geoCoder.reverseGeocodeLocation(lastLocation, completionHandler: { (placemarks, error) -> Void in
                if error == nil {
                    let placeArray = placemarks as [CLPlacemark]!
                    
                    var placeMark: CLPlacemark!
                    placeMark = placeArray?[0]
                    
                    print(placeMark.addressDictionary)
                    
                    self.lbl_address.text = "\((placeMark.addressDictionary!["Thoroughfare"])!), \((placeMark.addressDictionary!["City"])!)"
                }
                
            })
        }
        
        if distanceMeter > 50.0 {
            NSNotificationCenter.defaultCenter().postNotificationName("TravelCompletedAlarm", object: nil, userInfo: nil)
            
            self.InsertFile()
            NSNotificationCenter.defaultCenter().postNotificationName("TravelCompletList", object: nil, userInfo: nil)
        }
    }
    
    // Delegatge MapView
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        let region : MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 500, 500)
        self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
    }

}
