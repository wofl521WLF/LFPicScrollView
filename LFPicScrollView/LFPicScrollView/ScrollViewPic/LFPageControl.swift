//
//  LFPageControl.swift
//  LFPicScrollView
//
//  Created by 吴林丰 on 2017/3/14.
//  Copyright © 2017年 吴林丰. All rights reserved.
//

import UIKit

class LFPageControl: UIView {

    
    /**
     页面基本常量
     */
    let PAGE_VIEW_SPACE_BETWEEN_DOTS = 3
    let PAGE_VIEW_NORMAL_DOT_WIDTH = 18
    let PAGE_VIEW_NORMAL_DOT_HEIGHT = 4
    let PAGE_VIEW_HIGHLIGHT_DOT_WIDTH = 18
    let PAGE_VIEW_HIGHLIGHT_DOT_HEIGHT = 4
    let PAGE_VIEW_SELECTED_DOT_IMAGE = UIImage.init(named: "explain_highlight_dot.png")
    let PAGE_VIEW_DOT_IMAGE = UIImage.init(named: "explain_normal_dot.png")
    
    /**
     页面基本变量
     */
    var _numberOfPages:NSInteger{
        get{
            return self.numberOfPages!
        }
        set(newnumberOfPages){
            self.numberOfPages = newnumberOfPages
            if self._selectedDotView != nil {
                 return
            }
            self.frame = CGRect.init(x: 0, y: 0, width: Int(self.getPageViewWidth(pageNumber: newnumberOfPages)), height: PAGE_VIEW_NORMAL_DOT_HEIGHT)
            for i in 0..<_numberOfPages {
                let dotView:UIImageView = UIImageView.init(frame: CGRect.init(x: Int(self.getDotXWithIndex(index: i)), y: 0, width: PAGE_VIEW_NORMAL_DOT_WIDTH, height: PAGE_VIEW_NORMAL_DOT_HEIGHT))
                dotView.image = PAGE_VIEW_DOT_IMAGE
                dotView.tag = 100 + i
                self.addSubview(dotView)
            }
            _selectedDotView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: PAGE_VIEW_HIGHLIGHT_DOT_WIDTH, height: PAGE_VIEW_HIGHLIGHT_DOT_HEIGHT))
            _selectedDotView?.image = PAGE_VIEW_SELECTED_DOT_IMAGE
            self.addSubview(_selectedDotView!)
        }
    }
    var _currentPage:NSInteger{
        get {
            return self.currentPage!
        }
        set(newcurentPage){
            self.currentPage = newcurentPage
            _selectedDotView?.center = (self.viewWithTag(100 + newcurentPage)?.center)!
        }
    }
    var _selectedDotView:UIImageView?
    var numberOfPages:NSInteger?
    var currentPage:NSInteger?
    
    func getPageViewWidth(pageNumber:NSInteger) -> CGFloat {
        let ww1:NSInteger = _currentPage * PAGE_VIEW_NORMAL_DOT_WIDTH
        let ww2:NSInteger = (pageNumber - 1) * PAGE_VIEW_SPACE_BETWEEN_DOTS
        let wwsum:CGFloat = CGFloat(ww1) + CGFloat(ww2)
        return wwsum
    }
    
    func getDotXWithIndex(index:NSInteger) -> CGFloat {
         let DotX:NSInteger = index * (PAGE_VIEW_SPACE_BETWEEN_DOTS + PAGE_VIEW_NORMAL_DOT_WIDTH)
         return CGFloat(DotX)
    }
    
    
    
    init(pageNum:NSInteger) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        _currentPage = 0
        _numberOfPages = pageNum
        let width:CGFloat = self.getPageViewWidth(pageNumber: pageNum)
        let height:CGFloat = CGFloat(PAGE_VIEW_NORMAL_DOT_HEIGHT)
        self.frame = CGRect.init(x: 0, y: 0, width: width, height: height)
    }
    
    func setInitStateFromNib(pageNum:NSInteger){
        _currentPage = 0
        _numberOfPages = pageNum
        let width:CGFloat = self.getPageViewWidth(pageNumber: pageNum)
        let height:CGFloat = CGFloat(PAGE_VIEW_NORMAL_DOT_HEIGHT)
        self.frame = CGRect.init(x: 0, y: 0, width: width, height: height)
        for i in 0...pageNum{
            let originx:CGFloat = self.getDotXWithIndex(index: i)
            let dotView:UIImageView = UIImageView.init(frame: CGRect.init(x: originx, y: 0, width: CGFloat(PAGE_VIEW_NORMAL_DOT_WIDTH), height: CGFloat(PAGE_VIEW_NORMAL_DOT_HEIGHT)))
            dotView.image = PAGE_VIEW_DOT_IMAGE
            dotView.tag = 100 + i
            self.addSubview(dotView)
        
        }
        _selectedDotView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: CGFloat(PAGE_VIEW_HIGHLIGHT_DOT_WIDTH), height: CGFloat(PAGE_VIEW_HIGHLIGHT_DOT_HEIGHT)))
        _selectedDotView?.image = PAGE_VIEW_SELECTED_DOT_IMAGE
        self.addSubview(_selectedDotView!)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
