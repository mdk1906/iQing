//
//  QWMyCommentsVC.swift
//  Qingwen
//
//  Created by qingwen on 2018/4/27.
//  Copyright © 2018年 iQing. All rights reserved.
//

import UIKit
class QWMyCommentsVC: QWBaseVC,UITableViewDelegate,UITableViewDataSource {
    var tableView : QWTableView?
    var cellID = "QWMyCommentsTVCell"
    var data = [CommentsVO]()
    var btnStr :String?
    var btnArr = [UIButton]()
    var emptyView : UIImageView!
    var uid :String?
    var nextStr :String?
    var listCount : Int?
    var listVO = CommentsVO.self
    lazy var logic: QWMyCenterLogic = {
        return QWMyCenterLogic(operationManager: self.operationManager)
    }()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextStr = ""
        self.listCount = 0
        self.getData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView = QWTableView()
        if (QWSize.screenHeight() == 812.0) {
            tableView?.frame = CGRect(x:0,y:114+24,width:QWSize.screenWidth(),height:QWSize.screenHeight()-114-24)

        }
        else{
            tableView?.frame = CGRect(x:0,y:114,width:QWSize.screenWidth(),height:QWSize.screenHeight()-114)

        }
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.backgroundColor = UIColor.white
        tableView?.showsVerticalScrollIndicator = false
        tableView?.separatorStyle = .none
        tableView?.register(QWMyCommentsTVCell.self, forCellReuseIdentifier: cellID)
        
        tableView?.mj_footer = MJRefreshAutoFooter(refreshingBlock: { [weak self] () -> Void in
            if (self?.data.count)! >= (self?.listCount)!{
                
            }else{
                self?.getMoreData()
            }
            
        })
        self.view.addSubview(tableView!)
        self.createBtn()
        self.createEmpty()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func createEmpty()  {
        emptyView = UIImageView.init()
        emptyView.frame = CGRect(x:(QWSize.screenWidth()-200)/2,y:200,width:200,height:200)
        emptyView.image = UIImage(named: "empty_1_none")
        emptyView.isHidden = true
        self.view.addSubview(emptyView)
    }
    override func getData()  {
        self.data = [CommentsVO]()
        self.showLoading()
        emptyView.isHidden = true
        nextStr = ""
        self.listCount = 0
        let params = [NSString: AnyObject]()
        
        let url = "\(QWOperationParam.currentBfDomain())/v3/post/" + uid! + "/send_log/?refer=" + btnStr!
        let currentUrl = url
        let param = QWInterface.getWithUrl(currentUrl, params: params) { (aResponseObject, anError) -> Void in
            if anError != nil {
                
                return ;
            }
            
            if let dict = aResponseObject as? [String: AnyObject] {
                let count = dict["count"] as! Int
                self.listCount = count
                if count  > 15{
                    self.nextStr = dict["next"] as? String
                }
                else{
                    self.nextStr = ""
                }
                var results = [Dictionary<String, Any>]()
                results = dict["results"] as! [Dictionary<String, Any>]
                for item in results {
                    print(item)
                    let post = CommentsVO.vo(withDict: item)
                    self.data.append(post!)
                }
                self.hideLoading()
                self.tableView?.reloadData()
                if self.data.count == 0{
                    self.emptyView?.isHidden = false
                }
                
            }
        }
        
        self.operationManager.request(with: param)
    }
    
    override func getMoreData()  {
        let params = [NSString: AnyObject]()
        
        //        let url = "\(QWOperationParam.currentBfDomain())/v3/post/" + uid! + "/send_log/?refer=" + btnStr!
        let currentUrl = "\(QWOperationParam.currentBfDomain())" + nextStr!
        let param = QWInterface.getWithUrl(currentUrl, params: params) { (aResponseObject, anError) -> Void in
            if anError != nil {
                
                return ;
            }
            
            if let dict = aResponseObject as? [String: AnyObject] {
                if dict["count"] != nil{
                    let count = dict["count"] as! Int
                    self.listCount = count
                    if count  > 15{
                        self.nextStr = dict["next"] as? String
                        var results = [Dictionary<String, Any>]()
                        results = dict["results"] as! [Dictionary<String, Any>]
                        for item in results {
                            print(item)
                            let post = CommentsVO.vo(withDict: item)
                            self.data.append(post!)
                        }
                        self.hideLoading()
                        self.tableView?.reloadData()
                        self.tableView?.mj_footer.endRefreshing()
                        if self.data.count == 0{
                            self.emptyView?.isHidden = false
                        }
                    }else{
                        self.nextStr = ""
                    }
                }
                
                
                
            }
        }
        print("count12345 = ",self.data.count)
        self.operationManager.request(with: param)
    }
    func createBtn()  {
        let titleArr = ["发出的评论","回复的评论"]
        let backView = UIView.init()
        backView.backgroundColor = UIColor(hex: 0xF4F4F4)
        if (QWSize.screenHeight() == 812.0) {
            backView.frame = CGRect(x:0,y:88,width:QWSize.screenWidth(),height:50)
        }
        else{
            backView.frame = CGRect(x:0,y:64,width:QWSize.screenWidth(),height:50)
        }
        
        self.view.addSubview(backView)
        
        for index in 0..<2 {
            let btn = UIButton.init()
            btn.frame = CGRect(x:10+index*10+100*index,y:12,width:100,height:28)
            btn.layer.cornerRadius = 10
            btn.layer.masksToBounds = true
            btn.setTitle(titleArr[index], for: .normal)
            btn.backgroundColor = UIColor.white
            btn.setTitleColor(UIColor(hex: 0x8C8C8C), for: .normal)
            btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn.tag = index
            btnArr.append(btn)
            backView.addSubview(btn)
            if index == 0{
                btn.setTitleColor(UIColor(hex: 0xFB83AC), for: .normal)
                btnStr = "1"
            }
        }
        
    }
    func btnClick(btn:UIButton)  {
        for index in btnArr {
            if index == btn{
                btn.setTitleColor(UIColor(hex: 0xFB83AC), for: .normal)
            }
            else{
                index.setTitleColor(UIColor(hex: 0x8C8C8C), for: .normal)
            }
        }
        if btn.tag == 0 {
            btnStr = "1"
        }
        else if btn.tag == 1{
            btnStr = "2"
        }
        self.getData()
    }
    override func update() {
    }
    //MARK: - tableView代理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let CommentsVO = self.data[indexPath.row]
        self.logic.pushCommentsVC(withPostUrl: CommentsVO.post_url)
        
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    //每一块有多少行
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
        //        return 1
    }
    //绘制cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! QWMyCommentsTVCell
        cell.CommentsVO = self.data[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.05
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let CommentsVO = self.data[indexPath.row]
        let contentLab = QWLabel.init()
        let height :CGFloat = contentLab.getLabHeight(labelStr: CommentsVO.s_content!, font: UIFont.systemFont(ofSize: 12), width: QWSize.screenWidth()-22)
        if CommentsVO.r_content == "" {
            return 60+height+20
        }
        else{
            return 60+height+20+38+10
        }
        
    }
    //    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //        if self.listCount! > self.data.count && self.nextStr != ""{
    //            self.getMoreData()
    //        }
    //    }
}

