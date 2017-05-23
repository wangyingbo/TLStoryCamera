//
//  TLPhotoLibraryPickerView.swift
//  TLStoryCamera
//
//  Created by garry on 2017/5/23.
//  Copyright © 2017年 com.garry. All rights reserved.
//

import UIKit

class TLPhotoLibraryPickerView: UIView {
    fileprivate var collectionView:UICollectionView?
    
    fileprivate var hintLabel:UILabel = {
        let label = UILabel.init()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.init(colorHex: 0xffffff, alpha: 0.5)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 23, width: self.width, height: self.height - 23))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
