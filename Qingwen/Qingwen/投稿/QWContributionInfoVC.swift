//
//  QWContributionInfoVC.swift
//  Qingwen
//
//  Created by Aimy on 10/26/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWContributionInfoVC: QWBaseVC {

    var contributionVO: ContributionVO?
    
    lazy var logic: QWContributionLogic = {
        let logic = QWContributionLogic(operationManager: self.operationManager)
        logic.channel = self.channel as NSNumber?
        return logic
    }()

    var channel = QWChannelType.type10.rawValue
    var change = false

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var bookImageView: UIImageView!
    @IBOutlet var imageTipLabel: UILabel!
    @IBOutlet var titleTF: UITextField!
    @IBOutlet var introTV: UITextView!

    @IBOutlet var activityBtn: UIButton!
    @IBOutlet var activityCancelBtn: UIButton!
    
    
    @IBOutlet var categoryBtn: UIButton!
    @IBOutlet var categoryCV: UICollectionView!
    @IBOutlet var currentLocateBtn: UIButton!

    @IBOutlet var locate10Btn: UIButton!
    @IBOutlet var locate11Btn: UIButton!
    @IBOutlet var locate12Btn: UIButton!

    @IBOutlet var layout: UICollectionViewFlowLayout!
    
    @IBOutlet var managerialView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.titleTF.layer.cornerRadius = 5
        self.titleTF.layer.borderWidth = PX1_LINE
        self.titleTF.layer.borderColor = UIColor(hex: 0x505050)?.cgColor

        self.introTV.layer.cornerRadius = 5
        self.introTV.layer.borderWidth = PX1_LINE
        self.introTV.layer.borderColor = UIColor(hex: 0x505050)?.cgColor

        self.categoryCV.backgroundColor = UIColor.white

//        let itemWidth = QWSize.getLengthWith(.type4_0, andLength: 60)
//        self.layout.itemSize = CGSize(width: itemWidth, height: ceil(itemWidth * 36 / 85))
//        var edge = (QWSize.screenWidth() - 4 * itemWidth) / (4 + 1);
//        if SWIFT_IS_IPAD_DEVICE {
//            edge = (QWSize.screenWidth() - 5 * itemWidth) / (5 + 1);
//        }
//
//        if SWIFT_IS_IPHONE_DEVICE {
//            self.layout.sectionInset = UIEdgeInsetsMake(edge - 1, edge - 1, edge - 1, edge - 1)
//            self.layout.minimumLineSpacing = edge
//        }
//        else {
//            self.layout.sectionInset = UIEdgeInsetsMake(20, edge - 1, 20, edge - 1)
//            self.layout.minimumLineSpacing = 20
//        }
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        categoryCV?.delegate = self
        categoryCV?.dataSource = self
