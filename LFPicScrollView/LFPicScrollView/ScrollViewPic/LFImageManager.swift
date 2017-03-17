//
//  LFImageManager.swift
//  LFPicScrollView
//
//  Created by 吴林丰 on 2017/3/14.
//  Copyright © 2017年 吴林丰. All rights reserved.
//

import UIKit
//图片下载失败会调用该block(如果设置了重复下载次数,则会在重复下载完后,假如还没下载成功,就会调用该block)
//error错误信息
//url下载失败的imageurl
typealias DownLoadImageErrorBlock = (_ error:NSError,_ imageUrl:NSString) -> Void

class LFImageManager: NSObject {

    //下载失败重复下载的次数。默认不重复
    var DownloadImageRepeatCount:NSInteger?
 
    var downLoadErrorBlock:DownLoadImageErrorBlock?
    lazy var webImageCache:NSMutableDictionary = {
        let webImageData:NSMutableDictionary = NSMutableDictionary.init()
        return webImageData
    }()
    
    var downCount:NSInteger?
    
    var delegate:Any?
    
    var strSample = NSString()
    
    lazy var cachePath:NSString = {
        let cachePaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
        return cachePaths
    }()
    
    lazy var DownloadImageCount:NSMutableDictionary = {
        let downloadImageCount = NSMutableDictionary.init()
        return downloadImageCount
    }()
    
    static let sharedInstance:LFImageManager = {
        let instance = LFImageManager ()
        return instance
    } ()
    
    // MARK: Init
    override init() {
        print("My Class Initialized")
        // initialized with variable or property
        strSample = "My String"
    }
    
    //MARK -- downLoadImage
    func LoadDiskCache(url:NSString) -> Bool {
        let contentsOfFile:String = self.cachePath.appendingPathComponent(url.lastPathComponent)
        do {
            let data:NSData = try NSData.init(contentsOfFile: contentsOfFile)
            if let image:UIImage = UIImage.init(data: data as Data) {
                self.webImageCache.setObject(image, forKey: url)
                return true
            }else{
                try?FileManager.default.removeItem(atPath: self.cachePath.appendingPathComponent(url.lastPathComponent))
                return false
            }
        } catch {
            return false
        }
    }
    
    
    //MARK ---下载的图片保存到ImageCache和沙盒中,key为urlString
    func downLoadImage(url:NSString){
        if url.length == 0 || (url as String).isEmpty == true {
            return
        }
        
        if self.LoadDiskCache(url: url) {
            return
        }
        let urlPath:URL = URL.init(string: url as String)!
        URLSession.shared.dataTask(with:urlPath, completionHandler: { (data, response, error) in
            self.downLoadImagefinish(data: data!, urlString: (url as String), error: error, response: response!)
        }).resume()
    }
    
    
    //下载完成
    func downLoadImagefinish(data:Data,urlString:String,error:Error?,response:URLResponse){
        let image:UIImage? = UIImage.init(data: data)
        if image == nil {
            
            self.repeatDownLoadImage(urlString: urlString, error: error)
            return
        }
        
        if image == nil {
            let res:HTTPURLResponse = response as! HTTPURLResponse
            let errorData:String = String.init(data: data, encoding: .utf8)!
            let errormsg:Error = NSError.init(domain: "错误数据字符串信息:\(errorData)\nhttp statusCode(错误代码):\(res.statusCode)", code: 0, userInfo: nil)
            self.repeatDownLoadImage(urlString: urlString, error: errormsg)
            return
        }
        
        //内存缓存
        self.webImageCache.setObject(image!, forKey: urlString as NSCopying)
        struct Count{
            static var count:Int = 0
        }
        Count.count += 1
        if Count.count == self.downCount {
            let lfPic:LFPicScrollView = delegate as! LFPicScrollView
            lfPic.ImageUpdate()
        }
        
        //沙盒缓存
        (data as NSData).write(toFile: self.cachePath.appendingPathComponent((urlString as NSString).lastPathComponent), atomically: true)
    }
    
    //重新下载
    func repeatDownLoadImage(urlString:String,error:Error?){
        let number:NSNumber = self.DownloadImageCount.object(forKey: urlString) as! NSNumber
        let count:NSInteger = number.boolValue ? (number.intValue) : 0
        if self.DownloadImageRepeatCount! > count {
            let newcount = count + 1
            let obj:NSNumber = NSNumber.init(value:newcount)
             self.DownloadImageCount.setObject(obj, forKey: urlString as NSCopying)
        }else{
            if (self.downLoadErrorBlock != nil) {
                 let errormsg:Error = NSError.init(domain: "错误数据字符串信息:\nhttp statusCode(错误代码):", code: 0, userInfo: nil)
                 self.downLoadErrorBlock!(errormsg as NSError,urlString as NSString)
            }
        }
    }
}
