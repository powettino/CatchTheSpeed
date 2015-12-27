//
//  InterfacePersonalDetail.swift
//  CatchTheSpeed
//
//  Created by Iacopo Peri on 04/10/15.
//  Copyright (c) 2015 YeApp. All rights reserved.
//

import Foundation
import WatchKit
import WatchConnectivity

class InterfacePersonalDetail: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet weak var group1: WKInterfaceGroup!
    
    @IBOutlet weak var infoTable: WKInterfaceTable!
    @IBOutlet weak var noUser: WKInterfaceLabel!
    @IBOutlet weak var name: WKInterfaceLabel!
    @IBOutlet weak var personalImage: WKInterfaceImage!
    
    var infoArray : NSArray = []
    
    var session = WCSession();
    
    override func awakeWithContext(context: AnyObject?) {
        self.noUser.setText("No user logged")
        self.group1.setCornerRadius(10)
        
        session.sendMessage(message: ["request": "refreshData"], replyHandler: {
            (replyInfo, error) -> Void in
            let result = replyInfo["userId"] as? String
            self.switchView(true)
            if let userId : String = result {
                if (!userId.isEmpty){
                    self.switchView(false)
                    self.getUserChart(userId)
                }
            }}, errorHandler: nil)
            
        WKInterfaceController.openParentApplication(["request": "refreshData"],
            reply: { (replyInfo, error) -> Void in
                let result = replyInfo["userId"] as? String
                self.switchView(true)
                if let userId : String = result {
                    if (!userId.isEmpty){
                        self.switchView(false)
                        self.getUserChart(userId)
                    }
                }
        })
    }
    
    internal func switchView(noId : Bool){
        self.noUser.setHidden(!noId)
        self.group1.setHidden(noId)
        self.infoTable.setHidden(noId)
    }
    
    internal func getUserChart(userId : String){
        
        print("userid: \(userId)")
        var urlReq = Utility.prepareRestRequest("https://api.parse.com/1/users/\(userId)")
        
        let queue:NSOperationQueue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(urlReq, queue: queue, completionHandler:{ (response: NSURLResponse?, data: NSData?, error: NSError!) -> Void in
            if(error==nil){
                var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
                self.name.setText((jsonResult["name"] as! String))
                var infoPicture = jsonResult["profilePicture"] as? NSDictionary
                if let info = infoPicture{
                    var picReq : NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: (info["url"] as! String))!)
                    let queuePic:NSOperationQueue = NSOperationQueue()
                    NSURLConnection.sendAsynchronousRequest(picReq, queue: queuePic, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                        if data != nil {
                            let image = UIImage(data: data)
                            self.personalImage.setImage(image)
                        }
                    })
                }else{
                    self.personalImage.setImageNamed("face.jpeg")
                }
            }else{
                self.noUser.setText("No connection available")
                print("adadad")
                self.switchView(true)
            }
            
        })
        
        var params = ["user":["__type":"Pointer", "className":"_User", "objectId":"\(userId)"]]
        var error : NSError?
        var whereClause = (NSString(data: NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &error)!, encoding: NSUTF8StringEncoding))?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        urlReq = Utility.prepareRestRequest("https://api.parse.com/1/classes/Points?order=gameType&where=\(whereClause!)")
        
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>=nil
        var errReq: NSError?
        var dataVal: NSData? =  NSURLConnection.sendSynchronousRequest(urlReq, returningResponse: response, error:&errReq)
        if (errReq == nil){
            var err: NSError?
            var jsonResult: NSDictionary = (NSJSONSerialization.JSONObjectWithData(dataVal!, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary)!
            
            self.infoArray = jsonResult["results"] as! NSArray
            self.infoTable.setNumberOfRows(self.infoArray.count, withRowType: "PersonalRowController")
            for (index, singleRes) in (self.infoArray).enumerate(){
                if let row = self.infoTable.rowControllerAtIndex(index) as? PersonalRowController {
                    var chartInfo : NSDictionary = singleRes as! NSDictionary
                    row.setInfo(String(chartInfo["score"] as! Int), gameMod: InterfaceControllerGlobal.ModeGame(rawValue: (chartInfo["game_type"] as! Int))!.toString(), level: chartInfo["level"] as! String)
                }
            }
        }else{
            self.noUser.setText("No connection available")
            self.switchView(true)
        }
    }
    
    
    override func willActivate() {
        super.willActivate()
        if (WCSession.isSupported()){
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }
    override func didDeactivate() {
        super.didDeactivate()
    }
}