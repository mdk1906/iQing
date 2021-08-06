//
//  QWContributionPublishView.swift
//  Qingwen
//
//  Created by Aimy on 4/11/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

@objc
protocol QWContributionPublishViewDelegate: NSObjectProtocol {
    func publishView(_ view: QWContributionPublishView, onPressedCancelPublishBtn sender: AnyObject)
    func publishView(_ view: QWContributionPublishView, onPressedTimePublishBtn sender: AnyObject, time: Date)
    func publishView(_ view: QWContributionPublishView, onPressedPublishBtn sender: AnyObject)
}

class QWContributionPublishView: UIView {

    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var timePicker: UIDatePicker!
    @IBOutlet var publishBtn: UIButton!
    @IBOutlet var timePublishSwitch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.timePicker.minimumDate = Date()
//        self.timePicker.maximumDate = Date.ini
        self.timePicker.isEnabled = false
        if SWIFT_ISIPHONE3_5 || SWIFT_ISIPHONE4_0 {
            self.timeLabel.font = UIFont.systemFont(ofSize: 13)
        }
    }

    weak var delegate: QWContributionPublishViewDelegate?

    @IBAction func onPressedCancelBtn(_ sender: AnyObject) {
        self.removeFromSuperview()
    }


    @IBAction func onPressedPublishBtn(_ sender: AnyObject) {
        if timePublishSwitch.isOn {
            let userCalendar = Calendar.current
            let dateComponents = userCalendar.dateComponents([.year,.month, .day, .hour,.minute,.second], from: self.timePicker.date )
            if self.timePicker.date.compare(Date()) == .orderedAscending {
                self.showToast(withTitle: "不能选择比当前更早的时间", subtitle: nil, type: .alert)
                return
            }
            else if  dateComponents.hour == 0{
                self.showToast(withTitle: "定时发布时间不能选择0点到1点之间的时间", subtitle: nil, type: .alert)
                return
            }
            else if dateComponents.hour == 23 && dateComponents.minute == 30 {
                self.showToast(withTitle: "定时发布时间不能选择0点到1点之间的时间", subtitle: nil, type: .alert)
                return
            }
            self.onPressedCancelBtn(sender)
            self.delegate?.publishView(self, onPressedTimePublishBtn: sender, time: self.timePicker.date)
        } else {
            self.onPressedCancelBtn(sender)
            self.delegate?.publishView(self, onPressedPublishBtn: sender)
        }
    }

    @IBAction func dateTimeChanged(_ sender: AnyObject) {
        guard self.timePublishSwitch.isOn else {
            return
        }
        self.timeLabel.text = QWHelper.fullDate(toString: self.timePicker.date)
    }
    
    @IBAction func onSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            self.timePicker.isEnabled = true
            self.timeLabel.text = QWHelper.fullDate(toString: self.timePicker.date)
        }
        else {
            self.timePicker.isEnabled = false
            self.timeLabel.text = "尚未打开定时开关"
        }
    }
    
}
