//
//  TLPhotoLibraryPickerView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit
import Photos

protocol TLPhotoLibraryPickerViewDelegate: NSObjectProtocol {
    func photoLibraryPickerDidSelectVideo(url:URL)
    func photoLibraryPickerDidSelectPhoto(imgData:Data)
}

class TLPhotoLibraryPickerView: UIView {
    fileprivate var collectionView:UICollectionView?
    
    fileprivate var hintLabel:UILabel = {
        let label = UILabel.init()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.init(colorHex: 0xffffff, alpha: 0.6)
        return label
    }()
    
    fileprivate var imgs = [PHAsset]()
    
    public weak var delegate:TLPhotoLibraryPickerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        
        let collectionHeight = self.height - 23
        
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize.init(width: 80, height: collectionHeight)
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 23, width: self.width, height: collectionHeight), collectionViewLayout: layout)
        collectionView!.backgroundColor = UIColor.clear
        collectionView!.delegate = self
        collectionView!.dataSource = self;
        collectionView!.showsHorizontalScrollIndicator = false
        collectionView!.register(TLPhotoLibraryPickerCell.self, forCellWithReuseIdentifier: "cell")
        self.addSubview(collectionView!)
        
        self.addSubview(hintLabel)
        
        self.loadPhotos()
    }
    
    public func loadPhotos() {
        self.imgs.removeAll()
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
        let results = PHAsset.fetchAssets(with: options)
        let dayLate = NSDate().timeIntervalSince1970 - 24 * 60 * 60
        
        var count = 0
        while count < results.count {
            let r = results[count]
            if r.creationDate?.timeIntervalSince1970 ?? 0 > dayLate {
                imgs.append(r)
            }
            count += 1
        }
        
        if imgs.count > 0 {
            hintLabel.text = "过去24小时"
            hintLabel.sizeToFit()
            hintLabel.center = CGPoint.init(x: self.width / 2, y: 23 / 2)
        }else {
            hintLabel.text = "过去24小时内没有照片"
            hintLabel.sizeToFit()
            hintLabel.center = CGPoint.init(x: self.width / 2, y: self.height / 2)
        }
        self.collectionView?.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TLPhotoLibraryPickerView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgs.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TLPhotoLibraryPickerCell
        cell.set(asset: self.imgs[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = self.imgs[indexPath.row]
        print(asset.mediaType)
        if asset.mediaType == .video {
            PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { (ass, mix, map) in
                let url = (ass as! AVURLAsset).url
                DispatchQueue.main.async {
                    self.delegate?.photoLibraryPickerDidSelectVideo(url: url)
                }
            }
        }
        
        if asset.mediaType == .image {
            PHImageManager.default().requestImageData(for: asset, options: nil, resultHandler: { (result, string, orientation, info) -> Void in
                if let r = result {
                    self.delegate?.photoLibraryPickerDidSelectPhoto(imgData: r)
                }
            })
        }
    }
}


class TLPhotoLibraryPickerCell: UICollectionViewCell {
    fileprivate lazy var thumImgview:UIImageView = {
        let imgView = UIImageView.init()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        return imgView
    }()
    
    fileprivate lazy var durationLabel:UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    public var asset:PHAsset?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(thumImgview)
        thumImgview.frame = self.bounds
        
        self.contentView.addSubview(durationLabel)
    }
    
    func set(asset:PHAsset) {
        self.asset = asset
        
        PHCachingImageManager.default().requestImage(for: asset, targetSize: self.size, contentMode: PHImageContentMode.aspectFill, options: nil) { (image, nfo) in
            self.thumImgview.image = image
        }
        
        durationLabel.isHidden = asset.mediaType != .video
        let time = Int(asset.duration)
        let h = time / 3600
        let min = Int((time - h * 3600) / 60)
        let s = Int((time - h * 3600) % 60)
        let hourStr = h <= 0 ? "" : h < 10 ? "0\(h):" : "\(h):"
        let minStr = min <= 0 ? "0:" : min < 10 ? "0\(min):" : "\(min):"
        let sStr = s <= 0 ? "" : s < 10 ? "0\(s)" : "\(s)"
        
        durationLabel.text = hourStr + minStr + sStr
        durationLabel.sizeToFit()
        durationLabel.center = CGPoint.init(x: self.width - durationLabel.width / 2 - 5, y: self.height - durationLabel.height / 2 - 5)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class TLPhotoLibraryHintView: UIView {
    fileprivate lazy var hintLabel:UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.init(colorHex: 0xffffff, alpha: 0.8)
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "向上滑动打开相册"
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        label.layer.shadowRadius = 2
        label.layer.shadowOpacity = 0.7
        return label
    }()
    
    fileprivate lazy var arrowIco = UIImageView.init(image: #imageLiteral(resourceName: "story_icon_up"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(hintLabel)
        hintLabel.sizeToFit()
        hintLabel.center = CGPoint.init(x: self.width / 2, y: self.height - 10 - hintLabel.height / 2)
        
        self.addSubview(arrowIco)
        arrowIco.sizeToFit()
        arrowIco.center = CGPoint.init(x: self.width / 2, y: 10 + arrowIco.height / 2)
        
        UIView.animate(withDuration: 0.8, delay: 0, options: [.repeat,.autoreverse], animations: {
            self.arrowIco.centerY = 5 + self.arrowIco.height / 2
        }, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
