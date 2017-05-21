//
//  TLColorPaletteView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

enum TLStoryDeployType {
    case text
    case draw
}

protocol TLColorPaletteViewDelegate: NSObjectProtocol {
    func colorPaletteDidSelected(color:UIColor)
    func colorPaletteSliderView(hidden:Bool)
}

class TLColorPaletteView: UIView {
    fileprivate lazy var pageControl:UIPageControl = {
        let control = UIPageControl.init()
        control.currentPage = 1
        control.numberOfPages = 3
        return control
    }()
    
    fileprivate var sliderBtn:UIButton = {
        let btn = UIButton.init(type: UIButtonType.custom)
        btn.setImage(#imageLiteral(resourceName: "story_publish_icon_drawing_tool_size"), for: .normal)
        btn.backgroundColor = UIColor.white
        btn.layer.cornerRadius = 15
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 2
        return btn
    }()
    
    fileprivate var collectionView:UICollectionView?
        
    fileprivate var colors:[[UIColor]] = [
        [
            UIColor.init(colorHex: 0xffffff, alpha: 1),
            UIColor.init(colorHex: 0x000000, alpha: 1),
            UIColor.init(colorHex: 0x3e9aec, alpha: 1),
            UIColor.init(colorHex: 0x73bf56, alpha: 1),
            UIColor.init(colorHex: 0xfbcb64, alpha: 1),
            UIColor.init(colorHex: 0xfc8f3b, alpha: 1),
            UIColor.init(colorHex: 0xe64e55, alpha: 1),
            UIColor.init(colorHex: 0xa11db9, alpha: 1),
            UIColor.init(colorHex: 0xeb4b59, alpha: 1)
        ],
        [
            UIColor.init(colorHex: 0xe50f22, alpha: 1),
            UIColor.init(colorHex: 0xeb878d, alpha: 1),
            UIColor.init(colorHex: 0xfdd3d4, alpha: 1),
            UIColor.init(colorHex: 0xfedcb6, alpha: 1),
            UIColor.init(colorHex: 0xfec386, alpha: 1),
            UIColor.init(colorHex: 0xd1904d, alpha: 1),
            UIColor.init(colorHex: 0x97653d, alpha: 1),
            UIColor.init(colorHex: 0x3f2621, alpha: 1),
            UIColor.init(colorHex: 0x1e4a2a, alpha: 1),
            ],
        [
            UIColor.init(colorHex: 0x262626, alpha: 1),
            UIColor.init(colorHex: 0x363636, alpha: 1),
            UIColor.init(colorHex: 0x555555, alpha: 1),
            UIColor.init(colorHex: 0x737373, alpha: 1),
            UIColor.init(colorHex: 0x999999, alpha: 1),
            UIColor.init(colorHex: 0xb2b2b2, alpha: 1),
            UIColor.init(colorHex: 0xc7c7c7, alpha: 1),
            UIColor.init(colorHex: 0xdbdbdb, alpha: 1),
            UIColor.init(colorHex: 0xefefef, alpha: 1)
        ]
    ]
    
    public weak var delegate:TLColorPaletteViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let layout = TLColorPaletteCollectionViewFlowLayout.init()
        collectionView = UICollectionView.init(frame: CGRect.init(x: 40, y: 15, width: self.width - 40, height: 30), collectionViewLayout: layout)
        collectionView!.backgroundColor = UIColor.clear
        collectionView!.delegate = self
        collectionView!.dataSource = self;
        collectionView!.showsHorizontalScrollIndicator = false
        collectionView!.register(TLColorPaletteCell.self, forCellWithReuseIdentifier: "cell")
        collectionView!.contentSize = CGSize.init(width: self.width - 45, height: 30)
        self.addSubview(collectionView!)
        
        self.addSubview(pageControl)
        pageControl.frame = CGRect.init(x: 0, y: 0, width: 100, height: 20)
        pageControl.center = CGPoint.init(x: self.width / 2, y: self.height - pageControl.height / 2)
        
        sliderBtn.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        sliderBtn.center = CGPoint.init(x: 5 + sliderBtn.width / 2, y: self.height / 2)
        self.addSubview(sliderBtn)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(sliderAction))
        sliderBtn.addGestureRecognizer(tap)
    }
    
    func setDefault(color:UIColor?) {
        if let c = color {
            for (i,array) in colors.enumerated() {
                if let _ = array.index(of: c) {
                    collectionView?.scrollToItem(at: IndexPath.init(row: 0, section: i), at: .left, animated: false)
                    sliderBtn.backgroundColor = c
                    break
                }
            }
        }else {
            collectionView?.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: .left, animated: false)
            sliderBtn.backgroundColor = UIColor.white
        }        
    }
    
    func sliderAction(sender:UITapGestureRecognizer) {
        let b = sender.view as! UIButton
        b.isSelected = !b.isSelected
        self.delegate?.colorPaletteSliderView(hidden: !b.isSelected)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TLColorPaletteView: UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors[section].count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return colors.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TLColorPaletteCell
        cell.color = colors[indexPath.section][indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let color = colors[indexPath.section][indexPath.row]
        self.sliderBtn.backgroundColor = color
        self.delegate?.colorPaletteDidSelected(color: color)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.init(width: 10, height: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.init(width: 10, height: 0)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.width)
    }
}

class TLColorPaletteCollectionViewFlowLayout: UICollectionViewFlowLayout{
    override init() {
        super.init()
        self.itemSize = CGSize.init(width: 20, height: 20)
        self.minimumInteritemSpacing = 10
        self.scrollDirection = .horizontal
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        let width = self.collectionView!.width
        
        if proposedContentOffset.x < width / 2 {
            return CGPoint.init(x: 0, y: proposedContentOffset.y)
        }
        
        if proposedContentOffset.x > width / 2 && proposedContentOffset.x < width * 1.5 {
            return CGPoint.init(x: width, y: proposedContentOffset.y)
        }
        
        return CGPoint.init(x: width * 2 + 5, y: proposedContentOffset.y)
    }
}

class TLColorPaletteCell: UICollectionViewCell {
    fileprivate lazy var colorView = UIView.init()
    public var color:UIColor? {
        get {
            return self.colorView.backgroundColor
        }
        set {
            self.colorView.backgroundColor = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        colorView.frame = self.bounds
        colorView.layer.cornerRadius = self.width / 2
        colorView.layer.masksToBounds = true
        colorView.layer.borderColor = UIColor.white.cgColor
        colorView.layer.borderWidth = 2
        self.contentView.addSubview(colorView)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return super.point(inside: point, with: event)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
