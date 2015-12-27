//
//  utility.swift
//  CatchTheSpeed
//
//  Created by Iacopo Peri on 19/06/15.
//  Copyright (c) 2015 YeApp. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import AVFoundation

class UtilityFunction{
    
    class SpriteKitUtility {
        static func removeNodeFromParentWithName(parent: SKNode , nodeName : String){
            parent.enumerateChildNodesWithName(nodeName) {
                node, stop in
                node.removeFromParent();
            }
        }
        static func removeNodesFromParentWIthNames(parent: SKNode , nodesName : [String]){
            for name in nodesName{
                removeNodeFromParentWithName(parent, nodeName: name)
            }
        }
    }
    
    class IOSDeviceUtility {
        
        private static let iPhone5Bound : (CGFloat, CGFloat) = (320.0, 568.0)
        //        private static let iPhone5SBound : (CGFloat, CGFloat) = (320.0, 568.0)
        private static let iPhone6Bound : (CGFloat, CGFloat)  = (375.0, 667.0)
        private static let iPhone6PlusBound : (CGFloat, CGFloat)  = (414.0, 736.0)
        
        enum IOSDeviceType : String {
            case unknown = "unknown"
            case iPhone5 = "5"
            //            case iPhone5S = "5s"
            case iPhone6 = "6"
            case iPhone6Plus = "6+"
            
            static let allValues = [unknown, iPhone5, iPhone6, iPhone6Plus]
        }
        
        static func IOSDeviceDimension(device: IOSDeviceType) -> (w:CGFloat, h:CGFloat)?{
            switch device{
            case .iPhone5:
                return iPhone5Bound
                //            case .iPhone5S:
                //                return iPhone5SBound
            case .iPhone6:
                return iPhone6Bound
            case .iPhone6Plus:
                return iPhone6PlusBound
            default:
                return nil;
            }
        }
        
        static func checkDevice(bounds:(CGFloat, CGFloat)) -> IOSDeviceUtility.IOSDeviceType{
            for device in IOSDeviceType.allValues{
                if let dev = IOSDeviceDimension(device){
                    if(UtilityFunction.Coding.compare(bounds, tuple2: dev)){
                        return device
                    }
                }
            }
            return IOSDeviceType.unknown
        }
        
        static func checkDevice(view: UIView) -> IOSDeviceUtility.IOSDeviceType{
            for device in IOSDeviceType.allValues{
                if let dev = IOSDeviceDimension(device){
                    if(UtilityFunction.Coding.compare((view.frame.width, view.frame.height), tuple2: dev)){
                        return device
                    }
                }
            }
            return IOSDeviceType.unknown
        }
    }
    class Coding{
        static func compare <T:Equatable> (tuple1:(T,T),tuple2:(T,T)) -> Bool
        {
            return (tuple1.0 == tuple2.0) && (tuple1.1 == tuple2.1)
        }
    }
    
    class UIUtility{
        
        static var loadingArray = [Int : UIView]()
        
        static func showAlertWithContent(presenterView: UIViewController, title: String, message: String, preferredStyle: UIAlertControllerStyle, actions:[UIAlertAction], animated: Bool, completion: (() -> Void)?){
            let genericAlert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
            for action in actions{
                genericAlert.addAction(action)
            }
            presenterView.presentViewController(genericAlert, animated:animated, completion: completion)
        }
        
        static func showActivityIndicator(view: UIView, tag:Int) {
            if loadingArray.indexForKey(tag) != nil{
                UtilityFunction.UIUtility.hideActivityIndicator(view, tag: tag)
            }
            let loadingBox: UIView = UIView()
            let loading: UIActivityIndicatorView! = UIActivityIndicatorView()
            //
            //                view.layer.borderColor = UIColor.redColor().CGColor
            //                view.layer.borderWidth = 3
            loadingBox.frame = CGRectMake(0, 0, view.frame.size.width < 80 ? view.frame.size.width : 80.0, view.frame.size.height < 80 ? view.frame.size.height : 80.0 )
            
            loadingBox.frame.origin.x = (view.frame.size.width - loadingBox.frame.size.width)/2
            loadingBox.frame.origin.y = (view.frame.size.height - loadingBox.frame.size.height)/2
            
//            println("view: \(view.frame.size.width) loa: \(loadingBox.frame.size.width) ori: \(loadingBox.frame.origin.x)")
            loadingBox.backgroundColor = UIColor(red: 0.26, green: 0.26 , blue: 0.26, alpha: 0.7)
            loadingBox.clipsToBounds = true
            loadingBox.layer.cornerRadius = 10
            loadingBox.tag = tag
            loadingBox.layer.zPosition = 50
            
            loading.frame = CGRectMake(0.0, 0.0, loadingBox.frame.size.width / 2, loadingBox.frame.size.height / 2);
            loading.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
            loading.center = CGPointMake(loadingBox.frame.size.width / 2, loadingBox.frame.size.height / 2);
            
            loadingBox.addSubview(loading)
            
//            println("aggiunto spinner con id \(tag)")
            loadingArray.updateValue(loadingBox, forKey: tag)
            view.addSubview(loadingBox)
            
            loading.startAnimating()
        }
        
