//
//  QWListVC.swift
//  Qingwen
//
//  Created by Aimy on 10/12/15.
//  Copyright © 2015 iQing. All rights reserved.
//

class QWBaseListVC: QWBaseVC {

    @IBOutlet var tableView: QWTableView!
    @IBOutlet var collectionView: QWCollectionView!
    @IBOutlet var layout: UICollectionViewFlowLayout!

    var type = 0

    var customSection = 1
    
    var game = false

    var useSection = false
    
    var listVO: PageVO? {
        return nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        if tableView == nil {
            tableView = QWTableView()
        }

        if layout == nil {
            layout = UICollectionViewFlowLayout()
        }

        if collectionView == nil {
            collectionView = QWCollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        }

        self.tableView.separatorInset = UIEdgeInsets.zero;
        if #available(iOS 8, *) {
            self.tableView.layoutMargins = UIEdgeInsets.zero;
        }

        let os = ProcessInfo().operatingSystemVersion
        
        switch  (os.majorVersion, os.minorVersion, os.patchVersion) {
        case  (10, _, _):
            self.tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 49, right: 0)
        default :
            break
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let extraData = self.extraData {
            if let type = extraData.objectForCaseInsensitiveKey("type") as? NSNumber {
                self.type = type.intValue
            }
        }

        if self.type == 0 {
            self.tableView.isHidden = true
            self.tableView.delegate = nil
            self.tableView.dataSource = nil
            self.collectionView.isHidden = false
        }
        else {
            self.tableView.isHidden = false
            self.collectionView.delegate = nil
            self.collectionView.dataSource = nil
            self.collectionView.isHidden = true
        }

        self.tableView.rowHeight = 130;

        self.layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
        self.layout.minimumInteritemSpacing = 5
        self.layout.minimumLineSpacing = 5
        self.layout.headerReferenceSize = CGSize.zero
        self.layout.footerReferenceSize = CGSize.zero
    }

    override func resize(_ size: CGSize) {
        self.layout?.invalidateLayout()
    }

    override func setPageShow(_ enable: Bool) {
        self.tableView.scrollsToTop = false
        self.collectionView.scrollsToTop = false
        
        if self.type == 0 {
            self.collectionView.scrollsToTop = enable
        }
        else {
            self.tableView.scrollsToTop = enable
        }
    }
    func getLabWidth(labelStr:String,font:UIFont,height:CGFloat) -> CGFloat {
        
        let statusLabelText: NSString = labelStr as NSString
        
        let size = CGSize(width:900, height:height)
        
        let dic = NSDictionary(object: font, forKey: NSFontAttributeName as NSCopying)
        
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [String : AnyObject], context: nil).size
        
        return strSize.width
        
    }
    func getLabHeight(labelStr:String,font:UIFont,width:CGFloat) -> CGFloat {
        
        let statusLabelText: NSString = labelStr as NSString
        
        let size = CGSize(width:width, height:900)
        
        let dic = NSDictionary(object: font, forKey: NSFontAttributeName as NSCopying)
        
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [String : AnyObject], context: nil).size
        
        return strSize.height
        
    }
}

extension QWBaseListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if useSection {
            if let vos = self.listVO?.results {
                return vos.count
            }
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let vos = self.listVO?.results {
            if useSection {
                return 1
            }
            else {
                return vos.count
            }
        }

        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QWBaseTVCell

        if #available(iOS 8.0, *) {
            cell.layoutMargins = UIEdgeInsets.zero
        }

        updateWithTVCell(cell, indexPath: indexPath)
        
        if useSection {
            if let list = listVO?.results, let count = listVO?.count?.intValue, list.count == indexPath.section + 1, list.count < count {
                getMoreData()
            }
        }
        else {
            if let list = listVO?.results, let count = listVO?.count?.intValue {
                if list.count == indexPath.row + 1 && list.count < count {
                    getMoreData()
                    
                }
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didSelectedCellAtIndexPath(indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.tableFooterView == nil {
            if useSection {
                if let list = listVO?.results, let count = listVO?.count?.intValue, list.count == indexPath.section + 1, list.count < count {
                    getMoreData()
                }
            }
            else {
                if let list = listVO?.results, let count = listVO?.count?.intValue {
                    if list.count == indexPath.row + 1 && list.count < count {
                        getMoreData()
                        
                    }
                }
            }
        }
    }
}

protocol QWBaseListVCDelegate {
    func updateWithCVCell(_ cell: QWBaseCVCell, indexPath: IndexPath)
    func updateWithTVCell(_ cell: QWBaseTVCell, indexPath: IndexPath)
    func didSelectedCellAtIndexPath(_ indexPath: IndexPath)
}

extension QWBaseListVC: QWBaseListVCDelegate {

    func updateWithCVCell(_ cell: QWBaseCVCell, indexPath: IndexPath) {

    }

    func updateWithTVCell(_ cell: QWBaseTVCell, indexPath: IndexPath) {

    }

    func didSelectedCellAtIndexPath(_ indexPath: IndexPath) {
        
    }
}

extension QWBaseListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (SWIFT_IS_IPHONE_DEVICE) {
            let width = floor((QWSize.screenWidth() - 40) / 3)
            return CGSize(width: width, height: width / 0.75 + 30);
        }
        else {
            if (UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation)) {
                let width = floor((QWSize.screenWidth() - 70) / 6)
                return CGSize(width: width, height: width / 0.75 + 30);
            }
            else {
                let width = floor((QWSize.screenWidth() - 50) / 4)
                return CGSize(width: width, height: width / 0.75 + 30);
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let listCount = listVO?.results.count , let pageCount = listVO?.count?.intValue,listCount < pageCount {
            return CGSize(width: QWSize.screenWidth(), height: 44)
        }

        return CGSize.zero
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let vos = self.listVO?.results {
            return vos.count
        }

        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! QWBaseCVCell
        updateWithCVCell(cell, indexPath: indexPath)

        if let list = listVO?.results, let count = listVO?.count?.intValue {
            if list.count == indexPath.item + 1 && list.count < count {
                getMoreData()
                
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        didSelectedCellAtIndexPath(indexPath)
    }
}
