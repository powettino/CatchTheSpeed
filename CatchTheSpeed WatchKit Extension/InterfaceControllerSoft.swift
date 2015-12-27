//
//  InterfaceController.swift
//  CatchTheSpeed WatchKit Extension
//
//  Created by Iacopo Peri on 30/09/15.
//  Copyright (c) 2015 YeApp. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceControllerSoft: WKInterfaceController {
    
    
    @IBOutlet weak var titleChart: WKInterfaceLabel!
    @IBOutlet weak var chart: WKInterfaceTable!
    
    @IBOutlet weak var noUser: WKInterfaceLabel!
    var infoArray : NSArray = []
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.getChart()
    }
    
    internal func getChart(){
        
        var params = ["game_type":InterfaceControllerGlobal.ModeGame.soft.rawValue]
        var error : NSError?
        var whereClause = (NSString(data: NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &error)!, encoding: NSUTF8StringEncoding))?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        var urlReq = Utility.prepareRestRequest("https://api.parse.com/1/classes/Points?order=-score&limit=10&include=user&where=\(whereClause!)")
        
        urlReq.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlReq.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let queue:NSOperationQueue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(urlReq, queue: queue, completionHandler:{ (response: NSURLResponse?, data: NSData?, error: NSError!) -> Void in
            if (error==nil){
                var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
                self.infoArray = jsonResult["results"] as! NSArray
                self.noUser.setHidden(true)
                self.chart.setHidden(false)
            }else{
                self.noUser.setHidden(false)
                self.chart.setHidden(true)
                println("\(error.localizedDescription)")
            }
        })
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        self.chart.setNumberOfRows(self.infoArray.count, withRowType: "ChartRowController")
        
        for (index, singleRes) in (self.infoArray).enumerate(){
            if let row = self.chart.rowControllerAtIndex(index) as? ChartRowController {
                let chartInfo : NSDictionary = singleRes as! NSDictionary
                let user : NSDictionary = (chartInfo["user"] as? NSDictionary)!
                let level : String = chartInfo["level"] as! String
                row.setInfo(String(index+1), playerName: user["name"] as! String, actualPoints: String(chartInfo["score"] as! Int), gameMod: "Level: \(level)")
            }
        }
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
