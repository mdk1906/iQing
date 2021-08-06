//
//  QWFavoriteBooks.swift
//  Qingwen
//
//  Created by wei lu on 9/02/18.
//  Copyright © 2018 iQing. All rights reserved.
//

protocol QWFavoriteBooksDelegate {
    func cellPopAction(doAction:BooklistsWorkActionType,workId:NSNumber?,data:BooksListVO?)
    func getMore()
}

class QWFavoriteBooks:QWBaseVC{
    lazy var bodyCollectionView:QWCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = QWCollectionView(frame: .zero, collectionViewLayout: layout )
        collection.isPagingEnabled = true
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.dataSource = self
        collection.delegate = self
        
        return collection
    }()
    
    var cellData:FavoriteBooksInListVO?
    var isOwn:Bool?
    var delegate:QWFavoriteBooksDelegate?
    
    override func viewDidLoad() {
        self.setUpViews()
        self.bodyCollectionView.register(QWBooksListContentCell.self, forCellWithReuseIdentifier: "cellId")
//        self.bodyCollectionView.mj_footer = MJRefreshAutoFooter(refreshingBlock: { [weak self] () -> Void in
//            self?.more()
//        })
    }
    
    func setUpViews(){
        self.view.addSubview(self.bodyCollectionView)
        self.bodyCollectionView.autoPinEdge(.top, to: .top, of: self.view)
        self.bodyCollectionView.autoPinEdge(.left, to: .left, of: self.view)
        self.bodyCollectionView.autoPinEdge(.right, to: .right, of: self.view)
        self.bodyCollectionView.autoPinEdge(.bottom, to: .bottom, of: self.view)
        //
    }
    
    func updateItemWithData(_ logicData:QWGetBookslistDetailsLogic){
        self.cellData = logicData.bookList
    }
    
//    func more(){
//        self.delegate?.getMore()
//    }
    
    override func getMoreData() {
        self.delegate?.getMore()
    }
    
}

extension QWFavoriteBooks:QWBooksListDetailsContentDelegate{
    func didSelectedContentCellAtIndexPath(_ sender: UIButton?){
        
    }
    
    func cellPopView(doAction:BooklistsWorkActionType,workId:NSNumber?,data:BooksListVO?){
        self.delegate?.cellPopAction(doAction: doAction,workId: workId,data: data)
    }
}

extension QWFavoriteBooks:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(self.cellData?.results != nil){
            return self.cellData!.results!.count/2
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: QWSize.screenWidth(), height: 100)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
            
            if let list = self.cellData?.results, let amount = self.cellData?.count?.intValue {
                if list.count == indexPath.row + 1 && list.count < amount {
                    getMoreData()
                    
                }
            }
            return cell
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
        if let work = self.cellData?.results?[(indexPath as NSIndexPath).item] as? BooksListVO{
            didSelectItemAtIndex(work)
        }
    }
}
