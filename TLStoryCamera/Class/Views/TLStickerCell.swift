//
//  TLStickerCell.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

class TLStickerCell: UICollectionViewCell {
    public lazy var imgView:UIImageView = UIImageView.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imgView)
        imgView.frame = self.bounds
        
        imgView.contentMode = .scaleAspectFit
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
