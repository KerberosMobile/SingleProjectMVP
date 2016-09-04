//
//  Tab_3_VC.swift
//  SingleProjectMVP
//
//  Created by Nikita on 9/4/16.
//  Copyright © 2016 ksenia. All rights reserved.
//

import UIKit

class Tab_3_VC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableview: UITableView!
    
    var usrInfo = UserInfo.getInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Tab_1_VC.showAlaert), name: "TravelCompletedAlarm", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Tab_3_VC.reloadList), name: "TravelCompletList", object: nil)
        
//        for _ in 0..<5 {
//            let date = NSDate()
//            let formatter = NSDateFormatter()
//            formatter.dateFormat = "YYYY/MM/dd HH:mm"
//            let currentDate:NSString = formatter.stringFromDate(date)
//            usrInfo.completedDate.addObject(currentDate)
//        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func reloadList(){
        tableview.reloadData()
    }

    //Delegate TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usrInfo.completedDate.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CompletedTravelList", forIndexPath: indexPath)
        cell.textLabel?.text = usrInfo.completedDate.objectAtIndex(indexPath.row) as? String
        return cell;
    }
    

}
