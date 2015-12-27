//
//  ChartView.swift
//  CatchTheSpeed
//
//  Created by Iacopo Peri on 28/08/15.
//  Copyright (c) 2015 YeApp. All rights reserved.
//

import Foundation
import UIKit

class ChartView : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var chartElementArray : [ChartElement] = [ChartElement]()
    
    @IBOutlet weak var noResult: UILabel!
    @IBOutlet weak var chartTable: UITableView!
    
    @IBOutlet weak var personalChartElement: ChartCustomCell!
    
    internal func setElementPositionFromDimension(){
        self.personalChartElement.frame.size.width = self.view.frame.size.width - 10
        self.personalChartElement.frame.origin.x = 5
        self.personalChartElement.frame.origin.y = self.view.frame.size.height - self.personalChartElement.frame.size.height - 8
        
        self.chartTable.frame.size.width = self.view.frame.size.width
        
        self.chartTable.frame.size.height = self.view.frame.size.height - self.chartTable.frame.origin.y - self.personalChartElement.frame.size.height - 16
    }
    
    internal func resetCell(cell : ChartCustomCell){
        UtilityFunction.UIUtility.removeAllSubviews(cell.picture)
        cell.picture.image = nil
        cell.score.text = nil
        cell.level.text = nil
        cell.player.text = nil
        cell.mod.text = nil
        cell.chartPosition.text = nil
    }
    
    override func viewDidLoad() {
        setElementPositionFromDimension()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "risorse/backgrounds/sfondoMenu.jpg")!)
        
        UtilityFunction.UIUtility.showActivityIndicator(self.chartTable, tag: 20)
        UtilityFunction.UIUtility.showActivityIndicator(self.personalChartElement, tag: 30)
        
        self.personalChartElement.layer.borderColor = UIColor.orangeColor().CGColor
        self.personalChartElement.layer.borderWidth = 3
        self.personalChartElement.layer.cornerRadius = 10
        self.personalChartElement.layer.shadowColor = UIColor.yellowColor().CGColor
        self.personalChartElement.layer.shadowOffset = CGSize()
        self.personalChartElement.layer.shadowRadius = 10
        self.personalChartElement.layer.shadowOpacity = 1
        
        self.noResult.hidden=true
        
        resetCell(self.personalChartElement)
        
        if( ViewController.userLogged){
            var query = PFQuery(className: "Points")
            query.whereKey("user", equalTo: PFUser.currentUser()!)
                .orderByDescending("score")
                .includeKey("user")
                .findObjectsInBackgroundWithBlock({ (gameScore : [AnyObject]?, error: NSError?) -> Void in
                    if error != nil {
                        println(error?.localizedDescription)
                    }else if let infos = gameScore as? [PFObject]{
                        UtilityFunction.UIUtility.hideActivityIndicator(self.personalChartElement, tag: 30)
                        if(infos.count==0){
                            self.noResult.hidden=false
                        }else{
                            self.noResult.hidden=true
                            var infoQuery = infos[0]
                            let level = infoQuery["level"] as! String
                            let mod = ViewController.ModeGame(rawValue: infoQuery["game_type"] as! Int)
                            
                            var user = infoQuery["user"] as! PFUser
                            
                            UtilityFunction.UIUtility.showActivityIndicator(self.personalChartElement, tag: 2000)
                            
                            let profilePic = user["profilePicture"] as? PFFile
                            if let picture = profilePic {
                                picture.getDataInBackgroundWithBlock { (imageData:NSData?, error: NSError?) -> Void in
                                    UtilityFunction.UIUtility.hideActivityIndicator(self.personalChartElement.picture, tag: 2000)
                                    if error == nil {
                                        self.personalChartElement.picture.clipsToBounds = true
                                        self.personalChartElement.picture.layer.cornerRadius = 10
                                        self.personalChartElement.picture.image = UIImage(data: imageData!)
                                    }else{
                                        println("Cannot load image from web personale")
                                        self.personalChartElement.picture.image = UIImage(named: "risorse/general/face.jpeg")
                                    }
                                }
                            }
                            
                            self.personalChartElement.score.text = String(infoQuery["score"] as! Int)
                            self.personalChartElement.level.text = "Level: \(level)"
                            self.personalChartElement.player.text = user["name"] as? String
                            self.personalChartElement.mod.text = mod?.toString()
                        }
                    }
                })
        }else{
            self.personalChartElement.hidden=true
            self.chartTable.frame.size.height = self.view.frame.size.height - self.chartTable.frame.origin.y - 5
        }
        
        var query = PFQuery(className:"Points")
        query.limit = 10
        query.orderByDescending("score")
            .includeKey("user")
            .findObjectsInBackgroundWithBlock({ (gameScores: [AnyObject]?, error: NSError?) -> Void in
                if error != nil {
                    UtilityFunction.UIUtility.showAlertWithContent(self, title: "No connection available", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert, actions: [UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)], animated: true, completion: nil)
                    println(error)
                } else if let infos = gameScores as? [PFObject]{
                    UtilityFunction.UIUtility.hideActivityIndicator(self.chartTable, tag: 20)
                    for infoQuery in infos{
                        let score = infoQuery["score"] as! Int
                        let level = infoQuery["level"] as! String
                        let mod = ViewController.ModeGame(rawValue: infoQuery["game_type"] as! Int)
                        
                        var user = infoQuery["user"] as! PFUser
                        let name = user["name"] as! String
                        self.chartElementArray.append(ChartElement(id: user.objectId!, name: name, score: score, mod: mod!.toString(), level: level, chartPosition: self.chartElementArray.count+1))
                        self.chartTable.reloadData()
                    }
                }
            })
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chartElementArray.count
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView:UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        var reusableCell : ChartCustomCell? = tableView.dequeueReusableCellWithIdentifier("chartCell", forIndexPath: indexPath) as? ChartCustomCell
        if reusableCell==nil {
            reusableCell = ChartCustomCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "chartCell")
        }
        
        resetCell(reusableCell!)
        var element : ChartElement = self.chartElementArray[indexPath.row]
        reusableCell!.score.text = String(element.score)
        reusableCell!.level.text = "Level: \(element.level)"
        reusableCell!.player.text = element.name
        reusableCell!.mod.text = "\(String(element.mod))"
        reusableCell!.chartPosition.text = "\(String(element.chartPosition))˚"
        
        UtilityFunction.UIUtility.showActivityIndicator(reusableCell!.picture, tag: element.chartPosition+1000)
        var query = PFUser.query()
        query?.getObjectInBackgroundWithId(element.id, block: { (result: PFObject?, error: NSError?) -> Void in
            if error == nil{
                let profilePic = result!["profilePicture"] as? PFFile
                if let picture = profilePic {
                    picture.getDataInBackgroundWithBlock { (imageData:NSData?, error: NSError?) -> Void in
                        UtilityFunction.UIUtility.hideActivityIndicator(reusableCell!.picture, tag: element.chartPosition+1000)
                        
                        if error == nil {
                            reusableCell!.picture.clipsToBounds = true
                            reusableCell!.picture.layer.cornerRadius = 10
                            reusableCell!.picture.image = UIImage(data: imageData!)
                        }else{
                            println("Cannot load image from web")
                            reusableCell!.picture.image = UIImage(named: "risorse/general/face.jpeg")
                        }
                    }
                }else{
                    UtilityFunction.UIUtility.hideActivityIndicator(reusableCell!.picture, tag: element.chartPosition+1000)
                    reusableCell!.picture.image = UIImage(named: "risorse/general/face.jpeg")
                }
            }else{
                UtilityFunction.UIUtility.hideActivityIndicator(reusableCell!.picture, tag: element.chartPosition+1000)
                reusableCell!.picture.image = UIImage(named: "risorse/general/face.jpeg")
            }
        })
        return reusableCell!;
    }
    
}