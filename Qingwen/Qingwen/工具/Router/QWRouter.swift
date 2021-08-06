//
//  QWRouter.swift
//  Qingwen
//
//  Created by Aimy on 10/12/15.
//  Copyright © 2015 iQing. All rights reserved.
//

let vcTypes: [QWBaseVC.Type] = [QWListVC.self, QWUserListVC.self, QWMyAttentionPeopleVC.self, QWRankingVC.self, QWChoosePhotoVC.self, QWChargeVC.self, QWRankingVC.self, QWBoutiqueVC.self,QWShopPageVC.self, QWActivityVC.self,QWActivityPageVC.self,QWContributionVC.self, QWHomeVC.self,QWBookLibraryVC.self, QWGameLibraryVC.self,QWBooksListCreate.self,QWBooksListDetails.self,QWAddMyCollectionTVC.self,QWBookCommentsListTVC.self,QWFavoriteListTBC.self]

typealias QWNativeFuncVOBlockType = @convention(block) ([String: AnyObject]) -> AnyObject?

protocol QWRouterMapping {
    static func registMapping();
    static func getStoryBoardIDOrNibNameWithType(_ type: Int) -> String?
}

extension QWBaseVC: QWRouterMapping {
    class func registMapping() {

    }

    class func getStoryBoardIDOrNibNameWithType(_ type: Int) -> String? {
        return nil
    }
}

extension QWRouter {
    func registMapping() {
        vcTypes.forEach { $0.registMapping() }
    }
}
