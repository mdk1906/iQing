//
//  QWFavoritesBooksCRView.swift
//  Qingwen
//
//  Created by wei lu on 14/12/17.
//  Copyright © 2017 iQing. All rights reserved.
//
class QWFavoriteBooksHeaderCRView: QWBaseCRView {
    

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightLabel: UIButton!
    @IBOutlet weak var actionImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        rightLabel.addTarget(self, action:#selector(self.tappedCreateBooks), for: .touchDown)
        
    }
    
    func tappedCreateBooks(){
        if(QWGlobalValue.sharedInstance().created_favorite == 1){
            let alert2 = UIAlertView.bk_alertView(withTitle: "提示", message: "您已经有了一个书单，不能重复创建") as! UIAlertView
            alert2.bk_addButton(withTitle: "确定", handler: {
                
            })
            alert2.show()
            return
        }else if(QWGlobalValue.sharedInstance().created_favorite == 0 || QWGlobalValue.sharedInstance().created_favorite == nil){
            let alert1 = UIAlertView.bk_alertView(withTitle: "提示", message: "您只能创建一个书单，请小心使用创建功能") as! UIAlertView
            alert1.bk_setCancelButton(withTitle: "确定", handler: {
                var params = [String:String]()
                params["action"] = "create"
                QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "CreateNewBooksList", andParams: params))
            })
            alert1.bk_setCancelButton(withTitle: "取消", handler: {
                
            })
            alert1.show()
        }
    }
    
    func updateWithIndexPath(_ indexPath: IndexPath) {
        
        //self.actionImageView.tag = (indexPath as NSIndexPath).section
        self.tag = (indexPath as NSIndexPath).section
        self.actionImageView.isHidden = true
        self.rightLabel.isHidden = true
        
        switch QWFavoriteBooksCVC.QWFavouriteBooksType(section: (indexPath as NSIndexPath).section) {
        case .booksRecommend:
            self.titleLabel.isHidden = false
            self.titleLabel.text = "书单推荐"
        case .booksMyFavorite:
            self.titleLabel.isHidden = false
            self.actionImageView.isHidden = false
            self.titleLabel.text = "我的书单"
            self.rightLabel.isHidden = false
        case .booksMyCollection:
            self.actionImageView.isHidden = true
            self.titleLabel.isHidden = false
            self.titleLabel.text = "我收藏的书单"
        default:
            self.titleLabel.isHidden = false
            self.actionImageView.isHidden = true
        }
    }
}
