//
//  Extension.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/04/08.
//  Copyright © 2021 홍희표. All rights reserved.
//

import UIKit

// Android 원본(res/values/color.xml 등)에서 가져온 디자인 토큰
extension UIColor {
    static let colorPrimary     = UIColor(red: 219/255, green: 36/255,  blue: 40/255,  alpha: 1) // #DB2428
    static let colorPrimaryDark = UIColor(red: 197/255, green: 18/255,  blue: 22/255,  alpha: 1) // #C51216
    static let colorAccent      = UIColor(white: 170/255, alpha: 1)                              // #AAAAAA
    static let textTimestamp    = UIColor(red: 160/255, green: 163/255, blue: 167/255, alpha: 1) // #A0A3A7
    static let profileBg        = UIColor(white: 238/255, alpha: 1)                              // #EEEEEE
    static let gridTitle        = UIColor(white: 76/255,  alpha: 1)                              // #4C4C4C
    static let chatCanvas       = UIColor(red: 244/255, green: 250/255, blue: 255/255, alpha: 1) // #F4FAFF
    static let bubbleOther      = UIColor(red: 229/255, green: 231/255, blue: 235/255, alpha: 1) // #E5E7EB
    static let bubbleMine       = UIColor(red: 104/255, green: 208/255, blue: 251/255, alpha: 1) // #68D0FB
    static let bubbleOtherText  = UIColor(white: 67/255,  alpha: 1)                              // #434343
    static let bubbleMineText   = UIColor(red: 10/255,  green: 35/255,  blue: 50/255,  alpha: 1) // #0A2332
    static let chatSenderName   = UIColor(white: 119/255, alpha: 1)                              // #777777
    static let chatInputText    = UIColor(white: 98/255,  alpha: 1)                              // #626262
    static let sendActive       = UIColor(red: 159/255, green: 73/255,  blue: 209/255, alpha: 1) // #9F49D1
    static let buttonNormalBg   = UIColor(white: 250/255, alpha: 1)                              // #FAFAFA
    static let replyTimestamp   = UIColor(white: 136/255, alpha: 1)                              // #888888
}

extension UIButton {
    // Android background_sendbtn_n/p 셀렉터 대응 — 채팅/댓글 전송 버튼 공통 스타일
    // 빈 입력: 흰 배경 + 회색 테두리 + 회색 텍스트 / 입력중: #9F49D1 보라 배경 + 흰 bold
    func applySendButtonStyle(hasText: Bool) {
        layer.cornerRadius = 2
        layer.borderWidth = hasText ? 0 : 1
        layer.borderColor = UIColor.colorAccent.cgColor
        backgroundColor = hasText ? .sendActive : .white
        setTitleColor(hasText ? .white : .darkGray, for: .normal)
        titleLabel?.font = hasText ? .boldSystemFont(ofSize: 15) : .systemFont(ofSize: 15)
        contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    }
}

extension UIImage {
    // 버튼 highlighted 배경 등에 쓰는 1×1 단색 이미지
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension UICollectionViewCell {
    // Android CardView(cornerRadius 4dp, elevation 3dp) 상당
    func cardView() {
        contentView.layer.cornerRadius = 4.0
        contentView.layer.masksToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.5)
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.24
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
}

extension UILabel {
    func getLineCount() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))
        let text = (self.text ?? "") as NSString
        let textHeight = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).height
        let lineHeight = font.lineHeight
        return Int(ceil(textHeight / lineHeight))
    }
}
