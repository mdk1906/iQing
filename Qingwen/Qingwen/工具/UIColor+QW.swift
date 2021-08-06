//  SwiftColors.swift
//
// Copyright (c) 2014 Doan Truong Thi
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#if os(iOS)
    import UIKit
    typealias SWColor = UIColor
    #else
    import Cocoa
    typealias SWColor = NSColor
#endif

public extension SWColor {
    /**
    Create non-autoreleased color with in the given hex string
    Alpha will be set as 1 by default

    :param:   hexString
    :returns: color with the given hex string
    */
    public convenience init?(hexString: String) {
        self.init(hexString: hexString, alpha: 1.0)
    }

    /**
    Create non-autoreleased color with in the given hex string and alpha

    :param:   hexString
    :param:   alpha
    :returns: color with the given hex string and alpha
    */
    public convenience init?(hexString: String, alpha: Float) {
        var hex = hexString

        // Check for hash and remove the hash
        if hex.hasPrefix("#") {
            hex = hex.substring(from: hex.characters.index(hex.startIndex, offsetBy: 1))
        }

        if (hex.range(of: "(^[0-9A-Fa-f]{6}$)|(^[0-9A-Fa-f]{3}$)", options: .regularExpression) != nil) {

            // Deal with 3 character Hex strings
//            if hex.characters.count == 3 {
//                let redHex   = hex.substring(to: hex.characters.index(hex.startIndex, offsetBy: 1))
//                let greenHex = hex.substring(with: Range<String.Index>(hex.characters.index(hex.startIndex, offsetBy: 1)..<hex.characters.index(hex.startIndex, offsetBy: 2)))
//                let blueHex  = hex.substring(from: hex.characters.index(hex.startIndex, offsetBy: 2))
//
//                hex = redHex + redHex + greenHex + greenHex + blueHex + blueHex
//            }
//
//            let redHex = hex.substring(to: hex.characters.index(hex.startIndex, offsetBy: 2))
//            let greenHex = hex.substring(with: Range<String.Index>(hex.characters.index(hex.startIndex, offsetBy: 2)..<hex.characters.index(hex.startIndex, offsetBy: 4)))
//            let blueHex = hex.substring(with: Range<String.Index>(hex.characters.index(hex.startIndex, offsetBy: 4)..<hex.characters.index(hex.startIndex, offsetBy: 6)))
//
//            var redInt:   CUnsignedInt = 0
//            var greenInt: CUnsignedInt = 0
//            var blueInt:  CUnsignedInt = 0
//
//            Scanner(string: redHex).scanHexInt32(&redInt)
//            Scanner(string: greenHex).scanHexInt32(&greenInt)
//            Scanner(string: blueHex).scanHexInt32(&blueInt)

            var cString: String = hexString.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            
            if cString.hasPrefix("0X") {
                cString = cString.substring(from: cString.index(cString.startIndex, offsetBy: 2))
            }
            if cString.hasPrefix("#") {
                cString = cString.substring(from: cString.index(cString.startIndex, offsetBy: 1))
            }
            
            
            var range: NSRange = NSMakeRange(0, 2)
            let rString = (cString as NSString).substring(with: range)
            range.location = 2
            let gString = (cString as NSString).substring(with: range)
            range.location = 4
            let bString = (cString as NSString).substring(with: range)
            
            var r: UInt32 = 0x0
            var g: UInt32 = 0x0
            var b: UInt32 = 0x0
            Scanner.init(string: rString).scanHexInt32(&r)
            Scanner.init(string: gString).scanHexInt32(&g)
            Scanner.init(string: bString).scanHexInt32(&b)
            
            self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(alpha))
        }
        else {
            // Note:
            // The swift 1.1 compiler is currently unable to destroy partially initialized classes in all cases,
            // so it disallows formation of a situation where it would have to.  We consider this a bug to be fixed
            // in future releases, not a feature. -- Apple Forum
            self.init()
            return nil
        }
    }

    /**
    Create non-autoreleased color with in the given hex value
    Alpha will be set as 1 by default

    :param:   hex
    :returns: color with the given hex value
    */
    public convenience init?(hex: Int) {
        self.init(hex: hex, alpha: 1.0)
    }

    /**
    Create non-autoreleased color with in the given hex value and alpha

    :param:   hex
    :param:   alpha
    :returns: color with the given hex value and alpha
    */
    public convenience init?(hex: Int, alpha: Float) {
        let hexString = NSString(format: "%2X", hex)
        self.init(hexString: hexString as String , alpha: alpha)
    }
}