//        categoryCV?.register(ce.self, forCellWithReuseIdentifier: "QWBooksListLatestCell")
//        self.layout.minimumInteritemSpacing = edge

        self.resize(CGSize(width: QWSize.screenWidth(), height: QWSize.screenHeight()))
    }

    override func resize(_ size: CGSize) {
        var frame = self.contentView.frame
        frame.size.width = size.width
        self.contentView.frame = frame
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fd_interactivePopDisabled = true
        if let contributionVO = self.contributionVO {
            self.title = "修改作品"
            self.logic.channel = contributionVO.book.channel
            self.logic.contributionVO = contributionVO
            self.logic.book = contributionVO.book
            self.logic.categorys = contributionVO.book.categories as? [CategoryItemVO]
            self.logic.activitys = contributionVO.book.activity as? [ActivityVO]
            self.update()
        }
        else { //新创建
            self.logic.channel = self.channel as NSNumber
            self.currentLocateBtn.isSelected = false
            if self.channel == QWChannelType.type10.rawValue {
                self.currentLocateBtn = self.locate10Btn
            }
            else if self.channel == QWChannelType.type11.rawValue{
                self.currentLocateBtn = self.locate11Btn
            } else {
                self.currentLocateBtn = self.locate12Btn
            }
            self.currentLocateBtn.isSelected = true
            self.managerialView.isHidden = true
        }
        // Do any additional setup after loading the view.
        self.categoryCV.backgroundColor = UIColor.white;

        self.scrollView.addSubview(self.contentView)
//        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0)

        if self.contentView.bounds.size.height > self.view.bounds.size.height {
            self.scrollView.contentSize = CGSize(width: QWSize.screenWidth(), height: self.contentView.bounds.size.height)
        }
        else {
            self.scrollView.contentSize = CGSize(width: QWSize.screenWidth(), height: self.view.bounds.size.height)
        }
        
        if #available(iOS 11.0, *){
            self.scrollView.bottomAnchor.constraint(equalTo: self.scrollView.safeAreaLayoutGuide.bottomAnchor).isActive = true
            self.managerialView.bottomAnchor.constraint(equalTo: self.scrollView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        }
        self.getActivityList()
    }
    
    func getActivityList() {
        self.logic.getActivitList {[weak self](aResponseObject, anError) in
            if let weakSelf = self {
                if let _ = weakSelf.contributionVO {
                    weakSelf.update()
                    weakSelf.setEditing(false, animated: true)
                }
                else {
                    weakSelf.currentLocateBtn.isSelected = true
                    weakSelf.setEditing(true, animated: true)
                }
            }
        }
    }
    
    override func update() {
        self.imageTipLabel.isHidden = true
        self.titleTF.text = self.logic.book?.title
        self.introTV.text = self.logic.book?.intro

        self.currentLocateBtn.isSelected = false
        
        if let channel = self.logic.channel {
            
            if channel.uintValue == QWChannelType.type10.rawValue {
                self.currentLocateBtn = self.locate10Btn
                self.logic.channel = QWChannelType.type10.rawValue as NSNumber?
            }else if channel.uintValue == QWChannelType.type11.rawValue {
                self.currentLocateBtn = self.locate11Btn
                self.logic.channel = QWChannelType.type11.rawValue as NSNumber?
            }else {
                self.currentLocateBtn = self.locate12Btn
                self.logic.channel = QWChannelType.type12.rawValue as NSNumber?
            }
         }
 
        self.currentLocateBtn.isSelected = true

        self.bookImageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(self.logic.book?.cover, imageSizeType: .coverThumbnail), placeholder: UIImage(named: "placeholder114x152"), animation: true)
        self.bookImageView.isUserInteractionEnabled = isEditing
        self.categoryCV.reloadData()
        if let activity = self.logic.book?.activity?.first as? ActivityVO,let title = activity.title {
            self.activityBtn.setTitle(title, for: UIControlState())
            self.activityCancelBtn.isHidden = false
        }
        else {
            self.activityBtn.setTitle("无", for: UIControlState())
            self.activityCancelBtn.isHidden = true
        }
    }

    func getRecord() {
        if let record_url = self.logic.contributionVO?.record_url {
            self.logic.getRecordWithUrl(record_url, andComplete: { (aResponseObject, anError) -> Void in

            })
        }
        
    }

    @IBAction func onPressedLocateBtn(_ sender: UIButton) {
        self.currentLocateBtn.isSelected = false
        self.currentLocateBtn = sender
        self.currentLocateBtn.isSelected = true
        self.logic.channel = self.currentLocateBtn.tag as NSNumber?
        self.setEditing(true, animated: true)
    }

    @IBAction func onPressedBookImageView(_ sender: UITapGestureRecognizer) {
        endTextEditing()
        let actionSheet = UIActionSheet.bk_actionSheet(withTitle: "上传封面") as! UIActionSheet
        actionSheet.bk_addButton(withTitle: "拍照") { () -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
                self.showToast(withTitle: "该设备没有照相功能", subtitle: nil, type: .alert)
                return
            }

            let picker = UIImagePickerController()
            picker.mediaTypes = [kUTTypeImage as String]
            picker.sourceType = .camera
            picker.bk_didCancelBlock = { (controller: UIImagePickerController?) in
                controller?.dismiss(animated: true, completion: { () -> Void in
                    self.setNeedsStatusBarAppearanceUpdate()
                })
            }

            picker.bk_didFinishPickingMediaBlock = { (controller: UIImagePickerController?, info: [AnyHashable: Any]?) in
                self.setNeedsStatusBarAppearanceUpdate()
                controller?.dismiss(animated: true, completion: { () -> Void in
                    self.setNeedsStatusBarAppearanceUpdate()
                    if let chosenImage = info?[UIImagePickerControllerOriginalImage] as? UIImage {
                        self.editImage(chosenImage)
                    }
                })
            }

            self.performInMainThreadBlock({ () -> Void in
                self .present(picker, animated: true, completion: nil)
                }, afterSecond:0.1)
        }

        actionSheet.bk_addButton(withTitle: "从相册选择") { () -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == false {
                self.showToast(withTitle: "该设备没有相册功能", subtitle: nil, type: .alert)
                return
            }

            let picker = UIImagePickerController()
            picker.mediaTypes = [kUTTypeImage as String]
            picker.sourceType = .photoLibrary
            picker.bk_didCancelBlock = { (controller: UIImagePickerController?) in
                controller?.dismiss(animated: true, completion: { () -> Void in
                    self.setNeedsStatusBarAppearanceUpdate()
                })
            }

            picker.bk_didFinishPickingMediaBlock = { (controller: UIImagePickerController?, info: [AnyHashable: Any]?) in
                self.setNeedsStatusBarAppearanceUpdate()
                controller?.dismiss(animated: true, completion: { () -> Void in
                    self.setNeedsStatusBarAppearanceUpdate()
                    if let chosenImage = info?[UIImagePickerControllerOriginalImage] as? UIImage {
                        self.editImage(chosenImage)
                    }
                })
            }

            self.performInMainThreadBlock({ () -> Void in
                self .present(picker, animated: true, completion: nil)
                }, afterSecond:0.1)
        }

        actionSheet.bk_setCancelButton(withTitle: "取消") { () -> Void in

        }

        actionSheet.show(in: sender.view!)
    }

    func editImage(_ image: UIImage) {
        let vc = PECropViewController()
        vc.delegate = self
        vc.image = image
        vc.toolbarHidden = true
        vc.cropAspectRatio = 3.0 / 4
        vc.keepingCropAspectRatio = true
        let nc = QWBaseNC(rootViewController: vc)
        self.present(nc, animated: true, completion: nil)
    }

    func uploadImage(_ image: UIImage) {
        self.showLoading()
        performInThreadBlock { () -> Void in
            let image = image.scale(to: CGSize(width: 480, height: 640))
            self.performInMainThreadBlock({ () -> Void in
                self.logic.uploadCover(image!) { (aResponseObject, anError) -> Void in
                    self.hideLoading()

                    if let anError = anError as NSError? {
                        self.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .error)
                        return
                    }

                    if let dict = aResponseObject as? [String: AnyObject] {
                        if let code = dict["code"] as? Int , code != 0 {
                            if let message = dict["data"] as? String {
                                self.showToast(withTitle: message, subtitle: nil, type: .error)
                            }
                            else {
                                self.showToast(withTitle: "上传失败", subtitle: nil, type: .error)
                            }
                        }
                        else {
                            self.imageTipLabel.isHidden = true
                            self.bookImageView.image = image
                            self.showToast(withTitle: "上传成功", subtitle: nil, type: .error)
                        }
                    }
                }
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? QWContributionCategoryVC {
            vc.categorys = self.logic.categorys
        }
        if let vc = segue.destination as? QWContributionActivityVC {
            vc.activitys = self.logic.activitys
        }
    }
    
    @IBAction func unwindToContributionBookFromCategory(_ segue: UIStoryboardSegue) {
        if let vc = segue.source as? QWContributionCategoryVC {
            self.logic.categorys = vc.categorys;
            self.categoryCV.reloadData()
        }
        if  let vc = segue.source as? QWContributionActivityVC {
            self.logic.activitys = vc.activitys
            self.setEditing(true, animated: true)
        }
        
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        self.change = editing
        if self.logic.contributionVO?.status == nil {//新创建
            self.titleTF.isUserInteractionEnabled = editing
            self.categoryBtn.isEnabled = editing
            self.locate10Btn.isEnabled = editing
            self.locate11Btn.isEnabled = editing
            
            self.activityCancelBtn.isEnabled = editing
            
            if let activity = self.logic.activitys?.first,let title = activity.title {
                self.activityBtn.setTitle(title, for: UIControlState())
                self.activityBtn.isEnabled = false
                self.activityBtn.setBackgroundImage(UIImage(), for: .disabled)
                self.activityBtn.setTitleColor(UIColor.color50(), for: .disabled)
                self.activityCancelBtn.isHidden = false
            }
            else {
                if let _ = self.logic.activityList?.results?.first as? ActivityVO{
                    self.activityBtn.setTitle("不参加活动", for: UIControlState())
                    self.activityCancelBtn.isHidden = true
                    if editing {
                        self.activityBtn.setBackgroundImage(UIImage(named: "contribution_right_select"), for: UIControlState())
                        self.activityBtn.setTitleColor(UIColor.colorQWPinkDark(), for: UIControlState())
                        
                    }
                    else {
                        self.activityBtn.setBackgroundImage(UIImage(named: "contribution_right_unselect"), for: UIControlState())
                        self.activityBtn.setTitleColor(UIColor(hex: 0xCCCCCC), for: UIControlState())
                    }
                }
                else {
                    self.activityBtn.setTitle("暂无活动", for: UIControlState())
                    self.activityBtn.setBackgroundImage(UIImage(named: "contribution_right_unselect"), for: UIControlState())
                    self.activityBtn.setTitleColor(UIColor(hex: 0xCCCCCC), for: UIControlState())
                    self.activityBtn.isUserInteractionEnabled = false
                }
            }
            if editing {
                self.titleTF.layer.borderColor = UIColor(hex: 0x505050)?.cgColor
                self.titleTF.textColor = UIColor(hex: 0x505050)

                self.locate10Btn.setTitleColor(UIColor(hex: 0x505050), for: UIControlState())
                self.locate10Btn.setBackgroundImage(UIImage(named: "btn_bg_7"), for: UIControlState())

                self.locate11Btn.setTitleColor(UIColor(hex: 0x505050), for: UIControlState())
                self.locate11Btn.setBackgroundImage(UIImage(named: "btn_bg_7"), for: UIControlState())
                
                self.locate12Btn.setTitleColor(UIColor(hex: 0x505050), for: UIControlState())
                self.locate12Btn.setBackgroundImage(UIImage(named: "btn_bg_7"), for: UIControlState())
                
                self.currentLocateBtn.setTitleColor(UIColor.white, for: UIControlState())
                self.currentLocateBtn.setBackgroundImage(UIImage(named: "btn_bg_2"), for: UIControlState())
                
                
            }
            else {
                self.titleTF.layer.borderColor = UIColor(hex: 0xcccccc)?.cgColor
                self.titleTF.textColor = UIColor(hex: 0xcccccc)

                self.locate10Btn.setTitleColor(UIColor(hex: 0xCCCCCC), for: UIControlState())
                self.locate10Btn.setBackgroundImage(UIImage(named: "btn_bg_7"), for: UIControlState())

                self.locate11Btn.setTitleColor(UIColor(hex: 0xCCCCCC), for: UIControlState())
                self.locate11Btn.setBackgroundImage(UIImage(named: "btn_bg_7"), for: UIControlState())

                self.locate12Btn.setTitleColor(UIColor(hex: 0xCCCCCC), for: UIControlState())
                self.locate12Btn.setBackgroundImage(UIImage(named: "btn_bg_7"), for: UIControlState())
                
                self.currentLocateBtn.setTitleColor(UIColor.white, for: UIControlState())
                self.currentLocateBtn.setBackgroundImage(UIImage(named: "btn_bg_10"), for: UIControlState())
            
            }

            self.bookImageView.isUserInteractionEnabled = editing
            self.introTV.isUserInteractionEnabled = editing
            if editing {
                self.introTV.layer.borderColor = UIColor(hex: 0x505050)?.cgColor
                self.introTV.textColor = UIColor(hex: 0x505050)
            }
            else {
                self.introTV.layer.borderColor = UIColor(hex: 0xcccccc)?.cgColor
                self.introTV.textColor = UIColor(hex: 0xcccccc)
            }
        }
        else if let status = self.logic.contributionVO?.status , status == .draft || status == .reject {//草稿,退回
            self.titleTF.isUserInteractionEnabled = false
            self.titleTF.layer.borderColor = UIColor(hex: 0xcccccc)?.cgColor
            self.titleTF.textColor = UIColor(hex: 0xcccccc)

            self.categoryBtn.isEnabled = editing
            self.locate10Btn.isEnabled = editing
            self.locate11Btn.isEnabled = editing
            
            self.activityCancelBtn.isHidden = true
            
            if let activity = self.logic.activitys?.first,let title = activity.title {
                self.activityBtn.setTitle(title, for: UIControlState())
                self.activityBtn.setBackgroundImage(nil, for:  .disabled)
                self.activityBtn.setBackgroundImage(nil, for:  .normal)
                
                self.activityBtn.isEnabled = false
                if editing {
                    self.activityBtn.setTitleColor(UIColor.color50(), for: .disabled)
                }
                else {
                    self.activityBtn.setTitleColor(UIColor(hex: 0xCCCCCC), for: .disabled)
                }
            }
            else {
                if let _ = self.logic.activityList?.results?.first as? ActivityVO{
                    self.activityBtn.setTitle("不参加活动", for: UIControlState())
                    self.activityCancelBtn.isHidden = true
                    self.activityBtn.isEnabled = false
                    if editing {
                        self.activityBtn.setBackgroundImage(UIImage(named: "contribution_right_select"), for: UIControlState())
                        self.activityBtn.setTitleColor(UIColor.colorQWPinkDark(), for: UIControlState())

                    }
                    else {
                        self.activityBtn.setBackgroundImage(UIImage(named: "contribution_right_unselect"), for: UIControlState())
                        self.activityBtn.setTitleColor(UIColor(hex: 0xCCCCCC), for: UIControlState())
                    }
                }
                else {
                    self.activityBtn.isEnabled = false
                    self.activityBtn.setTitle("暂无活动", for: UIControlState())
                    self.activityBtn.setBackgroundImage(UIImage(named: "contribution_right_unselect"), for: UIControlState())
                }
            }
            if editing {
                self.locate10Btn.setTitleColor(UIColor(hex: 0x505050), for: UIControlState())
                self.locate10Btn.setBackgroundImage(UIImage(named: "btn_bg_7"), for: UIControlState())

                self.locate11Btn.setTitleColor(UIColor(hex: 0x505050), for: UIControlState())
                self.locate11Btn.setBackgroundImage(UIImage(named: "btn_bg_7"), for: UIControlState())

                self.locate12Btn.setTitleColor(UIColor(hex: 0x505050), for: UIControlState())
                self.locate12Btn.setBackgroundImage(UIImage(named: "btn_bg_7"), for: UIControlState())
                
                self.currentLocateBtn.setTitleColor(UIColor.white, for: UIControlState())
                self.currentLocateBtn.setBackgroundImage(UIImage(named: "btn_bg_2"), for: UIControlState())
                
            }
            else {
                self.locate10Btn.setTitleColor(UIColor(hex: 0xCCCCCC), for: UIControlState())
                self.locate10Btn.setBackgroundImage(UIImage(named: "btn_bg_7"), for: UIControlState())

                self.locate11Btn.setTitleColor(UIColor(hex: 0xCCCCCC), for: UIControlState())
                self.locate11Btn.setBackgroundImage(UIImage(named: "btn_bg_7"), for: UIControlState())

                self.locate12Btn.setTitleColor(UIColor(hex: 0xCCCCCC), for: UIControlState())
                self.locate12Btn.setBackgroundImage(UIImage(named: "btn_bg_7"), for: UIControlState())
                
                self.currentLocateBtn.setTitleColor(UIColor.white, for: UIControlState())
                self.currentLocateBtn.setBackgroundImage(UIImage(named: "btn_bg_10"), for: UIControlState())
            }

            self.bookImageView.isUserInteractionEnabled = editing
            self.introTV.isUserInteractionEnabled = editing
            if editing {
                self.introTV.layer.borderColor = UIColor(hex: 0x505050)?.cgColor
                self.introTV.textColor = UIColor(hex: 0x505050)
            }
            else {
                self.introTV.layer.borderColor = UIColor(hex: 0xcccccc)?.cgColor
                self.introTV.textColor = UIColor(hex: 0xcccccc)
            }
        }
        else if let status = self.logic.contributionVO?.status , status == .approve || status == .partReview {//审核通过
            self.titleTF.isUserInteractionEnabled = false
            self.titleTF.textColor = UIColor(hex: 0xcccccc)
            self.titleTF.layer.borderColor = UIColor(hex: 0xcccccc)?.cgColor

            self.categoryBtn.isEnabled = false
            self.locate10Btn.isEnabled = false
            self.locate11Btn.isEnabled = false
            self.activityBtn.isEnabled = false
            self.activityCancelBtn.isEnabled = false

            self.activityBtn.setBackgroundImage(nil, for:  .disabled)
            self.activityBtn.setBackgroundImage(nil, for:  .normal)
            if let activity = self.logic.book?.activity?.first as? ActivityVO,let title = activity.title {
                self.activityBtn.setTitle(title, for: UIControlState())
                self.activityCancelBtn.isHidden = true
            }
            else {
                self.activityBtn.setTitle("无", for: UIControlState())
                self.activityCancelBtn.isHidden = true
            }
            
            self.locate10Btn.setTitleColor(UIColor(hex: 0xCCCCCC), for: UIControlState())
            self.locate10Btn.setBackgroundImage(UIImage(named: "btn_bg_7"), for: UIControlState())

            self.locate11Btn.setTitleColor(UIColor(hex: 0xCCCCCC), for: UIControlState())
            self.locate11Btn.setBackgroundImage(UIImage(named: "btn_bg_7"), for: UIControlState())

            self.locate12Btn.setTitleColor(UIColor(hex: 0xCCCCCC), for: UIControlState())
            self.locate12Btn.setBackgroundImage(UIImage(named: "btn_bg_7"), for: UIControlState())
            
            self.currentLocateBtn.setTitleColor(UIColor.white, for: UIControlState())
            self.currentLocateBtn.setBackgroundImage(UIImage(named: "btn_bg_10"), for: UIControlState())

            if editing {
                self.introTV.layer.borderColor = UIColor(hex: 0x505050)?.cgColor
                self.introTV.textColor = UIColor(hex: 0x505050)
            }
            else {
                self.introTV.layer.borderColor = UIColor(hex: 0xcccccc)?.cgColor
                self.introTV.textColor = UIColor(hex: 0xcccccc)
            }
            self.bookImageView.isUserInteractionEnabled = editing

        }
        else {//其他
            self.titleTF.textColor = UIColor(hex: 0xcccccc)
            self.titleTF.layer.borderColor = UIColor(hex: 0xcccccc)?.cgColor
            self.titleTF.isUserInteractionEnabled = false
            self.categoryBtn.isEnabled = false
            self.locate10Btn.isEnabled = false
            self.locate11Btn.isEnabled = false
            self.activityBtn.isEnabled = false
            self.activityCancelBtn.isEnabled = false
            
            if let activity = self.logic.book?.activity?.first as? ActivityVO,let title = activity.title {
                self.activityBtn.setTitle(title, for: UIControlState())
                self.activityBtn.setBackgroundImage(nil, for:  UIControlState())

                self.activityCancelBtn.isHidden = true
            }
            else {
                self.activityBtn.setTitle("无", for: .normal)
                self.activityCancelBtn.isHidden = true
            }
            self.locate10Btn.setTitleColor(UIColor(hex: 0xCCCCCC), for: UIControlState())
            self.locate10Btn.setBackgroundImage(UIImage(named: "btn_bg_7"), for: UIControlState())

            self.locate11Btn.setTitleColor(UIColor(hex: 0xCCCCCC), for: UIControlState())
            self.locate11Btn.setBackgroundImage(UIImage(named: "btn_bg_7"), for: UIControlState())

            self.locate12Btn.setTitleColor(UIColor(hex: 0xCCCCCC), for: UIControlState())
            self.locate12Btn.setBackgroundImage(UIImage(named: "btn_bg_7"), for: UIControlState())
            
            self.currentLocateBtn.setTitleColor(UIColor.white, for: UIControlState())
            self.currentLocateBtn.setBackgroundImage(UIImage(named: "btn_bg_10"), for: UIControlState())

            self.bookImageView.isUserInteractionEnabled = false
            self.introTV.isUserInteractionEnabled = false
            self.introTV.layer.borderColor = UIColor(hex: 0xcccccc)?.cgColor
            self.introTV.textColor = UIColor(hex: 0xcccccc)
        }
    }
    
    @IBAction func onPressedCancelActivityBtn(_ sender: Any) {
        self.activityBtn.setTitle("不参加活动", for: UIControlState())
        self.activityBtn.setTitleColor(UIColor.colorQWPinkDark(), for: UIControlState())
        self.activityBtn.setBackgroundImage(UIImage(named: "contribution_right_select"), for: UIControlState())
        
        self.activityCancelBtn.isHidden = true
        self.activityBtn.isEnabled = true
        self.logic.activitys = nil
    }
    
    @IBAction func onPressedEditBtn(_ sender: AnyObject) {
        let actionSheet = UIActionSheet.bk_actionSheet(withTitle: "") as! UIActionSheet
        
        if change {
            actionSheet.bk_addButton(withTitle: "保存修改") {
                self.onPressedSaveBtn()
            }
        }
        else {
            actionSheet.bk_addButton(withTitle: "修改作品") {
                self.setEditing(true, animated: true)
            }
        }
        
        if let _ = self.logic.book {
            actionSheet.bk_addButton(withTitle: "删除作品") {
                self.onPressedDeleteBtn()
            }
        }
        if let _ = self.logic.book {
            actionSheet.bk_addButton(withTitle: "申请完结") {
                self.onPressedEndBtn()
            }
        }
        if self.managerialView.isHidden {
            actionSheet.bk_addButton(withTitle: "下一步", handler: { 
                self.onPressedNextBtn()
            })
        }
        
        actionSheet.bk_setCancelButton(withTitle: "取消") { 
            
        }
        
        actionSheet.show(in: self.view)
    }
    
    @IBAction override func leftBtnClicked(_ sender: AnyObject?) {
        self.cancelAllOperations()
        if let _ = self.presentingViewController {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func onPressedSaveBtn() {
        if let status = self.logic.contributionVO?.status , status == .approve || status == .partReview {//已经通过
            if (self.introTV.text as NSString).length == 0 {
                self.showToast(withTitle: "请输入简介", subtitle: nil, type: .alert)
                return
            }
            
            if (self.introTV.text as NSString).length > 300 {
                self.showToast(withTitle: "简介不能超过300个字符", subtitle: nil, type: .alert)
                return
            }
            
            if self.logic.isLoading {
                return
            }
            
            self.logic.isLoading = true
            
            self.showLoading()
            self.logic.updateApproveBook(withIntro: self.introTV.text, andComplete: { (aResponseObject, anError) -> Void in
                self.hideLoading()
                self.logic.isLoading = false
                
                if let anError = anError as NSError?{
                    self.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .error)
                    return ;
                }
                
                if let dict = aResponseObject as? [String: AnyObject] {
                    if let code = dict["code"] as? Int , code != 0 {
                        if let message = dict["data"] as? String {
                            self.showToast(withTitle: message, subtitle: nil, type: .error)
                        }
                        else {
                            self.showToast(withTitle: "更新失败", subtitle: nil, type: .error)
                        }
                    }
                    else {
                        self.setEditing(false, animated: true)
                        self.showToast(withTitle: "更新成功", subtitle: nil, type: .error)
                    }
                }
            })
        }
        else if let _ = self.logic.book {
            if (self.introTV.text as NSString).length == 0 {
                self.showToast(withTitle: "请输入简介", subtitle: nil, type: .alert)
                return
            }
            
            if (self.introTV.text as NSString).length > 300 {
                self.showToast(withTitle: "简介不能超过300个字符", subtitle: nil, type: .alert)
                return
            }
            
            if let count = self.logic.categorys?.count, count < 2 {
                self.showToast(withTitle: "请至少选择2个分类", subtitle: nil, type: .alert)
                return
            }
            
            if let count = self.logic.categorys?.count, count > 5 {
                self.showToast(withTitle: "分类不能超过5个", subtitle: nil, type: .alert)
                return
            }
            
            if self.logic.isLoading {
                return
            }
            
            self.logic.isLoading = true
            
            self.showLoading()
            self.logic.updateBook(withIntro: self.introTV.text, andComplete: { (aResponseObject, anError) -> Void in
                self.hideLoading()
                self.logic.isLoading = false
                
                if let anError = anError as NSError? {
                    self.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .error)
                    return ;
                }
                
                if let _ = aResponseObject as? [String: AnyObject] {
                    self.setEditing(false, animated: true)
                    self.showToast(withTitle: "更新成功", subtitle: nil, type: .error)
                }
            })
        }
        else {
            
            if let text = self.titleTF.text , (text as NSString).length == 0 {
                self.showToast(withTitle: "请输入书名", subtitle: nil, type: .alert)
                return
            }
            
            if let text = self.titleTF.text , (text as NSString).length > 64 {
                self.showToast(withTitle: "书名不能超过64个字符", subtitle: nil, type: .alert)
                return
            }
            
            if (self.introTV.text as NSString).length == 0 {
                self.showToast(withTitle: "请输入简介", subtitle: nil, type: .alert)
                return
            }
            
            if let coverPath = self.logic.coverPath , (coverPath as NSString).length == 0 {
                self.showToast(withTitle: "请上传封面", subtitle: nil, type: .alert)
                return
            }
            
            if (self.introTV.text as NSString).length > 300 {
                self.showToast(withTitle: "简介不能超过300个字符", subtitle: nil, type: .alert)
                return
            }
            
            if let count = self.logic.categorys?.count, count < 2 {
                self.showToast(withTitle: "请至少选择2个分类", subtitle: nil, type: .alert)
                return
            }
            
            if let count = self.logic.categorys?.count, count > 5 {
                self.showToast(withTitle: "分类不能超过5个", subtitle: nil, type: .alert)
                return
            }
            
            if self.logic.isLoading {
                return
            }
            
            self.logic.isLoading = true
            
            self.showLoading()
            self.logic.createBook(withTitle: self.titleTF.text!, intro: self.introTV.text, andComplete: { (aResponseObject, anError) -> Void in
                self.hideLoading()
                self.logic.isLoading = false
                
                if let anError = anError as NSError? {
                    self.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .error)
                    return ;
                }
                
                if let _ = aResponseObject as? [String: AnyObject] {
                    self.setEditing(false, animated: true)
                    self.showToast(withTitle: "创建成功", subtitle: nil, type: .error)
                }
            })
        }
    }
    
    func onPressedDeleteBtn() {
        let alert = UIAlertView()
        guard let title =  contributionVO?.book.title else {
            return
        }
        alert.bk_init(withTitle: "删除作品", message: "删除作品\"\(title)\"")
        alert.bk_addButton(withTitle: "取消") {
            
        }
        alert.bk_addButton(withTitle: "确定") { [weak self]() -> Void in
            if let weakSelf = self {
                weakSelf.logic.deleteBook { [weak weakSelf](aResponseObject, anError) in
                    if let weakSelf = weakSelf {
                        if anError == nil {
                            if let aResponseObject = aResponseObject as? [String: AnyObject] {
                                if let code = aResponseObject["code"] as? NSNumber , code.isEqual(to: NSNumber(value: 0)) {
                                    
                                    weakSelf.showToast(withTitle: "删除成功", subtitle: nil, type: ToastType.alert)
                                    weakSelf.leftBtnClicked(weakSelf.navigationItem.leftBarButtonItem!)
                                }
                                else {
                                    if let message = aResponseObject["msg"] as? String {
                                        weakSelf.showToast(withTitle: message, subtitle: nil, type: ToastType.alert)
                                    }
                                    else {
                                        weakSelf.showToast(withTitle: "删除失败 ", subtitle: nil, type: ToastType.alert)
                                    }
                                }
                            }
                        }
                        else {
                            if let anError = anError as NSError? {
                                weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: ToastType.error)
                            }
                            
                        }
                        weakSelf.hideLoading()
                    }
                }
            }
        }
        alert.show()
    }
    func onPressedEndBtn()  {
        let alert = UIAlertView()
        guard let title =  contributionVO?.book.title else {
            return
        }
        alert.bk_init(withTitle: "提示", message: "每月仅有3次申请完结机会")
        alert.bk_addButton(withTitle: "取消") {
            
        }
        alert.bk_addButton(withTitle: "提交") { [weak self]() -> Void in
            if let weakSelf = self {
                weakSelf.logic.endBook { [weak weakSelf](aResponseObject, anError) in
                    if let weakSelf = weakSelf {
                        if anError == nil {
                            if let aResponseObject = aResponseObject as? [String: AnyObject] {
                                if let code = aResponseObject["code"] as? NSNumber , code.isEqual(to: NSNumber(value: 0)) {
                                    
                                    weakSelf.showToast(withTitle: "申请成功", subtitle: nil, type: ToastType.alert)
                                    weakSelf.leftBtnClicked(weakSelf.navigationItem.leftBarButtonItem!)
                                }
                                else {
                                    if let message = aResponseObject["msg"] as? String {
                                        weakSelf.showToast(withTitle: message, subtitle: nil, type: ToastType.alert)
                                    }
                                    else {
                                        weakSelf.showToast(withTitle: "申请失败 ", subtitle: nil, type: ToastType.alert)
                                    }
                                }
                            }
                        }
                        else {
                            if let anError = anError as NSError? {
                                weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: ToastType.error)
                            }
                            
                        }
                        weakSelf.hideLoading()
                    }
                }
            }
        }
        alert.show()
    }
    func onPressedNextBtn() {
        if let _ = self.logic.book {
            let vc = QWContributionAddVolumeVC.createFromStoryboard(withStoryboardID: "addvolume", storyboardName: "QWContribution")!
            vc.logic = self.logic
            vc.fromInfo = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            self.showToast(withTitle: "请先保存作品 ", subtitle: nil
                , type: ToastType.alert)
        }
    }
    
    @IBAction func onPressedManageVolume(_ sender: Any) {
        let vc = QWContributionContentVolumeTVC.createFromStoryboard(withStoryboardID: "contentVolume", storyboardName: "QWContribution")!
        vc.logic = self.logic
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onPressedManageDraft(_ sender: Any) {
        let vc = QWContributionDraftVC.createFromStoryboard(withStoryboardID: "draft", storyboardName: "QWContribution")!
        vc.logic =  self.logic
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onPressedBookDetailBtn(_ sender: Any) {
        if let contribution = self.contributionVO, contribution.status == . approve || contribution.status == .partReview{
            var params = [String: String]();
            params["id"] = contribution.nid?.stringValue
            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "book", andParams: params))
        }
        else {
            self.showToast(withTitle: "只能查看审核过的作品", subtitle: nil, type: .alert)

        }
    }
    
}

