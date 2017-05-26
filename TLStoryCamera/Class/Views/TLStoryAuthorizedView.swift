//
//  TLStoryAuthorizedView.swift
//  TLStoryCamera
//
//  Created by garry on 2017/5/26.
//  Copyright © 2017年 com.garry. All rights reserved.
//

import UIKit

class TLStoryAuthorizedView: UIView {
    fileprivate var authorizedManager = TLAuthorizedManager()
    fileprivate var titleLabel:UILabel = {
        let lable = UILabel.init()
        lable.text = "允许访问即可拍摄照片和视频"
        lable.textColor = UIColor.init(colorHex: 0xcccccc, alpha: 1)
        lable.font = UIFont.systemFont(ofSize: 18)
        return lable
    }()
    
    fileprivate var openCameraBtn:UIButton = {
       let btn = UIButton.init()
        btn.setTitle("启用相机访问权限", for: .normal)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        authorizedManager.delegate = self
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TLStoryAuthorizedView: TLAuthorizedManagerDelegate {
    func authorization(type: TLAuthorizedManager.AuthorizedType, authorized: Bool) {
        
    }
}
