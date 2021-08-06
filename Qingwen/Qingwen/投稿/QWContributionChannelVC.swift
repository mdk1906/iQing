//
//  QWContributionChannelVC.swift
//  Qingwen
//
//  Created by Aimy on 4/8/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

class QWContributionChannelVC: QWBaseVC {
    lazy var logic: QWContributionLogic = {
        let logic = QWContributionLogic(operationManager: self.operationManager)
        return logic
    }()
    
    @IBOutlet var backgroundView: UIImageView!
    var activity : ActivityVO?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "locate_bg")!)
        
        // Do any additional setup after loading the view.
        self.fd_prefersNavigationBarHidden = true;
        if #available(iOS 11.0, *){
            self.backgroundView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        }
        self.getActivityList()
    }
    func getActivityList() {
        self.logic.getActivitList {[weak self](aResponseObject, anError) in
            let listVO = ActivityListVO.vo(withDict: aResponseObject as? [String : Any])
            
            if let weakSelf = self {
                if (listVO?.results?.count)! > 0{
                    weakSelf.activity = listVO?.results![0] as? ActivityVO
                }
                
                
            }
        }
    }
    override func leftBtnClicked(_ sender: AnyObject?) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? QWContributionInfoVC {
            vc.channel = sender as! UInt
            vc.logic.activitys = [activity] as? [ActivityVO]
        }
    }

    @IBAction func onPressedBoyBtn(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "book", sender: QWChannelType.type10.rawValue)
    }


    @IBAction func onPressedGirlBtn(_ sender: AnyObject) {
        
    }
    
    @IBAction func onPressedColleaguesBtn(_ sender: AnyObject) {
//        self.performSegue(withIdentifier: "book", sender: QWChannelType.type12.rawValue)
        self.performSegue(withIdentifier: "book", sender: QWChannelType.type11.rawValue)
    }
    
}
