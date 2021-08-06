//
//  QWBooksListConentCell.swift
//  Qingwen
//
//  Created by wei lu on 31/12/17.
//  Copyright © 2017 iQing. All rights reserved.
//

import UIKit

enum BooklistsWorkActionType:Int {
    case Update
    case Delete
    case Create
}

protocol QWBooksListDetailsContentDelegate {
    func didSelectedContentCellAtIndexPath(_ sender: UIButton?)
    func cellPopView(doAction:BooklistsWorkActionType,workId:NSNumber?,data:BooksListVO?)
}

class QWBooksListContentCell:QWBaseCVCell{
    
    var content:QWBooksListContentView!
    var basicHeight:CGFloat = 250
    var delegate:QWBooksListDetailsContentDelegate?
    var cellData:BooksListVO?
    var itemId:NSNumber!
    
    func setUpViews(){
        self.content = Bundle.main.loadNibNamed("QWBooksListContentCell", owner: self, options: nil)?.first as! QWBooksListContentView
        self.contentView.addSubview(self.content!)
        self.content!.autoPinEdge(.top, to: .top, of: self.contentView)
        self.content!.autoPinEdge(.left, to: .left, of: self.contentView)
        self.content!.autoPinEdge(.right, to: .right, of: self.contentView)
        self.content!.autoPinEdge(.bottom, to: .bottom, of: self.contentView)
        self.contentView.sendSubview(toBack: self.content!)
        self.clipsToBounds = true;
        self.content!.delegate = self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateItemWithData(_ bookLists:BooksListVO,ShowAll showAll:Bool){
        self.cellData = bookLists
        self.content!.updateItemWithData(bookLists,ShowAll: showAll)
        self.itemId = bookLists.nid
        self.showAllIntro()
    }
    
    func showPopInfo(content:String){
        let info = UIAlertView.bk_alertView(withTitle: "推荐语：", message: content) as! UIAlertView
        
        info.show()
        self.perform(#selector(QWBooksListContentCell.dismissAlert), with: info, afterDelay: 2.0)
    }
    
    func dismissAlert(obj:UIAlertView){
        obj.dismiss(withClickedButtonIndex: obj.cancelButtonIndex, animated: true)
    }
    
    func showAllIntro() {
        if let content = self.content.recommed?.text {
            let introText = "推荐语："+content
            _ = NSMutableAttributedString(string: "推荐语：", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12),NSForegroundColorAttributeName: UIColor(hex:0x555555)!])

            //遇到\n，会换行
            let temText = introText.replacingOccurrences(of: "\n", with: "")
            var attributedString = NSMutableAttributedString(string: temText, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12),NSForegroundColorAttributeName: UIColor(hex:0x555555)!])
            var size = CGSize(width: CGFloat.greatestFiniteMagnitude,height:20)
            if var layout = YYTextLayout(containerSize: size, text: attributedString){
                if(layout.textBoundingSize.width > (QWSize.screenWidth() - self.content.cover.width) * 1.5){//大于1.5行
                    size = CGSize(width: (QWSize.screenWidth() - self.content.cover.width) * 1.5,height:20)
                    layout = YYTextLayout(containerSize: size, text: attributedString)!
                    let ocTemText = temText as NSString
                    attributedString = NSMutableAttributedString(string: ocTemText.substring(with: layout.visibleRange), attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12),NSForegroundColorAttributeName: UIColor(hex:0x555555)!])
                    attributedString.append(NSMutableAttributedString(string: "...", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12),NSForegroundColorAttributeName: UIColor(hex:0x555555)!]))
                    
                    let more = NSMutableAttributedString(string: "更多", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12),NSForegroundColorAttributeName: UIColor(hex:0xfb83ac)!])
                    
                    let highlight = YYTextHighlight()
                    highlight.setColor(UIColor(hex:0xfb83ac))
                    highlight.tapAction = {[weak self] (view: UIView, text: NSAttributedString, range: NSRange, rect: CGRect) in
                        self?.showPopInfo(content: ocTemText as String)
                        self?.delegate?.didSelectedContentCellAtIndexPath(nil)
                    }
                    attributedString.append(more)
                    attributedString.yy_setTextHighlight(highlight, range: attributedString.yy_rangeOfAll())
                    self.content.recommed.attributedText = attributedString;
                    size = CGSize(width: QWSize.screenWidth() - self.content.cover.width, height: CGFloat.greatestFiniteMagnitude)
                    layout = YYTextLayout(containerSize: size, text: attributedString)!
                    self.content.recommed.textLayout = layout
                    self.content.recommed.numberOfLines = 3;
                }else{
                    size = CGSize(width: QWSize.screenWidth() - self.content.cover.width, height: CGFloat.greatestFiniteMagnitude)
                    layout = YYTextLayout(containerSize: size, text: attributedString)!
                    self.content.recommed.attributedText = attributedString
                    self.content.recommed.textVerticalAlignment = .top
                    self.content.recommed.numberOfLines = 3;
                    
                    self.content.recommed.textLayout = layout
                }
            }
        }
    }
}
extension QWBooksListContentCell:cellExtraActionDelagate{

    func tapMore() {
        let action = UIActionSheet()
        action.bk_addButton(withTitle: "修改推荐语") {() in
            if(self.cellData?.work == nil){
                self.showToast(withTitle: "没有找到这本书", subtitle: nil, type: .alert)
                return
            }
            self.delegate?.cellPopView(doAction:.Update,workId: self.itemId,data:self.cellData)
        }
        
        action.bk_addButton(withTitle: "移除作品") {() in
            self.delegate?.cellPopView(doAction:.Delete,workId: self.itemId,data:self.cellData)
        }
        
        action.bk_setCancelButton(withTitle: "取消") {
            
        }
        action.show(in:  QWRouter.sharedInstance().rootVC.view)
    }
    
}
