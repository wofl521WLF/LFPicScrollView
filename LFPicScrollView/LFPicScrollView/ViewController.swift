//
//  ViewController.swift
//  LFPicScrollView
//
//  Created by 吴林丰 on 2017/3/14.
//  Copyright © 2017年 吴林丰. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var picView:LFPicScrollView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dataArray = ["http://yun.dabai.7lk.com/assets/banner/1488962203558.jpg",
                         "http://yun.dabai.7lk.com/assets/banner/1489048359757.jpg",
                         "http://yun.dabai.7lk.com/assets/banner/1489143487010.jpg",
                         "http://yun.dabai.7lk.com/assets/banner/1487043308059.jpg",
                         "http://yun.dabai.7lk.com/assets/banner/1486716464532.jpg"]
        if self.picView != nil {
             self.picView?.removeFromSuperview()
        }else{
            self.picView = LFPicScrollView.init(frame: CGRect.init(x: 0, y: 64, width: kScreenWidth, height: 200), imageUrls: dataArray as NSArray)
            //当数组大于1的时候启用自动轮播
            if dataArray.count > 1{
                self.picView?.AutoScrollDelay = 4
                self.picView?.style = .PageControlAtCenter                
            }
            self.view.addSubview(self.picView!)
            self.picView?.clickActionBlock = {(_ index:NSInteger) in
                print("第\(index) 张图片被点击")
            }
        }
        
        LFImageManager.sharedInstance.DownloadImageRepeatCount = 1
        LFImageManager.sharedInstance.downLoadErrorBlock = {(_ error:NSError,_ imageUrl:NSString) in
            print("\(imageUrl) 链接下载时发生\(error)")
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

