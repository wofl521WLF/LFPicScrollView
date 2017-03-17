//
//  LFPicScrollView.swift
//  LFPicScrollView
//
//  Created by 吴林丰 on 2017/3/14.
//  Copyright © 2017年 吴林丰. All rights reserved.
//

import UIKit

//定义枚举类型
enum PageControlStyle:Int {
    case PageControlAtCenter
    case PageControlAtRight
}

/**
 当点击图片的时候，相应的返回value所在的index，和value所对应的链接，便于
 页面之间的跳转
 */
typealias clickBlock = (_ index:NSInteger) -> Void

class LFPicScrollView: UIView,UIScrollViewDelegate {

    
    //页面用的常量
    private var myWidth:CGFloat{
        get{
            return self.frame.size.width
        }
    }
    private var myHeight:CGFloat{
        get{
            return self.frame.size.height
        }
    }
    
    private var pageSize:CGFloat{
        get{
            return myHeight*0.2 > 25 ? 25:(myHeight*0.2)
        }
    }
    private weak var _leftImageView:UIImageView?
    private weak var _centerImageView:UIImageView?
    private weak var _rightImageView:UIImageView?
    private weak var _PageControl:LFPageControl?
    private var _timer:Timer?
    private var _currentIndex:NSInteger?
    private var MaxImageCount:NSInteger?
    private var maxCount:NSInteger{
        get{
            return self.MaxImageCount!
        }
        set(newMaxCount){
            MaxImageCount = newMaxCount
            self.prepareImageView()
            self.preparePageControl()
            self.setUpTimer()
            self.changeImage(LeftIndex: newMaxCount - 1, centerIndex: 0, rightIndex: 1)
        }
    }
    private var _isNetwork:Bool?
    
    private var plcImage:UIImage{
        get{
            return self.placeImage!
        }
        set(newPlcImage){
            self.placeImage = newPlcImage
            self.changeImage(LeftIndex: self.maxCount - 1, centerIndex: 0, rightIndex: 1)
        }
    }
    private var placeImage:UIImage? //占位图
    private var scrollView:UIScrollView? //轮播控制器
    private var autodeley:TimeInterval?
    
    var AutoScrollDelay:TimeInterval{
        get{
            return self.autodeley!
        }
        set(newAutoDelay){
            self.autodeley = newAutoDelay
            self.removeTimer()
            self.setUpTimer()
        }
    } //时间小于0.5秒时不自动播放，默认间隔2为2秒
    private var imgUrls:NSArray{
        get{
            return urlArr as NSArray
        }
        set(newImgUrls){
            if newImgUrls.count > 0 {
                _isNetwork = (newImgUrls.firstObject as! String).hasPrefix("http")
                if _isNetwork == true {
                    urlArr = newImgUrls.copy() as! Array<String>
                    self.getImage()
                }else{
                    let temp:NSMutableArray = NSMutableArray.init(capacity: newImgUrls.count)
                    for name in newImgUrls{
                        let image:UIImage = UIImage.init(named: name as! String)!
                        temp.add(image)
                    }
                    urlArr = temp.copy() as! Array<String>
                }
            }
        }
    }
    var urlArr = Array<String>()
    var stylepp:PageControlStyle?
    var style:PageControlStyle{
        get{
            return self.stylepp!
        }
        set(newstyle){
            if newstyle == .PageControlAtRight {
                let witdh:CGFloat = CGFloat(self.maxCount)*17.5
                _PageControl?.frame = CGRect.init(x: 0, y: 0, width: witdh, height: 6)
                _PageControl?.center = CGPoint.init(x: myWidth-witdh*0.5+14, y: myHeight-pageSize*0.5+5)
            }else if(newstyle == .PageControlAtCenter){
                let witdh:CGFloat = CGFloat((self.maxCount - 1)*8 + self.maxCount*6)
                _PageControl?.frame = CGRect.init(x: 0, y: 0, width: witdh, height: 6)
                _PageControl?.center = CGPoint.init(x: self.center.x, y: myHeight-8-(_PageControl?.frame.size.height)!/2)
            }
        }
        
    } //设置pageControl的类型，默认是PageControlAtCenter
    var clickActionBlock:clickBlock? //定义点击Block
    init(frame:CGRect,imageUrls:NSArray){
        super.init(frame: frame)
        if imageUrls.count < 2 {
            //当只返回一个图片或者没有图片的时候
             self.prepareScrollView()
            self.dealAnotherAction(imageUrls)
        }else{
            self.imgUrls = imageUrls
            self.prepareScrollView()
            self.maxCount = imageUrls.count
        }
    }
    
