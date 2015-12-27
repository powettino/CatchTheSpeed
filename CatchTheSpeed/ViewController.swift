//
//  ViewController.swift
//  CatchTheSpeed
//
//  Created by Iacopo on 18/01/15.
//  Copyright (c) 2015 YeApp. All rights reserved.
//

import UIKit
import SpriteKit
import Social
import AVFoundation

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file as String, ofType: "sks") {
            let sceneData = try! NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let speedoScene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! Speedo
            archiver.finishDecoding()
            return speedoScene
        } else {
            return nil
        }
    }
}

class ViewController: UIViewController, ScoreDelegate, StartingActionDelegate, TimerDelegate, OptionMenuDelegate, PFLogInViewControllerDelegate, AVAudioPlayerDelegate{
    
    enum ModeGame : Int {
        case soft = 100
        case stressing = 50
        case survival = 200
        case astonishing = 500
        func toString() -> String{
            switch(self){
            case soft:
                return "Soft"
            case stressing:
                return "Stressing"
            case survival:
                return "Survival"
            case astonishing:
                return "Astonishing"
            }
        }
    }
    
    enum SlideScoreEnum : CGFloat {
        case top = -140
        case down = 0
    }
    
    var modGame : ModeGame = ModeGame.soft
    var level : Int = 1
    var counterMessageGame = 3
    var timerMessageGame = NSTimer()
    var currentPoint = 0
    var counterTimerMode = 60
    var optionOpened :Bool = false
    var speedoScene : Speedo?;
    var menu : MenuTable!
    static var userLogged : Bool = false;
    let read_permissions = [ "public_profile", "email"]
    let write_permissions = ["publish_actions"]
    let loadingBox: UIView = UIView()
    let loadingView: UIView = UIView()
    let loading: UIActivityIndicatorView! = UIActivityIndicatorView()
    var recordArray : [Int : Int] = [ModeGame.soft.rawValue: 0, ModeGame.stressing.rawValue:0, ModeGame.survival.rawValue:0, ModeGame.astonishing.rawValue:0]
    var startEngineAudio = AVAudioPlayer()
    var pointSetAudio = AVAudioPlayer()
    var failSetAudio = AVAudioPlayer()
    var soundTrackAudio = AVAudioPlayer()
    
