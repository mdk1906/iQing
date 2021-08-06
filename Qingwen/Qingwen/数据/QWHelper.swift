//
//  QWHelper.swift
//  Qingwen
//
//  Created by Aimy on 10/13/15.
//  Copyright © 2015 iQing. All rights reserved.
//

//device
let SWIFT_IS_IPHONE_DEVICE = (UI_USER_INTERFACE_IDIOM() == .phone)
let SWIFT_IS_IPAD_DEVICE = (UI_USER_INTERFACE_IDIOM() == .pad)

let PX1_LINE = (1.0 / UIScreen.main.scale)

func SWIFT_ISEQUAL_SCREEN_BOUNDS(_ vSize: CGSize, _ lSize: CGSize) -> Bool {
    return (vSize.equalTo(UIScreen.main.bounds.size) || lSize.equalTo(UIScreen.main.bounds.size))
}

let SWIFT_ISIPHONE3_5 = SWIFT_ISEQUAL_SCREEN_BOUNDS(CGSize(width: 320, height: 480), CGSize(width: 480, height: 320))
let SWIFT_ISIPHONE4_0 = SWIFT_ISEQUAL_SCREEN_BOUNDS(CGSize(width: 320, height: 568),  CGSize(width: 568, height: 320))
let SWIFT_ISIPHONE4_7 = SWIFT_ISEQUAL_SCREEN_BOUNDS(CGSize(width: 375, height: 667),  CGSize(width: 667, height: 375))
let SWIFT_ISIPHONE5_5 = SWIFT_ISEQUAL_SCREEN_BOUNDS(CGSize(width: 414, height: 736),  CGSize(width: 736, height: 414))
let SWIFT_ISIPHONE9_7 = SWIFT_ISEQUAL_SCREEN_BOUNDS(CGSize(width: 1024, height: 768), CGSize(width: 768, height: 1024))
let SWIFT_IS_LANDSCAPE = UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation)

