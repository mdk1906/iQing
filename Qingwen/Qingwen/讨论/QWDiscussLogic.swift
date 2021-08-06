//
//  QWDiscussLogic.swift
//  Qingwen
//
//  Created by Aimy on 2/23/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

extension QWDiscussLogic {

    func uploadImage(_ aImage: SubmitImageVO, andCompleteBlock aBlock: QWCompletionBlock?) {
        if QWGlobalValue.sharedInstance().isLogin() == false {
            QWRouter.sharedInstance().routerToLogin()
            return
        }

        var tempImage = aImage.image?.copy() as! UIImage
        if max(tempImage.size.width, tempImage.size.height) > 1280 {
            let times = max(tempImage.size.width, tempImage.size.height) / 1280;
            tempImage = tempImage.scale(to: CGSize(width: tempImage.size.width / times, height: tempImage.size.height / times))
        }

        var params = [String: String]();
        params["token"] = QWGlobalValue.sharedInstance().token;
        params["type"] = "gallery";

        let param = QWInterface.uploadImage(withParam: params, image: tempImage) { (aResponseObject, anError) -> Void in
            aBlock?(aResponseObject, anError);
        }

        if (UIDevice.current.systemVersion as NSString).floatValue > 8.0 {
            aImage.progress = self.operationManager.upload(with: param)
        }
        else {
            self.operationManager.request(with: param)
        }
    }
}
