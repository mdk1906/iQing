//
//  QWDownloadCVC.swift
//  Qingwen
//
//  Created by Aimy on 10/13/15.
//  Copyright © 2015 iQing. All rights reserved.
//

class QWDownloadCVC: QWBaseListVC {

    var bookCDs: PageVO?
    var volumeCDs: [[VolumeCD]]?
    var loading: Bool = false

    override var listVO: PageVO? {
        return self.bookCDs
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

//        self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0);

        getData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }
    
}

extension QWDownloadCVC {
    
    override func updateWithCVCell(_ cell: QWBaseCVCell, indexPath: IndexPath) {
        if let book = self.listVO?.results[(indexPath as NSIndexPath).item] as? BookCD {
            let cell = cell as! QWListCVCell
            cell.updateWithBookCD(book)
        }
    }

}
