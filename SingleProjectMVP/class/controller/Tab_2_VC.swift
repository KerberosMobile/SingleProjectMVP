//
//  Tab_2_VC.swift
//  SingleProjectMVP
//
//  Created by Nikita on 9/4/16.
//  Copyright © 2016 ksenia. All rights reserved.
//

import UIKit

class Tab_2_VC: UIViewController {

    @IBOutlet weak var lbl_distance: UILabel!
    var usrInfo = UserInfo.getInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Tab_2_VC.refresh), name: "refreshDistance", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Tab_1_VC.showAlaert), name: "TravelCompletedAlarm", object: nil)
        self.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        
        self.lbl_distance.text = String(format: "%.2fm",  usrInfo.distance)
    }


}
