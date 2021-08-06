//
//  QWBooksListConentCell.swift
//  Qingwen
//
//  Created by wei lu on 31/12/17.
//  Copyright © 2017 iQing. All rights reserved.
//

import UIKit

protocol QWBooksListBodyCellDelegate {
    func cellPopAction(doAction:BooklistsWorkActionType,workId:NSNumber?,data:BooksListVO?)
}

class QWBooksListBodyCell:QWBaseCVCell{
    lazy var bodyCollectionView:QWCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collection = QWCollectionView(frame: .zero, collectionViewLayout: layout )
        collection.isPagingEnabled = true
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.dataSource = self
        collection.delegate = self
        return collection
    }()
    
    var cellData:FavoriteBooksInListVO?
    var faithData:UserPageVO?
    var isOwn:Bool?
    var estmateHeight:CGFloat = 281
    var basicHeight:CGFloat = 250
    var itemId:NSNumber!
    var delegate:QWBooksListBodyCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
    }
    
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //setUpViews()

    }
    
    func setUpViews(){
        self.contentView.addSubview(self.bodyCollectionView)
        self.bodyCollectionView.autoPinEdge(.top, to: .top, of: self.contentView)
        self.bodyCollectionView.autoPinEdge(.left, to: .left, of: self.contentView)
        self.bodyCollectionView.autoPinEdge(.right, to: .right, of: self.contentView)
        self.bodyCollectionView.autoPinEdge(.bottom, to: .bottom, of: self.contentView)
//
    }
    
    func updateItemWithData(_ logicData:QWGetBookslistDetailsLogic){
        self.cellData = logicData.bookList
        self.faithData = logicData.faithPointsPage
    }

}

extension QWBooksListBodyCell:QWBooksListDetailsContentDelegate{
    func didSelectedContentCellAtIndexPath(_ sender: UIButton?){
        
    }
    
    func cellPopView(doAction:BooklistsWorkActionType,workId:NSNumber?,data:BooksListVO?){
        self.delegate?.cellPopAction(doAction: doAction,workId: workId,data: data)
    }
}

extension QWBooksListBodyCell:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(section == 0){
            if(self.cellData?.results != nil){
                return self.cellData!.results!.count
            }
        }
        if(section == 1){
            return 1
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(indexPath.section == 0){
            return CGSize(width: QWSize.screenWidth(), height: 100)
        }else if(indexPath.section == 1){
            return CGSize(width: QWSize.screenWidth(), height: 281)
        }
       return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(indexPath.section == 0){
            self.bodyCollectionView.register(QWBooksListContentCell.self, forCellWithReuseIdentifier: "cellId")
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as? QWBooksListContentCell{
                cell.delegate = self
                if let items = self.cellData?.results[indexPath.item] as? BooksListVO{
                    cell.updateItemWithData(items, ShowAll: false)
                }
                
                if let headerItems = self.isOwn{
                    if(headerItems == false){
                        cell.content.extraBtn.isEnabled = false
                        cell.content.extraBtn.alpha = 0.0
                    }else{
                        cell.content.extraBtn.alpha = 1.0
                        cell.content.extraBtn.isHidden = false
                    }
                }
                return cell
            }
        }else if(indexPath.section == 1){
            self.bodyCollectionView.register(QWBooksListLatestCell.self, forCellWithReuseIdentifier: "QWBooksListLatestCell")
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QWBooksListLatestCell", for: indexPath) as? QWBooksListLatestCell{
                if let items = self.faithData{
                    cell.updateItemWithData(items)
                }
                cell.listID = self.itemId
                return cell
            }
        }
        
        return UICollectionViewCell()

    }
        
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        func didSelectItemAtIndex(_ item: BooksListVO) {
            if let book = item.work {
                var params = [String: String]()
                params["id"] = book.nid?.stringValue
                params["book_url"] = book.url
                if item.work_type == .game {
                    QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "gamedetail", andParams: params))
                }
                else {
                    QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "book", andParams: params))
                }
            }
        }
        if(indexPath.section == 0){
            if let work = self.cellData?.results?[(indexPath as NSIndexPath).item] as? BooksListVO{
                didSelectItemAtIndex(work)
            }
        }else if (indexPath.section == 1){
            
        }
    }
}