    func dealAnotherAction(_ urls:NSArray){
        self.imgUrls = urls
        self.scrollView?.contentOffset = CGPoint.init(x: 0, y: 0)
        let imageview = UIImageView.init(frame: (self.scrollView?.bounds)!)
        if urls.count == 0 {
            imageview.image = creatImageWithColor(color: UIColor.white)
        }else{
            imageview.image = LFImageManager.sharedInstance.webImageCache.object(forKey: urlArr[0]) as! UIImage?
        }
        let gesture:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(TapAction(_:)))
        imageview.contentMode = .scaleAspectFill
        imageview.clipsToBounds = true
        imageview.isUserInteractionEnabled = true
        imageview.addGestureRecognizer(gesture)
        self.scrollView?.isScrollEnabled = false
        self.removeTimer()
        self.scrollView?.addSubview(imageview)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /**
     更新图片
     */
    func ImageUpdate(){
        if urlArr.count > 0{
            self.perform(#selector(self.addImage), on: Thread.main, with: nil, waitUntilDone: true)
        }
    }
    
    func addImage() {
        let image1:UIImage? = LFImageManager.sharedInstance.webImageCache.object(forKey: urlArr[0]) as! UIImage?
        let image2:UIImage? = LFImageManager.sharedInstance.webImageCache.object(forKey: urlArr[1]) as! UIImage?
        if image1 != nil {
             _centerImageView?.image = image1
        }
        
        if image2 != nil {
            _rightImageView?.image = image2
        }
        
    }
    
    func getImage(){
         LFImageManager.sharedInstance.delegate = self
         LFImageManager.sharedInstance.downCount = urlArr.count
        for urlString in urlArr {
             LFImageManager.sharedInstance.downLoadImage(url: urlString as NSString)
        }
    }
    /**
     *  设置Timer的状态
     *
     *  @param state NO-停止定时器; YES-开始定时器
     */
    func setTimerState(state:Bool){
        let date:Date = state ? Date.init(timeIntervalSinceNow: 4) : Date.distantFuture
        _timer?.fireDate = date
        _timer?.fire()
    }

    /**
     当用户点击图片时候，所执行的方法
     */
    func TapAction(_ tap: UITapGestureRecognizer) {
        if (self.clickActionBlock != nil) {
             self.clickActionBlock!(_currentIndex!)
        }
    }
    //准备pageControl
    func prepareScrollView(){
        let scrollviewFrame = CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        let sc = UIScrollView.init(frame: scrollviewFrame)
        sc.showsVerticalScrollIndicator = false
        sc.showsHorizontalScrollIndicator = false
        sc.contentMode = UIViewContentMode.center
        sc.isScrollEnabled = true
        sc.contentSize = CGSize.init(width: 3*scrollviewFrame.width, height: scrollviewFrame.height)
        sc.delegate = self
        sc.backgroundColor = UIColor.clear
        sc.isPagingEnabled = true
        _currentIndex = 0
        self.AutoScrollDelay = 2.0
        self.scrollView = sc
        self.addSubview(self.scrollView!)
    }

    //设置ImageView
    func prepareImageView(){
    
        let left:UIImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: myWidth, height: myHeight))
        let center:UIImageView = UIImageView.init(frame: CGRect.init(x: myWidth, y: 0, width: myWidth, height: myHeight))
        let right:UIImageView = UIImageView.init(frame: CGRect.init(x: myWidth*2, y: 0, width: myWidth, height: myHeight))
        left.contentMode = .scaleAspectFill
        left.clipsToBounds = true
        center.contentMode = .scaleAspectFill
        center.clipsToBounds = true
        right.contentMode = .scaleAspectFill
        right.clipsToBounds = true
        center.isUserInteractionEnabled = true
        let gesture:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(TapAction(_:)))
        center.addGestureRecognizer(gesture)
        self.scrollView?.addSubview(left)
        self.scrollView?.addSubview(center)
        self.scrollView?.addSubview(right)
        _leftImageView = left
        _centerImageView = center
        _rightImageView = right
    }
    func preparePageControl(){
        
        let page = LFPageControl.init(pageNum: self.maxCount)
        page._currentPage = 0
        page._numberOfPages = self.maxCount
        page.frame = CGRect.init(x: 0, y: myHeight, width: myWidth, height: 7)
        _PageControl = page
        self.addSubview(_PageControl!)
        self.bringSubview(toFront: _PageControl!)
    }
    
    //启动定时器
    func setUpTimer(){
        if self.AutoScrollDelay.isLess(than: 0.5) == false {
            if _timer != nil {
                 self.removeTimer()
            }
            _timer = Timer.scheduledTimer(timeInterval: self.AutoScrollDelay, target: self, selector: #selector(scorll), userInfo:nil, repeats: true)
        }
    }
    
    
    func removeTimer(){
        if _timer == nil{
            return
        }
        
        _timer?.invalidate()
        _timer = nil
    }
    
    func changeImage(LeftIndex:NSInteger,centerIndex:NSInteger,rightIndex:NSInteger){
        if _isNetwork == true{
             _leftImageView?.image = self.setImageWithIndex(index: LeftIndex)
            _centerImageView?.image = self.setImageWithIndex(index: centerIndex)
            _rightImageView?.image = self.setImageWithIndex(index: rightIndex)
        }
        self.scrollView?.contentOffset = CGPoint.init(x: myWidth, y: 0)
    }
    
    func setImageWithIndex(index:NSInteger) -> UIImage {
        let image:UIImage? = LFImageManager.sharedInstance.webImageCache.object(forKey:urlArr[index]) as! UIImage?
        if image != nil {
             return image!
        }else{
            let img:UIImage = UIImage.init(named: "8354AE0B1E3B911B8A3CF18633A32988.jpg")!
            return img
        }
    }
    
    func scorll(){
        let width:Int = Int(kScreenWidth)
        let offx:Int = Int((self.scrollView?.contentOffset.x)!)
        if offx % width != 0 {
            self.scrollView?.setContentOffset(CGPoint.init(x: 0, y: 0), animated: false)
            return
        }
        self.scrollView?.setContentOffset(CGPoint.init(x: (self.scrollView?.contentOffset.x)! + myWidth, y: 0), animated: true)
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.setUpTimer()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
         self.removeTimer()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.changeImage(offsetx: scrollView.contentOffset.x)
    }
    

    func changeImage(offsetx:CGFloat) {
        if offsetx >= myWidth * 2 {
             _currentIndex! += 1
            if _currentIndex! == self.maxCount - 1 {
                 self.changeImage(LeftIndex: _currentIndex! - 1, centerIndex: _currentIndex!, rightIndex: 0)
            }else if(_currentIndex! == self.maxCount){
                _currentIndex = 0
                self.changeImage(LeftIndex: self.maxCount - 1, centerIndex: 0, rightIndex: 1)
            }else{
                self.changeImage(LeftIndex: _currentIndex! - 1, centerIndex: _currentIndex!, rightIndex: _currentIndex! + 1)
            }
            _PageControl?._currentPage = _currentIndex!
        }
        
        if offsetx <= 0 {
            _currentIndex! -= 1
            if _currentIndex! == 0 {
                self.changeImage(LeftIndex: self.maxCount - 1, centerIndex: 0, rightIndex: 1)
            }else if(_currentIndex! == -1){
                _currentIndex! = self.maxCount - 1
                self.changeImage(LeftIndex: _currentIndex! - 1, centerIndex: _currentIndex!, rightIndex: 0)
            }else{
                self.changeImage(LeftIndex: _currentIndex! - 1, centerIndex: _currentIndex!, rightIndex: _currentIndex! + 1)
            }
            _PageControl?._currentPage = _currentIndex!
        }
        
    }
    
    deinit {
        self.removeTimer()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
