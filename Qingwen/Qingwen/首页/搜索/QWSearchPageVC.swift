//
//  QWSearchPageVC.swift
//  Qingwen
//
//  Created by mumu on 16/8/26.
//  Copyright © 2016年 iQing. All rights reserved.
//

import UIKit

class QWSearchPageVC: QWBasePaperVC {

    lazy var firstVC: QWSearchBookVC = {
        let vc = QWSearchBookVC.createFromStoryboard(withStoryboardID: "searchbook", storyboardName: "QWSearch")!
        vc.game = false
        vc.extraData = self.extraData
        self.addChildViewController(vc)
        return vc
    }()

    lazy var secondVC: QWSearchGameVC = {
        let vc = QWSearchGameVC.createFromStoryboard(withStoryboardID: "searchgame", storyboardName: "QWSearch")!
        vc.game = true
        vc.extraData = self.extraData
        self.addChildViewController(vc)

        return vc
    }()
    
    lazy var thirdVC: QWSearchActivityVC = {
        let vc = QWSearchActivityVC.createFromStoryboard(withStoryboardID: "searchactivity", storyboardName: "QWSearch")!
        self.addChildViewController(vc)

        return vc
    }()
    
    lazy var fouthVC: QWSearchActivityVC = {
        let vc = QWSearchActivityVC.createFromStoryboard(withStoryboardID: "searchactivity", storyboardName: "QWSearch")!
        var params = [String: AnyObject]()
        params["topic"] = 1 as AnyObject
        vc.extraData = params
        self.addChildViewController(vc)

        return vc
    }()
    
    lazy var fifthVC: QWSearchUserVC = {
        let vc = QWSearchUserVC.createFromStoryboard(withStoryboardID: "searchuser", storyboardName: "QWSearch")!
        self.addChildViewController(vc)
        return vc
    }()
    
    lazy var sixthVC: QWSearchFavoriteVC = {
        let vc = QWSearchFavoriteVC.createFromStoryboard(withStoryboardID: "searchfavorite", storyboardName: "QWSearch")!
        self.addChildViewController(vc)
        return vc
    }()
    
    lazy var logic: QWSearchLogic = {
        return QWSearchLogic(operationManager: self.operationManager)
    }()
    
    var keyWords: String?
    
    var titles = ["小说", "演绘", "活动", "专题", "用户","书单"]
    override var segmentTitles: [String] {
        return titles
    }
    
    override var pages: [UIViewController]? {
        return [self.firstVC, self.secondVC,self.thirdVC, self.fouthVC,self.fifthVC,self.sixthVC]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func getCount() {
        guard let ketwords = self.keyWords else {
            return
        }
        if self.logic.isLoading {
            return
        }
        self.logic.isLoading = true
        self.logic.getCountsWithKeywords(ketwords) { [weak self](_, _) in
            if let weakSelf = self {
                weakSelf.titles = ["小说", "演绘", "活动", "专题", "用户","书单"]
                weakSelf.logic.isLoading = false
                if let searchCounts = weakSelf.logic.searchCounts as? [SearchCount]{
                    for (_, searchCount) in searchCounts.enumerated() {
                        if searchCount.work_type!.intValue > 0 {
                            if searchCount.count!.intValue > 99 {
                                weakSelf.titles[(searchCount.work_type!.intValue - 1)] = "\(weakSelf.titles[(searchCount.work_type!.intValue - 1)])(99)"
                            }
                            else if searchCount.count!.intValue > 0 {
                                weakSelf.titles[(searchCount.work_type!.intValue - 1)] = "\(weakSelf.titles[(searchCount.work_type!.intValue - 1)])(\(searchCount.count!))"
                            }
                        }
                    }
                }
                weakSelf.segmentPaper?.reloadData()
            }
        }
    }
    
    override func update() {
        self.getCount()
        self.firstVC.keyWords = self.keyWords
        self.firstVC.change = true
        
        self.secondVC.keyWords = self.keyWords
        self.secondVC.change = true

        self.thirdVC.keyWords = self.keyWords
        self.thirdVC.change = true

        self.fouthVC.keyWords = self.keyWords
        self.fouthVC.change = true

        self.fifthVC.keyWords = self.keyWords
        self.fifthVC.change = true

        self.sixthVC.keyWords = self.keyWords
        self.sixthVC.change = true
        
        if self.segmentPaper?.pager.indexForSelectedPage == 0 {
            self.firstVC.update()
        }
        else if self.segmentPaper?.pager.indexForSelectedPage == 1 {
            self.secondVC.update()
        }
        else if self.segmentPaper?.pager.indexForSelectedPage == 2 {
            self.thirdVC.update()
        }
        else if self.segmentPaper?.pager.indexForSelectedPage == 3 {
            self.fouthVC.update()
        }
        else if self.segmentPaper?.pager.indexForSelectedPage == 4 {
            self.fifthVC.update()
        }
        else if self.segmentPaper?.pager.indexForSelectedPage == 5 {
            self.sixthVC.update()
        }
    }
}
