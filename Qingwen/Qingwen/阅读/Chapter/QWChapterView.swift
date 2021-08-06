//
//  QWChapterView.swift
//  Qingwen
//
//  Created by Aimy on 10/22/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

@objc
protocol QWChapterViewDelegate : NSObjectProtocol {
    func chapterView(_ view: QWChapterView, onPressedRetryBtn sender: AnyObject);
}

class QWChapterView: UIView {

    weak var delegate: QWChapterViewDelegate?

    @IBOutlet var chapterInfoLabel: UILabel!
    @IBOutlet var volumeInfoLabel: UILabel!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var updateLabel: UILabel!
    @IBOutlet var retryBtn: UIButton!
    @IBOutlet var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var whisperLab: UILabel!
    @IBOutlet weak var leftLine: UIView!
    @IBOutlet weak var rightLine: UIView!
    @IBOutlet weak var authourWordLab: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let title = NSAttributedString(string: "加载失败，请点击重试", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSForegroundColorAttributeName: UIColor(hex: 0x16719e)!, NSUnderlineStyleAttributeName: 2])
        self.retryBtn.setAttributedTitle(title, for: UIControlState())
        let notificationName = Notification.Name(rawValue: "lineisHiden")
        NotificationCenter.default.addObserver(self, selector: #selector(hideLine), name: notificationName, object: nil)
//        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "stopAloud"), object: nil)

    }

    func updateWithChapterVO(_ chapter: ChapterVO) {

        self.chapterInfoLabel.textColor = QWReadingConfig .sharedInstance().readingColor
        self.volumeInfoLabel.textColor = UIColor(hex: 0x848484)
        self.countLabel.textColor = UIColor(hex: 0x848484)
        self.updateLabel.textColor = UIColor(hex: 0x848484)
        self.whisperLab.textColor = UIColor(hex: 0x505050)
        
        self.chapterInfoLabel.font = QWReadingConfig.sharedInstance().titleFont
        self.volumeInfoLabel.font = QWReadingConfig.sharedInstance().font
        self.countLabel.font = QWReadingConfig.sharedInstance().font
        self.updateLabel.font = QWReadingConfig.sharedInstance().font
        self.whisperLab.font = QWReadingConfig.sharedInstance().font
        
        self.chapterInfoLabel.text = chapter.title?.withType(QWReadingConfig.sharedInstance().traditional, origin: QWReadingConfig.sharedInstance().originalFont)
        self.volumeInfoLabel.text = chapter.volumeTitle?.withType(QWReadingConfig.sharedInstance().traditional, origin: QWReadingConfig.sharedInstance().originalFont)
        self.countLabel.text = ("字数: " + QWHelper.count(toString: chapter.count)).withType(QWReadingConfig.sharedInstance().traditional, origin: QWReadingConfig.sharedInstance().originalFont)
        self.updateLabel.text = ("更新: " + QWHelper.fullDate(toString: chapter.updated_time)).withType(QWReadingConfig.sharedInstance().traditional, origin: QWReadingConfig.sharedInstance().originalFont)
        self.whisperLab.text = chapter.whisper?.withType(QWReadingConfig.sharedInstance().traditional, origin: QWReadingConfig.sharedInstance().originalFont)
        self.loadingView.isHidden = false
        self.retryBtn.isHidden = true

        switch QWReadingConfig.sharedInstance().readingBG {
        case .black:
            self.loadingView.activityIndicatorViewStyle = .white
            break;
        default:
            self.loadingView.activityIndicatorViewStyle = .gray
            break;
        }
    }

    func showCompleted() {
        self.loadingView.isHidden = true
        self.retryBtn.isHidden = true
    }

    func showError() {
        self.loadingView.isHidden = true
        self.retryBtn.isHidden = false
    }

    @IBAction func onPressedRetryBtn(_ sender: AnyObject) {
        self.delegate?.chapterView(self, onPressedRetryBtn: sender)
        if QWGlobalValue.sharedInstance().isLogin() == false {
            QWRouter.sharedInstance().routerToLogin()
            return;
        }
    }
    func hideLine()  {
        self.leftLine.isHidden = true
        self.rightLine.isHidden = true
        self.authourWordLab.isHidden = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
}