extension QWContributionInfoVC: PECropViewControllerDelegate {
    func cropViewControllerDidCancel(_ controller: PECropViewController!) {
        self.dismiss(animated: true, completion: nil)
    }

    func cropViewController(_ controller: PECropViewController!, didFinishCroppingImage croppedImage: UIImage!) {
        self.dismiss(animated: true, completion: nil)
        self.uploadImage(croppedImage)
    }
}

extension QWContributionInfoVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let categorys = self.logic.categorys {
            return categorys.count
        }
        else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "catrgorycell", for: indexPath) as! QWDetailCategoryCVCell
        let vo = self.logic.categorys![(indexPath as NSIndexPath).row]
        print(vo)
        cell.categoryBtn.setTitle(vo.name, for: UIControlState())
        return cell
    }
}

extension QWContributionInfoVC: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if SWIFT_ISIPHONE3_5 || SWIFT_ISIPHONE4_0 {
            if self.titleTF == textField {
                self.scrollView.setContentOffset(CGPoint(x: 0, y: textField.frame.origin.y - 64 - 15), animated: true)
            }
        }

        self.titleTF.layer.borderColor = UIColor(hex: 0xFB83AC)?.cgColor
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.titleTF.layer.borderColor = UIColor(hex: 0x505050)?.cgColor
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string as NSString).length == 0 {
            return true
        }

        if let text = textField.text , textField == self.titleTF && (text as NSString).length > 64 {
            return false
        }

        return true
    }
}

extension QWContributionInfoVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if SWIFT_ISIPHONE3_5 || SWIFT_ISIPHONE4_0 {
            if self.introTV == textView {
                self.scrollView.setContentOffset(CGPoint(x: 0, y: textView.frame.origin.y - 64 - 15), animated: true)
            }
        }

        self.introTV.layer.borderColor = UIColor(hex: 0xFB83AC)?.cgColor
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        self.introTV.layer.borderColor = UIColor(hex: 0x505050)?.cgColor
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text as NSString).length == 0 {
            return true
        }

        if textView == self.introTV && (self.introTV.text as NSString).length > 300 {
            return false
        }

        return true
    }
}