    var audioStatus : Bool {
        get{
            let ud = NSUserDefaults.standardUserDefaults().boolForKey("audioStatus")
            return ud
        }
        set(value){
            NSUserDefaults.standardUserDefaults().setBool(value, forKey: "audioStatus")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var effectsStatus : Bool {
        get{
            let ud = NSUserDefaults.standardUserDefaults().boolForKey("effectsStatus")
            return ud
        }
        set(value){
            NSUserDefaults.standardUserDefaults().setBool(value, forKey: "effectsStatus")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var userMinimalInformation : String {
        get{
            let umi = NSUserDefaults.standardUserDefaults().stringForKey("userMinimalInformation")
            return umi!
        }
        set(value){
            NSUserDefaults.standardUserDefaults().setValue(value, forKey: "userMinimalInformation")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    @IBOutlet weak var copyLabelCount: UILabel!
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var labelCount: UILabel!
    @IBOutlet weak var fadingView: UIView!
    @IBOutlet weak var puntiAttuali: UILabel!
    @IBOutlet weak var nomePlayer: UILabel!
    @IBOutlet weak var opzioni: UIBarButtonItem!
    @IBOutlet weak var slidingMenu: UIView!
    @IBOutlet weak var acceleratorView: SKView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var windowInformations: UIView!
    @IBOutlet weak var pointText: UILabel!
    @IBOutlet weak var levelText: UILabel!
    @IBOutlet weak var currentLevel: UILabel!
    @IBOutlet weak var FBButton: UIButton!
    @IBOutlet weak var gameTitle: UILabel!
    @IBOutlet weak var borderInformationView: UIView!
    
    @IBOutlet weak var currentRecord: UILabel!
    @IBOutlet weak var recordText: UIView!
    
    @IBAction func playMod(sender: AnyObject) {
        self.startedGame()
    }
    
    @IBAction func FBButtonClick(sender: AnyObject) {
        UtilityFunction.UIUtility.showActivityIndicator(self.view, tag: 1)
        if(ViewController.userLogged){
            PFUser.logOutInBackgroundWithBlock({ (error: NSError?) -> Void in
                if(error==nil){
                    print("User logged out")
                    
                    UtilityFunction.UIUtility.showAlertWithContent(self, title: "Logout", message: "User has successfully logged out", preferredStyle: UIAlertControllerStyle.Alert, actions: [UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: (nil))], animated: true, completion: {finished in
                        self.FBButton.setTitle("Connect", forState: UIControlState.Normal)
                        ViewController.userLogged = false
                        self.userMinimalInformation = ""
                    })
                }else{
                    
                    UtilityFunction.UIUtility.showAlertWithContent(self, title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert, actions: [UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: (nil))], animated: true, completion: (nil))
                }
            })
        }else{
            PFFacebookUtils.logInInBackgroundWithPublishPermissions(self.write_permissions,  block: {  (user: PFUser?, error: NSError?) -> Void in
                if(error == nil){
                    if let _ = user {
                        UtilityFunction.UIUtility.showAlertWithContent(self, title: "Login", message: "User has successfully logged in", preferredStyle: UIAlertControllerStyle.Alert, actions: [UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: (nil))], animated: true, completion: {
                            finished in
                            self.FBButton.setTitle("Disconnect", forState: UIControlState.Normal)
                            ViewController.userLogged = true
                            self.retrieveFBInformation()
                            self.updateRecordArray()
                            self.userMinimalInformation = PFUser.currentUser()!.objectId!
                        })
                        
                    } else {
                        print("Uh oh. The user cancelled the Facebook connection.")
                        UtilityFunction.UIUtility.showAlertWithContent(self, title: "Error", message: "Login cancelled", preferredStyle: UIAlertControllerStyle.Alert, actions: [UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: (nil))], animated: true, completion: (nil))
                    }
                }else{
                    UtilityFunction.UIUtility.showAlertWithContent(self, title: "Error", message: error!.localizedDescription , preferredStyle: UIAlertControllerStyle.Alert, actions: [UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: (nil))], animated: true, completion: (nil))
                    
                }
            })
        }
        UtilityFunction.UIUtility.hideActivityIndicator(self.view, tag: 1)
    }
    
    @IBAction func optionClick(sender: AnyObject) {
        self.speedoScene?.pauseSpeedo(true);
        if(!self.optionOpened){
            let newFrame =  CGRectMake(self.slidingMenu.frame.origin.x, 0, self.slidingMenu.frame.size.width , self.slidingMenu.frame.size.height)
            UIView.animateWithDuration(0.3 , delay: 0, options: UIViewAnimationOptions.TransitionFlipFromTop, animations: {
                self.slidingMenu.frame = newFrame;
                } , completion:(nil))
            self.optionOpened=true
        }else{
            self.closeMenu()
        }
    }
    
    func retrieveFBInformation(){
        let requestFb = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, name, first_name, last_name, picture.type(large), email"], HTTPMethod: "GET")
        requestFb.startWithCompletionHandler({
            (connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
            if(error != nil){
                print("Error: \(error.localizedDescription)")
                ViewController.userLogged=false
                self.FBButton?.setTitle("Connect", forState: UIControlState.Normal)
                PFUser.logOutInBackground()
                print("Utente sloggato forzatamente")
                UtilityFunction.UIUtility.showAlertWithContent(self, title: "No connection available", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert, actions: [UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)], animated: true, completion: nil)
            }else{
                if let loginResult = result as? Dictionary<String, AnyObject>{
                    let name:String = loginResult["name"] as AnyObject? as! String
                    //                    let facebookID:String = loginResult["id"] as AnyObject? as! String
                    let email:String? = (loginResult["email"] as AnyObject? as? String)
                    
                    //                    let pictureURL = "https://graph.facebook.com/\(facebookID)/picture?type=large&return_ssl_resources=1"
                    print(loginResult)
                    
                    let pictureURL = (loginResult["picture"]?.objectForKey("data")?.objectForKey("url") as! String)
                    
                    let URLRequest = NSURL(string: pictureURL)
                    //                    var URLRequestNeeded = NSURLRequest(URL: URLRequest!)
                    
                    let user : PFUser = PFUser.currentUser()!
                    
                    if let data = NSData(contentsOfURL: URLRequest!){
                        let picture = PFFile(data: data)
                        user["profilePicture"] = picture
                        
                        user.saveInBackgroundWithBlock({(success: Bool, errorSave: NSError?) -> Void in
                            if success {
                                print("Immagine recuperata da FB salvata")
                            }else{
                                print(errorSave)
                            }
                        })
                    }
                    else {
                        print("Error: \(error.localizedDescription)")
                    }
                    
                    //                    NSURLConnection.sendAsynchronousRequest(URLRequestNeeded, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!, error: NSError!) -> Void in
                    //                        if error == nil {
                    //                            var picture = PFFile(data: data)
                    //                            user["profilePicture"] = picture
                    //
                    //                            user.saveInBackgroundWithBlock({(success: Bool, errorSave: NSError?) -> Void in
                    //                                if success {
                    //                                    print("Immagine recuperata da FB salvata")
                    //                                }else{
                    //                                    print(errorSave)
                    //                                }
                    //                            })
                    //                        }
                    //                        else {
                    //                            print("Error: \(error.localizedDescription)")
                    //                        }
                    //                    })
                    
                    user["name"] = name
                    if let emailValue = email{
                        user["email"] = emailValue
                    }
                    user.saveInBackground()
                    ViewController.userLogged = true;
                    self.FBButton?.setTitle("Disconnect", forState: UIControlState.Normal)
                    self.updateRecordArray()
                }
            }
        })
    }
    
    func changedSurvival(){
        NSLog("cambiato survvival");
        switch (self.modGame){
        case ModeGame.soft:
            self.modGame=ModeGame.survival
        case ModeGame.stressing:
            self.modGame = ModeGame.astonishing
        case ModeGame.survival:
            self.modGame=ModeGame.soft
        case ModeGame.astonishing:
            self.modGame = ModeGame.stressing
        }
    }
    
    func changedTimer() {
        //        NSLog("cambiato timer");
        switch (self.modGame){
        case ModeGame.soft:
            self.modGame=ModeGame.stressing
        case ModeGame.stressing:
            self.modGame = ModeGame.soft
        case ModeGame.survival:
            self.modGame=ModeGame.astonishing
        case ModeGame.astonishing:
            self.modGame = ModeGame.survival
        }
    }
    
    func changedSounds() {
        if(self.soundTrackAudio.playing){
            self.soundTrackAudio.stop()
            self.soundTrackAudio.currentTime = 0
        }else{
            self.soundTrackAudio.prepareToPlay()
            self.soundTrackAudio.play()
        }
        self.audioStatus = !self.audioStatus
        
    }
    
    func changedEffects() {
        self.effectsStatus = !self.effectsStatus
    }
    
    func closeMenu(){
        let currentFrame = CGRectMake(self.slidingMenu.frame.origin.x, self.slidingMenu.frame.origin.y-self.slidingMenu.frame.size.height, self.slidingMenu.frame.size.width, self.slidingMenu.frame.size.height)
        
        UIView.animateWithDuration(0.3,delay:0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: {
            self.slidingMenu.frame = currentFrame;
            }, completion:(nil))
        
        self.optionOpened = false
        if(self.changeModeView()){
            //            self.speedoScene?.resetSpeedo()
            self.restartGame()
        }
        self.speedoScene?.pauseSpeedo(false);
    }
    
    func restartGame(){
        self.speedoScene?.resetSpeedo();
        self.slideInformationView(SlideScoreEnum.down)
        self.timerMessageGame.invalidate()
        
        self.fadingView.alpha = 0
        self.fadingView.hidden = false
        self.labelText.alpha=0
        self.labelCount.alpha=0
        self.copyLabelCount.alpha=0
        self.acceleratorView.alpha=1
        self.level=1
        self.currentPoint=0
        self.puntiAttuali.text = String(self.currentPoint)
        self.currentLevel.text = String(self.level)
        self.counterTimerMode = 60
        self.counterMessageGame=3
    }
    
    private func changeModeView() -> Bool{
        var changed : Bool! = false;
        switch (self.modGame, self.playButton.titleLabel!.text!.substringFromIndex(self.playButton.titleLabel!.text!.startIndex.advancedBy(5))) {
        case (ModeGame.stressing, "Stressing"):
            break;
        case (ModeGame.soft, "Soft"):
            break;
        case (ModeGame.survival, "Survival"):
            break;
        case (ModeGame.astonishing, "Astonishing!!") :
            break;
        case (ModeGame.soft, _):
            NSLog("Cambio modalita in soft");
            self.labelText.text = "Congrats!"
            self.playButton.setTitle("Play Soft", forState: UIControlState.Normal)
            self.speedoScene?.enableTimer(false);
            changed=true;
        case (ModeGame.stressing, _):
            NSLog("Cambio modalita in stressing");
            self.playButton.setTitle("Play Stressing", forState: UIControlState.Normal)
            self.speedoScene?.enableTimer(true);
            changed=true;
        case (ModeGame.survival, _):
            NSLog("Cambio modalita in survival");
            self.playButton.setTitle("Play Survival", forState: UIControlState.Normal)
            self.speedoScene?.enableTimer(false);
            changed=true;
        case (ModeGame.astonishing, _) :
            NSLog("Cambio modalita in astonishing");
            self.playButton.setTitle("Play Astonishing", forState: UIControlState.Normal)
            self.speedoScene?.enableTimer(true);
            changed=true;
        }
        return changed;
    }
    
    private func checkUserStatus() -> Bool{
        var result : Bool = false;
        UtilityFunction.UIUtility.showActivityIndicator(self.view, tag: 2)
        self.userMinimalInformation = ""
        if let user = PFUser.currentUser(){
            if(PFFacebookUtils.isLinkedWithUser(user)){
                NSLog("Facebook logged")
                result = true;
            }
            NSLog("Parse logged")
            self.userMinimalInformation = PFUser.currentUser()!.objectId!
        }
        UtilityFunction.UIUtility.hideActivityIndicator(self.view, tag: 2)
        return result;
    }
    
    internal func updateRecordArray(){
        let query = PFQuery(className: "Points")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
            .findObjectsInBackgroundWithBlock { (punteggi:[AnyObject]?, error:NSError?) -> Void in
                if(error != nil){
                    print("Error: \(error?.localizedDescription)")
                    ViewController.userLogged = false
                    self.FBButton.setTitle("Connect", forState: UIControlState.Normal)
                    
                    UtilityFunction.UIUtility.showAlertWithContent(self, title: "Error", message: "Cannot retrieve information: \(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert, actions: [UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: (nil))], animated: true, completion: (nil))
                    
                }else if let punteggi = punteggi as? [PFObject]{
                    //                    println("trovati \(punteggi.count) record per questo user")
                    for punteggio in punteggi{
                        if let gameType = punteggio.objectForKey("game_type") as? Int{
                            self.recordArray[gameType] = punteggio.objectForKey("score") as? Int
                            //                            println("il punteggio per gioco \(gameType) impostato e' \(self.recordArray[gameType])")
                        }
                    }
                    self.currentRecord.text = String(self.recordArray[self.modGame.rawValue]!)
                }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        UtilityFunction.UIUtility.showActivityIndicator(self.view, tag: 3)
        if(checkUserStatus()){
            print("User is linked as view appear")
            self.retrieveFBInformation()
        }
        UtilityFunction.UIUtility.hideActivityIndicator(self.view, tag: 3)
        if(self.audioStatus){
            self.soundTrackAudio.prepareToPlay()
            self.soundTrackAudio.play()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //                for family in UIFont.familyNames(){
        //                    for fontname in UIFont.fontNamesForFamilyName(family as! String){
        //                        NSLog("\(fontname)")
        //                    }
        //                }
        
        setElementPositionFromDimension()
        
        self.loading.layer.zPosition=10
        
        self.speedoScene = Speedo(size: self.acceleratorView.bounds.size)
        self.speedoScene?.size = self.acceleratorView.bounds.size
        self.speedoScene?.scaleMode = SKSceneScaleMode.ResizeFill
        self.acceleratorView.presentScene(self.speedoScene!)
        self.speedoScene?.scoreDelegate = self;
        self.speedoScene?.startingActionDelegate = self;
        self.speedoScene?.timerDelegate = self;
        self.speedoScene?.enableTouchStartGame(true);
        
        self.fadingView.hidden=true
        
        self.labelText.alpha=0
        self.labelCount.alpha=0
        self.copyLabelCount.alpha=0
        
        self.slidingMenu.layer.cornerRadius=30
        self.slidingMenu.layer.borderColor=UIColor.orangeColor().CGColor
        self.slidingMenu.layer.borderWidth=1
        self.slidingMenu.layer.shadowColor = UIColor.redColor().CGColor
        self.slidingMenu.layer.shadowOffset = CGSize()
        self.slidingMenu.layer.shadowOpacity = 0.8
        self.slidingMenu.layer.shadowRadius=5.0
        
        self.container.layer.cornerRadius=30
        
        self.menu = self.container.subviews[0] as! MenuTable
        self.menu.layer.cornerRadius=30
        self.menu.menuDelegate = self
        self.menu.backgroundColor = UIColor.redColor()
        self.menu.backgroundColor = UIColor(patternImage: UIImage(named: "risorse/backgrounds/sfondoMenu.jpg")!)
        
        let deviceNumberType = UtilityFunction.IOSDeviceUtility.checkDevice(view)
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "risorse/backgrounds/sfondo\(deviceNumberType.rawValue).png")!)
        
        self.windowInformations.layer.cornerRadius = 15
        self.windowInformations.layer.borderColor = UIColor(patternImage: UIImage(named: "risorse/borders/texture_gialla.png")!).CGColor
        self.windowInformations.layer.borderWidth = 10
        self.windowInformations.backgroundColor = UIColor(white: 100, alpha: 0.2)
        self.windowInformations.layer.zPosition = 1
        //        self.windowInformations.layer.shadowColor = UIColor.redColor().CGColor
        //        self.windowInformations.layer.shadowOffset = CGSize()
        //        self.windowInformations.layer.shadowRadius = 5
        //        self.windowInformations.layer.shadowOpacity = 1
        
        
        self.borderInformationView.layer.borderColor = UIColor(patternImage: UIImage(named: "risorse/borders/texture1.png")!).CGColor
        self.borderInformationView.layer.cornerRadius = 15
        self.borderInformationView.layer.borderWidth = 10
        self.borderInformationView.backgroundColor = UIColor.clearColor()
        self.borderInformationView.layer.zPosition = 2
        
        UIView.animateWithDuration(5, delay: 0, options: [UIViewAnimationOptions.Autoreverse, UIViewAnimationOptions.Repeat, UIViewAnimationOptions.CurveEaseInOut], animations: {self.borderInformationView.alpha = 0.0}, completion: (nil))
        
        self.puntiAttuali.layer.borderColor = UIColor(patternImage: UIImage(named: "risorse/borders/texture_mini.png")!).CGColor
        self.puntiAttuali.layer.borderWidth = 3
        self.puntiAttuali.layer.cornerRadius = 10
        
        self.currentLevel.layer.borderColor = UIColor(patternImage: UIImage(named: "risorse/borders/texture_mini.png")!).CGColor
        self.currentLevel.layer.borderWidth = 3
        self.currentLevel.layer.cornerRadius = 10
        
        self.currentRecord.layer.borderColor = UIColor(patternImage: UIImage(named: "risorse/borders/texture_mini.png")!).CGColor
        self.currentRecord.layer.borderWidth = 3
        self.currentRecord.layer.cornerRadius = 10
        
        self.menu.setEffectsSwitch(self.effectsStatus)
        self.menu.setAudioSwitch(self.audioStatus)
        
        self.startEngineAudio = UtilityFunction.Audio.setupAudioPlayerWithFile("risorse/audio/start_car_cut", type: "wav")
        self.startEngineAudio.delegate = self
        
        self.pointSetAudio = UtilityFunction.Audio.setupAudioPlayerWithFile("risorse/audio/check", type: "mp3")
        
        self.failSetAudio = UtilityFunction.Audio.setupAudioPlayerWithFile("risorse/audio/wrong", type: "mp3")
        
        self.soundTrackAudio = UtilityFunction.Audio.setupAudioPlayerWithFile("risorse/audio/soundtrack", type: "mp3")
        self.soundTrackAudio.numberOfLoops = -1
        self.soundTrackAudio.volume = 0.7
        
    }
    
    func audioPlayerDidFinishPlaying(successfully: Bool) {
        //        println("chiamo handler audio");
        switch(self.modGame){
        case ModeGame.soft:
            self.counterMessageGame=3
            self.speedoScene?.setNeedleSpeed(Needle.NeedleSpeed.low)
            self.speedoScene?.enableFailDelegate(true);
        case ModeGame.stressing:
            self.speedoScene?.setNeedleSpeed(Needle.NeedleSpeed.medium)
            self.speedoScene?.enableFailDelegate(false);
        case ModeGame.survival:
            self.speedoScene?.setNeedleSpeed(Needle.NeedleSpeed.fast)
            self.speedoScene?.enableFailDelegate(true);
        case ModeGame.astonishing:
            self.speedoScene?.setNeedleSpeed(Needle.NeedleSpeed.fastest)
            self.speedoScene?.enableFailDelegate(false);
        }
        
        self.speedoScene?.startSpeedo()
    }
    
    private func slideInformationView(position : SlideScoreEnum){
        if(position.rawValue != self.informationView.frame.origin.y){
            let slidingFrame = CGRectMake(self.informationView.frame.origin.x, position.rawValue, self.informationView.frame.size.width, self.informationView.frame.size.height)
            
            let pointSlide = CGRectMake(position.rawValue != 0 ? self.view.frame.size.width-self.puntiAttuali.frame.size.width+10 : self.view.frame.size.width+10, self.puntiAttuali.frame.origin.y, self.puntiAttuali.frame.size.width, self.puntiAttuali.frame.size.height);
            
            let levelSlide = CGRectMake(position.rawValue != 0 ? self.view.frame.size.width-self.currentLevel.frame.size.width+10 : self.view.frame.size.width+10, self.currentLevel.frame.origin.y, self.currentLevel.frame.size.width, self.currentLevel.frame.size.height);
            
            let recordSlide = CGRectMake(position.rawValue != 0 ? -10 : -self.currentRecord.frame.size.width-20, self.currentRecord.frame.origin.y, self.currentRecord.frame.size.width, self.currentRecord.frame.size.height)
            
            UIView.animateWithDuration(0.5 ,delay: position.rawValue != 0 ? 0 : 0.3, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.informationView.frame = slidingFrame;
                }, completion:(nil))
            
            UIView.animateWithDuration(0.5, delay: position.rawValue != 0 ? 0.2 : 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: {self.currentLevel.frame = levelSlide
                }, completion: (nil))
            
            UIView.animateWithDuration(0.5, delay: position.rawValue != 0 ? 0.2 : 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: {self.puntiAttuali.frame = pointSlide
                }, completion: (nil))
            
            UIView.animateWithDuration(0.5, delay: position.rawValue != 0 ? 0.2 : 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: {self.currentRecord.frame = recordSlide
                }, completion: (nil))
        }
    }
    
    private func setElementPositionFromDimension(){
        
        var offset : CGFloat;
        var borderOffset : CGFloat;
        switch (UtilityFunction.IOSDeviceUtility.checkDevice(self.view)){
        case UtilityFunction.IOSDeviceUtility.IOSDeviceType.iPhone5:
            offset=45
            borderOffset=5
        case UtilityFunction.IOSDeviceUtility.IOSDeviceType.iPhone6:
            offset=55
            borderOffset=7
        case UtilityFunction.IOSDeviceUtility.IOSDeviceType.iPhone6Plus:
            offset=75
            borderOffset=7
        default:
            offset=0
            borderOffset=5
        }
        
        self.acceleratorView.frame.size.width = self.view.frame.width
        self.acceleratorView.frame.size.height = self.view.frame.width
        self.acceleratorView.frame.origin.x = 0
        
        self.acceleratorView.frame.origin.y = (self.view.frame.height -
            self.acceleratorView.frame.size.height - offset)
        self.acceleratorView.layer.zPosition = 2
        self.fadingView.layer.zPosition = 2
        
        self.fadingView.frame.origin.x = (self.view.frame.size.width-self.fadingView.frame.size.width) / 2
        self.fadingView.frame.origin.y = self.acceleratorView.frame.origin.y + 30
        
        self.slidingMenu.frame = CGRectMake((self.view.frame.size.width-self.container.frame.size.width)/2, -self.slidingMenu.frame.size.height, self.slidingMenu.frame.size.width, self.slidingMenu.frame.size.height)
        self.slidingMenu.layer.zPosition = 10
        
        self.windowInformations.frame = CGRectMake(borderOffset, self.windowInformations.frame.origin.y+5, self.view.frame.size.width-(borderOffset*2), self.windowInformations.frame.size.height)
        
        self.borderInformationView.frame = CGRectMake(borderOffset, self.borderInformationView.frame.origin.y+5, self.view.frame.size.width-(borderOffset*2), self.borderInformationView.frame.size.height)
        
        self.informationView.frame.size.width = self.view.frame.size.width-10
        
        self.currentLevel.frame.origin.x = self.view.frame.size.width + 10
        self.currentLevel.frame.size.width = self.view.frame.size.width/2 - 15
        
        self.levelText.frame.origin.x = (self.view.frame.size.width/2 - 15) + 45
        
        self.puntiAttuali.frame.origin.x = self.view.frame.size.width + 10
        self.puntiAttuali.frame.size.width = self.view.frame.size.width/2 - 15
        
        self.pointText.frame.origin.x = (self.view.frame.size.width/2 - 15) + 45
        
        self.currentRecord.frame.origin.x = -self.currentRecord.frame.size.width - 10
        self.currentRecord.frame.size.width = self.view.frame.size.width/2 - 15
        
        self.recordText.frame.origin.x = (self.view.frame.size.width/2 - 15) - self.recordText.frame.size.width - 30
        
        self.gameTitle.frame.origin.x = ((self.view.frame.size.width - 10) - self.gameTitle.frame.size.width) / 2
        self.playButton.frame.origin.x = (self.view.frame.size.width - self.playButton.frame.size.width) / 2
        
        self.FBButton.frame.size.width = 220
        self.FBButton.frame.size.height = 40
        self.FBButton.setBackgroundImage(UIImage(named: "risorse/buttons/fb_s.png"), forState: UIControlState.Normal)
        self.FBButton.setBackgroundImage(UIImage(named: "risorse/buttons/fb_s_pressed.png"), forState: UIControlState.Selected)
        
        self.FBButton.frame.origin = CGPoint(x: ((self.view.frame.size.width-self.FBButton.frame.size.width)/2), y: self.view.frame.size.height - self.FBButton.frame.size.height - 10)
        self.FBButton.layer.zPosition = 3
    }
    
    func saveRecordOnline(){
        let query = PFQuery(className:"Points")
        let tempRecord = self.currentPoint
        let tempLevel = self.currentLevel.text
        let tempGame = self.modGame.rawValue
        query.whereKey("user", equalTo: PFUser.currentUser()!)
            .whereKey("game_type", equalTo: tempGame)
            .findObjectsInBackgroundWithBlock({ (gameScores: [AnyObject]?, error: NSError?) -> Void in
                if error != nil {
                    ViewController.userLogged = false
                    print("Error: \(error!.localizedDescription)")
                    UtilityFunction.UIUtility.showAlertWithContent(self, title: "Error", message: "Cannot save data: \(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert, actions: [UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: (nil))], animated: true, completion: (nil))
                    
                } else if let punteggi = gameScores as? [PFObject]{
                    //si aggiorna
                    if(punteggi.count==0){
                        print("entrato")
                        let punteggio = PFObject(className:"Points")
                        punteggio["score"] = tempRecord
                        punteggio["user"] = PFUser.currentUser()!
                        punteggio["level"] = tempLevel
                        punteggio["game_type"] = tempGame
                        punteggio.saveInBackgroundWithBlock({ (result:Bool, error:NSError?) -> Void in
                            if(result){
                                print("Record salvato nuovo \(tempRecord)")
                            }else{
                                print("Error: \(error!.localizedDescription)")
                                
                                UtilityFunction.UIUtility.showAlertWithContent(self, title: "Error", message: "Cannot save data: \(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert, actions: [UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: (nil))], animated: true, completion: (nil))
                            }
                        })
                    }else{
                        for punteggio in punteggi{
                            //dovrebbe essere solo 1 per modalita' di gioco
                            punteggio["score"] = tempRecord
                            punteggio["level"] = tempLevel
                            punteggio.saveInBackgroundWithBlock({ (result:Bool, error:NSError?) -> Void in
                                if(result){
                                    print("Record aggiornato \(tempRecord)")
                                }else{
                                    print("Error: \(error!.localizedDescription)")
                                    
                                    UtilityFunction.UIUtility.showAlertWithContent(self, title: "Error", message: "Cannot save data: \(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert, actions: [UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: (nil))], animated: true, completion: (nil))
                                }
                            })
                        }
                    }
                }
            })
    }
    
    func endGame(){
        //        NSLog("record: \(self.recordArray[self.modGame.rawValue]) - current: \(self.currentPoint)")
        if(self.effectsStatus){
            if(self.failSetAudio.playing){
                self.failSetAudio.stop()
            }
            self.failSetAudio.play()
        }
        switch(self.recordArray[self.modGame.rawValue]<self.currentPoint, self.modGame){
        case (true, _) :
            self.recordArray[self.modGame.rawValue] = self.currentPoint
            self.currentRecord.text = String(self.currentPoint)
            if(self.checkUserStatus()){
                self.saveRecordOnline()
            }
            self.showEndAlert("Congrats", message: "You have done a new record!", action: "Improve it!", enableShare: true)
        case (_, ModeGame.stressing):
            self.showEndAlert("Ouch!", message: "Your time is up!", action: "Try again", enableShare: false)
        case (_, ModeGame.soft):
            self.showEndAlert("OH NO!!!", message: "Omg, you have lost! LOSER!", action: "Sadness :(",enableShare: false)
        case (_, ModeGame.survival):
            self.showEndAlert("Nice try", message: "You will reborn...again...", action: "Let me live",enableShare: false)
        case (_, ModeGame.astonishing):
            self.showEndAlert("Nothing to blame", message: "It still hard for you", action: "I'm not giving up",enableShare: false)
        }
    }
    
    private func postOnFacebook(message : String, image : UIImage?){
        let data : NSData = UIImagePNGRepresentation(image!)!
        let post = FBSDKGraphRequest(graphPath: "/me/photos", parameters: [
            "caption":message, "source":data], HTTPMethod: "POST" );
        
        UtilityFunction.UIUtility.showActivityIndicator(self.view, tag: 4)
        post.startWithCompletionHandler({
            (connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
            UtilityFunction.UIUtility.hideActivityIndicator(self.view, tag: 4)
            if(error != nil){
                print(error)
                UtilityFunction.UIUtility.showAlertWithContent(self, title: "Error", message: "Operation failed", preferredStyle: UIAlertControllerStyle.Alert, actions: [UIAlertAction(title: "Sorry", style: UIAlertActionStyle.Default, handler: (nil))], animated: true, completion: {
                    finished in
                    self.restartGame()
                })
            }else{
                print(result)
                let postCompleted = UIAlertController(title: "Done", message: "Well done, you have shared your results on Facebook", preferredStyle: UIAlertControllerStyle.Alert)
                postCompleted.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: (nil)))
                self.presentViewController(postCompleted, animated: true, completion: {
                    finished in
                    self.restartGame()
                })
                
                UtilityFunction.UIUtility.showAlertWithContent(self, title: "Done", message: "Well done, you have shared your results on Facebook", preferredStyle: UIAlertControllerStyle.Alert, actions: [UIAlertAction(title: "Sorry", style: UIAlertActionStyle.Default, handler: (nil))], animated: true, completion: {
                    finished in
                    self.restartGame()
                })
            }
        })
    }
    
    func showEndAlert(title : String, message : String, action: String, enableShare: Bool){
        
        var actions : [UIAlertAction] = []
        
        if(enableShare){
            let actionShare = UIAlertAction(title: "Share", style: UIAlertActionStyle.Default, handler:{
                finished in
                let message : String = "I have just score \(self.recordArray[self.modGame.rawValue]!) points at level \(self.level) on Catch The Speed playing \"\(self.modGame.toString()) mode\"!!\n Do you think you can beat me?";
                
                let postImage = UtilityFunction.Imaging.takeScreenShot(self.view, cropRect: CGRect(origin: self.windowInformations.frame.origin, size: self.windowInformations.frame.size))
                
                if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
                    //                    if ViewController.userLogged{
                    //                        self.saveRecordOnline()
                    //                    }
                    let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                    facebookSheet.setInitialText(message)
                    facebookSheet.addImage(postImage)
                    self.presentViewController(facebookSheet, animated: true, completion: {
                        finished in
                        self.restartGame()
                    })
                } else {
                    if(self.checkUserStatus()){
                        //                        self.saveRecordOnline()
                        self.postOnFacebook(message, image: postImage)
                    }else{
                        
                        let actionYes = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler:{
                            finished in
                            PFFacebookUtils.logInInBackgroundWithPublishPermissions(self.write_permissions,  block: {  (user: PFUser?, error: NSError?) -> Void in
                                if(error == nil){
                                    if let _ = user {
                                        self.FBButton.setTitle("Disconnect", forState: UIControlState.Normal)
                                        ViewController.userLogged = true
                                        self.updateRecordArray()
                                        //Si ripete l'operazione perche' non si era loggati
                                        if(self.recordArray[self.modGame.rawValue]<self.currentPoint){
                                            self.recordArray[self.modGame.rawValue]=self.currentPoint
                                            self.saveRecordOnline()
                                            self.postOnFacebook(message, image:postImage)
                                        }else{
                                            UtilityFunction.UIUtility.showAlertWithContent(self, title: "Sorry", message: "You weren't logged in, your result isn't the best. Try a new shot!", preferredStyle: UIAlertControllerStyle.Alert, actions: [UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: (nil))], animated: true, completion:{
                                                finished in
                                                self.restartGame()
                                            })
                                        }
                                    } else {
                                        print("Uh oh. The user cancelled the Facebook connection.")
                                        UtilityFunction.UIUtility.showAlertWithContent(self, title: "Error", message: "Login cancelled", preferredStyle: UIAlertControllerStyle.Alert, actions: [UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: (nil))], animated: true, completion:{
                                            finished in
                                            self.restartGame()
                                        })
                                    }
                                }else{
                                    UtilityFunction.UIUtility.showAlertWithContent(self, title: "Error", message: error!.localizedDescription , preferredStyle: UIAlertControllerStyle.Alert, actions: [UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: (nil))], animated: true, completion: {
                                        finished in
                                        self.restartGame()
                                    })
                                }
                            })
                        })
                        let actionNo = UIAlertAction(title:"No", style:UIAlertActionStyle.Cancel, handler:{
                            finished in
                            UtilityFunction.UIUtility.showAlertWithContent(self, title: "Sorry", message: "You cannot share points without performing login action", preferredStyle: UIAlertControllerStyle.Alert, actions: [UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: (nil))], animated: true, completion: {finished in
                                self.restartGame()
                            })
                        })
                        
                        UtilityFunction.UIUtility.showAlertWithContent(self, title: "Perform Connect", message: "Do you want to connect with facebook?", preferredStyle: UIAlertControllerStyle.ActionSheet, actions: [actionYes, actionNo], animated: true, completion: (nil))
                    }
                }
            })
            actions.append(actionShare)
        }
        let actionNoShare = UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler:{
            finished in
            self.restartGame()
        })
        actions.append(actionNoShare)
        
        UtilityFunction.UIUtility.showAlertWithContent(self, title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert, actions: actions, animated: true, completion: (nil))
    }
    
    func messageGame(){
        if(self.counterMessageGame == 1){
            self.timerMessageGame.invalidate()
            UIView.animateWithDuration(0.2, animations: {
                self.fadingView.alpha = 0
                self.fadingView.hidden = false
                self.labelText.alpha=0
                self.labelCount.alpha=0
                self.copyLabelCount.alpha=0
                self.acceleratorView.alpha=1
                }, completion: {
                    finished in
                    self.labelCount.frame = CGRectMake((self.fadingView.frame.size.width - self.labelCount.frame.size.width)/2, self.labelCount.frame.origin.y, self.labelCount.frame.size.width, self.labelCount.frame.size.height);
                    self.copyLabelCount.frame = CGRectMake((self.fadingView.frame.size.width - self.labelCount.frame.size.width)/2, self.copyLabelCount.frame.origin.y, self.copyLabelCount.frame.size.width, self.copyLabelCount.frame.size.height);
                    
                    self.counterMessageGame=3
                    self.labelCount.text = String(self.counterMessageGame)
                    self.copyLabelCount.text = String(self.counterMessageGame)
                    self.speedoScene?.setLevel(self.level);
                    if(!self.optionOpened){
                        self.speedoScene?.pauseSpeedo(false);
                    }
                    self.speedoScene?.updateCollisionSection(nil);
                }
            )
        }else{
            self.counterMessageGame -= 1
            let middleFrame = CGRectMake((self.fadingView.frame.width - self.labelCount.frame.width)/2, self.labelCount.frame.origin.y, self.labelCount.frame.width, self.labelCount.frame.height);
            
            UtilityFunction.Animation.animateHorizontalElementOnMiddleBreak(self.view, toAnimate: self.labelCount, middlePosition: middleFrame, completeDuration: self.timerMessageGame.timeInterval, complex: ((self.counterMessageGame==2) ? "left" : "right"), finalComplention: nil);
            
            UtilityFunction.Animation.animateHorizontalElementOnMiddleBreak(self.view, toAnimate: self.copyLabelCount, middlePosition: middleFrame, completeDuration: self.timerMessageGame.timeInterval,complex: ((self.counterMessageGame==1) ? "left" : "right"), finalComplention: nil);
            
            self.labelCount.text = String(self.counterMessageGame)
            self.copyLabelCount.text = String(self.counterMessageGame)
        }
    }
    
    func checkTimeToSpeedUp(){
        //TODO: per disattivare opzione di accelerazione dopo la sezione minima
        if(self.speedoScene?.isMinimunSectionDimension() == true){
            if(self.level >= 5){
                let increasing : CGFloat = CGFloat(self.level) / 25.0
                self.speedoScene?.increaseSpeedTo(increasing);
                if((self.level % 5) == 0){
                    self.speedoScene?.animateText(nil)
                }
            }
        }
    }
    
    func timerEnded(){
        self.endGame()
        self.speedoScene?.stopSpeedo();
    }
    
    func startedGame() {
        self.currentRecord.text = String(self.recordArray[self.modGame.rawValue]!)
        self.slideInformationView(SlideScoreEnum.top);
        if(self.effectsStatus){
            self.startEngineAudio.play()
        }else{
            
            self.audioPlayerDidFinishPlaying(true)
        }
    }
    
    func setFail(){
        switch self.modGame{
        case ModeGame.soft:
            self.speedoScene?.stopSpeedo();
            self.endGame();
        case ModeGame.survival:
            self.speedoScene?.stopSpeedo();
            self.endGame()
        default:
            break;
        }
    }
    
    func setPoint(){
        if(self.effectsStatus){
            if(self.pointSetAudio.playing){
                self.pointSetAudio.stop()
            }
            self.pointSetAudio.play()
        }
        self.currentPoint += self.modGame.rawValue
        self.level++
        self.puntiAttuali.text = String(self.currentPoint)
        self.currentLevel.text = String(self.level)
        switch self.modGame {
        case ModeGame.stressing, ModeGame.astonishing, ModeGame.survival:
            self.speedoScene?.updateCollisionSection(self.level);
            self.checkTimeToSpeedUp()
        case ModeGame.soft:
            self.speedoScene?.pauseSpeedo(true);
            let origFrame = self.fadingView.frame
            self.fadingView.frame = CGRectMake(origFrame.origin.x, origFrame.origin.y, origFrame.width, 0)
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.fadingView.frame = origFrame
                self.fadingView.alpha = 1
                self.fadingView.hidden = false
                self.acceleratorView.alpha = 0.4
                self.labelText.alpha=1
                }, completion: { finished in
                    self.labelCount.alpha=1;
                    self.copyLabelCount.alpha=1;
                    let duration : NSTimeInterval = 0.8;
                    
                    UtilityFunction.Animation.animateHorizontalElementOnMiddleBreak(self.view, toAnimate: self.labelCount, middlePosition: self.labelCount.frame, completeDuration: duration, complex: "right", finalComplention: nil);
                    
                    UtilityFunction.Animation.animateHorizontalElementOnMiddleBreak(self.view, toAnimate: self.copyLabelCount, middlePosition: self.copyLabelCount.frame, completeDuration: duration, complex: "left", finalComplention: nil);
                    
                    self.timerMessageGame = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: Selector("messageGame"), userInfo: nil, repeats: true)
                }
            )
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false;
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
}