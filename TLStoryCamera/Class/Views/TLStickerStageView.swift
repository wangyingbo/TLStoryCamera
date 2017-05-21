//
//  TLStickerStageView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

protocol TLStickerStageViewDelegate:NSObjectProtocol {
    func hideIcons(_ hidden:Bool)
    func editing(textSticker:TLStickerTextView)
}

class TLStickerStageView: UIView {
    fileprivate lazy var deleteImgView:UIImageView = {
        let imgView = UIImageView.init()
        imgView.image = #imageLiteral(resourceName: "story_publish_icon_delete")
        imgView.contentMode = .center
        return imgView
    }()
    
    fileprivate var stickers = [UIView]()
    
    fileprivate var isPrepareDelete = false
    
    fileprivate var tap:UITapGestureRecognizer?
    
    weak var delegate:TLStickerStageViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        
        deleteImgView.bounds = CGRect.init(x: 0, y: 0, width: 80, height: 80)
        deleteImgView.center = CGPoint.init(x: self.bounds.width / 2, y: self.bounds.height - deleteImgView.height / 2)
        self.addSubview(deleteImgView)
        
        self.deleteImgView.isHidden = true
    }
    
    public func addSticker(img:UIImage) {
        let stickerView = TLStickerView.init(img: img, bgView: self)
        stickerView.bounds = CGRect.init(x: 0, y: 0, width: 100, height: 100)
        stickerView.delegate = self
        self.addSubview(stickerView)
        stickers.append(stickerView)
    }
    
    public func addTextView(sticker:TLStickerTextView) {
        sticker.delegate = self
        self.addSubview(sticker)
        stickers.append(sticker)
    }
    
    func removeSticker(sticker:UIView) {
        sticker.removeFromSuperview()
        
        if let index = stickers.index(of: sticker) {
            stickers.remove(at: index)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TLStickerStageView : TLStickerViewDelegate {
    func stickerEditing(sticker: TLStickerTextView) {
        self.delegate?.editing(textSticker: sticker)
    }

    func panDeleteSticker(point: CGPoint, sticker: UIView, isEnd: Bool) {
        let cPoint = self.convert(point, to: deleteImgView)
        if self.deleteImgView.point(inside: cPoint, with: nil) {
            if !isPrepareDelete {
                (sticker as! TLStickerViewProtocol).zoom(out: true)
                isPrepareDelete = true
            }
        }else {
            if isPrepareDelete {
                (sticker as! TLStickerViewProtocol).zoom(out: false)
                isPrepareDelete = false
            }
        }
        
        if isPrepareDelete && isEnd {
            UIView.animate(withDuration: 0.26, animations: {
                sticker.bounds = CGRect.init(x: 0, y: 0, width: 0, height: 0)
                sticker.alpha = 0
            }, completion: { (x) in
                self.removeSticker(sticker: sticker)
                self.isPrepareDelete = false
            })
        }
        
        self.deleteImgView.isHidden = isEnd
        
        self.delegate?.hideIcons(!isEnd)
    }
    
    func makeStickerBecomeFirstRespond(sticker: UIView) {
        for v in stickers {
            if v == sticker {
                self.bringSubview(toFront: v)
                break;
            }
        }
    }
}