        static func hideActivityIndicator(view: UIView, tag: Int) {
//            println("rimossso spinner con id \(tag)")
            let loadingBox = loadingArray.removeValueForKey(tag)
            loadingBox?.removeFromSuperview()
        }
        
        static func removeAllSubviews(view: UIView){
            for sub in view.subviews{
                sub.removeFromSuperview()
            }
//            view.subviews.map({$0.removeFromSuperview()})
        }
    }
    
    class Math{
        static func degreesToRadiant(angle : Double) -> CGFloat{
            return CGFloat(angle * (M_PI / 180));
        }
        
        static func radiansToDegrees (value:CGFloat) -> Double {
            return Double((value * 180)) / M_PI;
        }
        
        static func findXY(radius : CGFloat, centerX : CGFloat, centerY:CGFloat, angle:CGFloat) -> (x: CGFloat, y: CGFloat){
            let puntoX = centerX + (radius * cos(angle))
            let puntoY = centerY + (radius * sin(angle))
            return ( puntoX, puntoY)
        }
        
        static func randomDouble(min : Double , max : Double) -> Double{
            return (Double(arc4random())) / Double(UINT32_MAX) * (max-min) + min
        }
    }
    
    class Animation{
        static func animateHorizontalElementOnMiddleBreak(containerView: UIView, toAnimate : UIView, middlePosition : CGRect, completeDuration: NSTimeInterval, complex : String?, finalComplention: ((result: Bool) -> Void)?){
            if(complex != nil){
                var starting: CGRect!
                if(complex == "left"){
                    starting = CGRectMake(containerView.frame.width+middlePosition.width+10, middlePosition.origin.y, middlePosition.width, middlePosition.height)
                }else{
                    starting = CGRectMake(-middlePosition.width-10, middlePosition.origin.y, middlePosition.width, middlePosition.height)
                }
                toAnimate.frame = starting;
                UIView.animateWithDuration(completeDuration/5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    toAnimate.frame = middlePosition;
                    }, completion: {
                        finished in
                        UIView.animateWithDuration(completeDuration/5, delay: completeDuration*(3/5), options: UIViewAnimationOptions.CurveEaseIn, animations: {
                            toAnimate.frame = starting
                            }, completion :
                            finalComplention)
                })
            }else{
                toAnimate.frame = CGRectMake(-middlePosition.width, middlePosition.origin.y, middlePosition.width, middlePosition.height)
                UIView.animateWithDuration(completeDuration/5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    toAnimate.frame = middlePosition;
                    }, completion: {finished in
                        UIView.animateWithDuration(completeDuration/5, delay: completeDuration*(3/5), options: UIViewAnimationOptions.CurveEaseIn, animations: {
                            toAnimate.frame = CGRectMake(containerView.frame.width+50, middlePosition.origin.y, middlePosition.width , middlePosition.height)
                            }, completion :
                            finalComplention
                        )}
                )
            }
        }
    }
    
    class Imaging{
        static func cropImage(image: UIImage, cropRect: CGRect) -> UIImage{
            let imageRef : CGImageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect)!
            let img : UIImage = UIImage(CGImage: imageRef)
            return img
        }
        
        static func takeScreenShot(view: UIView, cropRect : CGRect?) -> UIImage{
            UIGraphicsBeginImageContext(view.frame.size)
            view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            var image : UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            //            var postImage = UIImage(named: "\(image)")
            
            if let rect = cropRect{
                image = UtilityFunction.Imaging.cropImage(image, cropRect: rect)
            }
            return image
        }
    }
    
    class Audio{
        static func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer  {
            let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
            let url = NSURL.fileURLWithPath(path!)
            
            var audioPlayer:AVAudioPlayer?
            do {
                audioPlayer = try AVAudioPlayer(contentsOfURL: url)
            } catch{
                audioPlayer = nil
            }
            
            return audioPlayer!
        }
    }
}