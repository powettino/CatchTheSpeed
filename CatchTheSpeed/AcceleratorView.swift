//
//  AcceleratorView.swift
//  CatchTheSpeed
//
//  Created by Iacopo on 18/01/15.
//  Copyright (c) 2015 YeApp. All rights reserved.
//

import UIKit
import QuartzCore

class AcceleratorView: UIView {
    
    
    struct puntiCirconferenza
    {
        var overPuntiBaseX : [CGFloat];
        var overPuntiBaseY : [CGFloat];
        
        var puntiBaseX : [CGFloat];
        var puntiBaseY : [CGFloat];
        
        var underPuntiBaseX : [CGFloat]
        var underPuntiBaseY : [CGFloat]
        
        init(){
            puntiBaseX = []
            puntiBaseY = []
            overPuntiBaseX = []
            overPuntiBaseY = []
            underPuntiBaseX = []
            underPuntiBaseY = []
        }
        
        mutating func addPointXY(x pointX : CGFloat,y pointY : CGFloat){
            puntiBaseX.append(pointX)
            puntiBaseY.append(pointY)
        }
        mutating func addUnderPointXY(x pointX: CGFloat,y pointY: CGFloat){
            underPuntiBaseY.append(pointY)
            underPuntiBaseX.append(pointX)
        }
        
        mutating func addOverPointXY(x pointX: CGFloat,y pointY: CGFloat){
            overPuntiBaseY.append(pointY)
            overPuntiBaseX.append(pointX)
        }
        
        func getPointXY(position: Int) -> (CGFloat, CGFloat){
            return (puntiBaseX[position], puntiBaseY[position])
        }
        
        func getOverPointXY(position:Int) -> (CGFloat, CGFloat){
            
            return (overPuntiBaseX[position], overPuntiBaseY[position])
            
        }
        
        func getUnderPointXY(position:Int) -> (CGFloat, CGFloat){
            
            return (underPuntiBaseX[position], underPuntiBaseY[position])
            
        }
    }
    
    private let offsetCircle: CGFloat = 0
    private let precision: CGFloat = ((1/36)*CGFloat(M_PI))
    private let maxValueTick: CGFloat = ((4/3)*CGFloat(M_PI))
    private let pi : CGFloat = CGFloat(M_PI)
    private let pi2 : CGFloat = (2*CGFloat(M_PI))
    private let offsetAngle : CGFloat = (5/6) * CGFloat(M_PI)
    private var externalRadius:CGFloat = 0
    private var radius : CGFloat = 0
    private var internalRadius:CGFloat = 0
    private var minRadius:CGFloat = 0
    private var tickerRadius : CGFloat = 0
    private var centerX: CGFloat = 0
    private var centerY:CGFloat = 0
    private var tickerAngleMov : CGFloat = 0
    private var tickerAngle : CGFloat = 0
    private var multiplier: Int = 1
    private var coloredRadius :CGFloat = 0
    private var coloredStartingAngle: CGFloat = 0
    private var coloredEndingAngle : CGFloat = 0
    private var enableColored: Bool = false
    var shapeTicker : CAShapeLayer = CAShapeLayer()
    var spin : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
    //    var currentTimeTicking : Double = 0
    var stillRunning : Bool = false
    var startAngle : CGFloat = 0
    private var puntiCerchio = puntiCirconferenza()
    var checkPosition : NSTimer = NSTimer()
    
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        calcolaPuntiBase(frame)
        drawTicker()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder )
        calcolaPuntiBase(frame)
        drawTicker()
    }
    
    var countIteraction = 1
    
    func animaTicker(duration: Double){
        //println( "\(countIteraction)")
        //        self.currentTimeTicking = ticking
        self.shapeTicker.anchorPoint = CGPoint(x: (0.5), y: (0.5))
        
        self.spin.removedOnCompletion = false;
        self.spin.fillMode = kCAFillModeForwards;
        
        //        let actualTick = self.tickerAngle
        //
        //        if( self.multiplier > 0){
        //            if( (countIteraction % 5) == 0){
        //                println("entrato : \(tickerAngleMov)")
        //                self.tickerAngleMov += ((1 / 180) * M_PI)
        //            }
        //            if((self.tickerAngle + self.tickerAngleMov) <= Double(self.maxValueTick)){
        //                self.tickerAngle += self.tickerAngleMov
        //            }else{
        //                self.tickerAngle = Double(self.maxValueTick)
        //                self.multiplier = -1
        //            }
        //        }else{
        //            if(countIteraction % 5 == 0){
        //                println("adada: \(tickerAngleMov)")
        //                if( self.tickerAngleMov - ((1 / 180) * M_PI) < self.startAngleMov){
        //                    self.tickerAngleMov = self.startAngleMov
        //                }else{
        //                    self.tickerAngleMov -= (1 / 180) * M_PI
        //                }
        //            }
        //            if(self.tickerAngle - (self.tickerAngleMov) >= 0){
        //                self.tickerAngle -= self.tickerAngleMov
        //            }else{
        //                self.tickerAngle = 0
        //                self.multiplier = 1
        //            }
        //        }
        //        countIteraction++;
        
        
        self.spin.toValue = self.maxValueTick
        self.spin.fromValue = self.startAngle
        self.spin.repeatCount = Float.infinity
        self.spin.autoreverses = true
        self.spin.cumulative = false
        self.spin.delegate = self
        self.spin.duration = duration
        self.stillRunning = true
        let tickTime = duration / 0.001
        self.tickerAngleMov  = (self.maxValueTick - self.startAngle) / CGFloat(tickTime)
        // self.checkPosition = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("schedulePosition"), userInfo: nil, repeats: true)
        println("ticktime: \(tickTime) - move: \(self.tickerAngleMov)")
        self.shapeTicker.addAnimation(spin, forKey: "ticking")
        
    }
    
    var startTime = CACurrentMediaTime()
    
    func schedulePosition(){
        //println("realElapsed: \(CACurrentMediaTime() - startTime)")
        if (CACurrentMediaTime() - startTime >= self.spin.duration*2){
            //            println("elapsed: \(CACurrentMediaTime()-startTime) angolo \(self.tickerAngle)")
            
            startTime = CACurrentMediaTime()
        }
        if( multiplier > 0){
            if ( (self.tickerAngle + self.tickerAngleMov) > self.maxValueTick ){
                self.tickerAngle = self.maxValueTick
                multiplier = -1
                //            println("siamo a metà \(i) : \(CACurrentMediaTime()-startTime)")
            }else{
                self.tickerAngle += self.tickerAngleMov
            }
        }else{
            if(self.tickerAngle - self.tickerAngleMov < self.startAngle){
                self.tickerAngle = self.startAngle
                multiplier = 1
                //                println("siamo a fine \(i) : \(CACurrentMediaTime()-startTime)")
                println("ORAAAAAAAAAAAAA")
            }else{
                self.tickerAngle -= self.tickerAngleMov
            }
        }
        //        println("angolo: \(self.tickerAngle)")
    }
    
    func bloccaTicker(){
        //        self.currentTimeTicking = 0
        //        self.stillRunning = false
        self.checkPosition.invalidate()
        self.shapeTicker.removeAllAnimations()
    }
    
    override func animationDidStart(anim: CAAnimation!) {
        startTime = CACurrentMediaTime()
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        //        if(self.stillRunning){
        //            self.animaTicker(self.currentTimeTicking)
        //        }
    }
    
    
    private func drawTicker()
    {
        shapeTicker.frame = self.layer.bounds
        
        var path = CGPathCreateMutable()
        var subLayer1 = CAShapeLayer()
        subLayer1.frame = self.layer.bounds
        subLayer1.lineWidth = 1.0
        subLayer1.fillColor = UIColor.redColor().CGColor
        subLayer1.strokeColor=UIColor.blackColor().CGColor
        CGPathMoveToPoint(path, nil, centerX, centerY)
        
        var puntiExt = findXY(radius, centerX: centerX, centerY: centerY, angle: ((CGFloat(tickerAngle)*pi) / 180) + offsetAngle)
        CGPathAddLineToPoint(path, nil, puntiExt.0, puntiExt.1)
        
        var punti = findXY(tickerRadius, centerX: centerX, centerY: centerY, angle: ((CGFloat(tickerAngle)*pi) / 180) + offsetAngle - ((1/2)*pi))
        CGPathAddLineToPoint(path, nil, punti.0, punti.1)
        CGPathMoveToPoint(path, nil, centerX, centerY)
        
        CGPathCloseSubpath(path)
        
        subLayer1.path = path
        shapeTicker.insertSublayer(subLayer1, atIndex: 1)
        
        
        var subLayer2 = CAShapeLayer()
        subLayer2.frame = self.layer.bounds
        subLayer2.lineWidth = 1.0
        subLayer2.fillColor = UIColor(red: 0.3, green: 0.5, blue: 0.5, alpha: 0.4).CGColor
        subLayer2.strokeColor=UIColor.blackColor().CGColor
        
        var path2 = CGPathCreateMutable()
        CGPathMoveToPoint(path2, nil, centerX, centerY)
        punti = findXY(tickerRadius, centerX: centerX, centerY: centerY, angle: ((CGFloat(tickerAngle)*pi) / 180) + offsetAngle + ((1/2)*pi))
        CGPathAddLineToPoint(path2, nil, punti.0 , punti.1)
        CGPathAddLineToPoint(path2, nil, puntiExt.0, puntiExt.1)
        CGPathMoveToPoint(path2, nil, centerX, centerY)
        CGPathCloseSubpath(path2)
        subLayer2.path = path2
        
        shapeTicker.insertSublayer(subLayer2, atIndex: 0)
        
        var center = CAShapeLayer()
        var centerPath = CGPathCreateMutable()
        
        center.fillColor = UIColor.blackColor().CGColor
        CGPathAddArc(centerPath, nil, centerX, centerY, minRadius, offsetAngle, pi2 + (maxValueTick), false)
        CGPathCloseSubpath(centerPath)
        center.path = centerPath
        shapeTicker.addSublayer(center)
        
        self.layer.addSublayer(shapeTicker)
        
    }
    
    override func drawRect(rect: CGRect) {
        let canvas = UIGraphicsGetCurrentContext()
        CGContextSaveGState(canvas)
        let centerX = frame.size.width/2
        let centerY = frame.size.height/2
        let width = frame.size.width
        let height = frame.size.height
        
        drawExternalCircle(canvas)
        if (enableColored){
            drawColored(canvas)
        }
        drawLinee(canvas)
        
        CGContextRestoreGState(canvas)
    }
    
    func getReferenceAngleValue() -> (min: Double, max: Double){
        return (Double(self.startAngle), Double(((self.maxValueTick) * 180) / pi) )
        //        return (Double(self.offsetAngle * 180 ) / M_PI, Double((self.maxValueTick + self.offsetAngle)*180) / M_PI)
    }
    
    func enableYellowSection(startingAngle: Double, endingAngle:Double){
        coloredStartingAngle = ((CGFloat(startingAngle) / 180 ) * pi) + self.offsetAngle
        coloredEndingAngle = ((CGFloat(endingAngle)  / 180 ) * pi ) + self.offsetAngle
        enableColored = true
        self.setNeedsDisplay()
    }
    
    func disableYellowSection()
    {
        enableColored=false
        coloredEndingAngle=0
        coloredStartingAngle=0
    }
    
    private func calcolaPuntiBase(frame: CGRect){
        var minDim = frame.size.width < frame.size.height ? frame.size.width : frame.size.height
        self.radius = (minDim-15)/2
        self.externalRadius = radius + 1
        self.internalRadius = externalRadius-10
        self.minRadius = internalRadius * 3/25
        self.tickerRadius = minRadius*(2/5)
        self.coloredRadius = self.radius
        centerX = frame.size.width/2
        centerY = frame.size.height/2 + offsetCircle
        
        for index in (0...Int(maxValueTick/precision)){
            var punti = findXY(radius, centerX: centerX, centerY: centerY, angle: (CGFloat(index)*precision)+offsetAngle)
            puntiCerchio.addPointXY(x: punti.0, y: punti.1)
            punti = findXY(internalRadius, centerX: centerX, centerY: centerY, angle: (CGFloat(index)*precision)+offsetAngle)
            puntiCerchio.addUnderPointXY(x: punti.0, y: punti.1)
            punti = findXY(externalRadius, centerX: centerX, centerY: centerY, angle: (CGFloat(index)*precision)+offsetAngle)
            puntiCerchio.addOverPointXY(x: punti.0, y: punti.1)
        }
    }
    
    func resetTicker() -> Void {
        self.shapeTicker.removeAnimationForKey("ticking")
        self.checkPosition.invalidate()
        self.tickerAngle = 0;
        
    }
    
    func getTickerAngle() -> Double{
        var modulo = (CACurrentMediaTime() - startTime) % (self.spin.duration * 2)
        
        println("primo \(modulo) -- \(self.spin.duration)")
        var angolo: CGFloat = 0.0;
        if(modulo > self.spin.duration)
        {
            modulo = (modulo % self.spin.duration)
            println("reverso \(modulo)")
            angolo = self.maxValueTick - (self.tickerAngleMov * CGFloat(modulo / 0.001))
        }else{
            
            angolo = self.startAngle + (self.tickerAngleMov * CGFloat(modulo / 0.001))
        }
        
        println("ANIMATOOOOOOOOOOOO \(angolo) --- \(((angolo * 180) / pi))")
        
        return Double((angolo * 180) / pi)
        //return Double(self.tickerAngle)
        
        //        return Double((tickerAngle + Double(offsetAngle)) * 180) / M_PI
    }
    
    func setTickerAngleMov(angle: Double){
        //        self.startAngleMov = (CGFloat(angle) * pi) / 180
        self.tickerAngleMov = (CGFloat(angle) * pi) / 180
    }
    
    private func drawColored(canvas :CGContext)
    {
        CGContextSaveGState(canvas)
        
        CGContextSetFillColorWithColor(canvas, UIColor.orangeColor().colorWithAlphaComponent(0.6).CGColor)
        CGContextSetLineWidth(canvas, 0.0)
        CGContextMoveToPoint(canvas, centerX, centerY)
        CGContextAddArc(canvas, centerX, centerY, radius, coloredStartingAngle, coloredEndingAngle ,0)
        
        var punti = findXY(radius, centerX: centerX, centerY: centerY, angle: offsetAngle)
        CGContextMoveToPoint(canvas,  punti.0, punti.1)
        
        CGContextDrawPath(canvas, kCGPathFillStroke)
        
        CGContextRestoreGState(canvas)
    }
    
    private func drawLinee(canvas: CGContext){
        CGContextSaveGState(canvas)
        for index in (0...Int(maxValueTick/precision)){
            if(index % 4 == 0){
                CGContextSetStrokeColorWithColor(canvas, UIColor.redColor().CGColor)
            }else{
                CGContextSetStrokeColorWithColor(canvas, UIColor.blackColor().CGColor)
            }
            CGContextSetLineWidth(canvas, 2.0);
            CGContextMoveToPoint(canvas, puntiCerchio.getOverPointXY(index).0, puntiCerchio.getOverPointXY(index).1)
            CGContextAddLineToPoint(canvas, puntiCerchio.getUnderPointXY(index).0, puntiCerchio.getUnderPointXY(index).1)
            CGContextStrokePath(canvas)
        }
        CGContextRestoreGState(canvas)
    }
    
    private func drawExternalCircle(canvas: CGContext) {
        CGContextSaveGState(canvas)
        CGContextSetLineWidth(canvas, 4.0);
        CGContextAddArc(canvas, centerX, centerY, radius, offsetAngle, offsetAngle + (maxValueTick),0)
        var punti = findXY(radius, centerX: centerX, centerY: centerY, angle: offsetAngle)
        CGContextAddLineToPoint(canvas, punti.0, punti.1)
        CGContextSetFillColorWithColor(canvas, UIColor.lightGrayColor().CGColor)
        CGContextDrawPath(canvas, kCGPathFillStroke)
        CGContextMoveToPoint(canvas, punti.0, punti.1)
        CGContextAddArc(canvas, centerX, (centerY+radius), radius, ((7/6)*pi), (11/6)*pi,0)
        CGContextSetFillColorWithColor(canvas, UIColor.grayColor().CGColor)
        CGContextFillPath(canvas)
        CGContextRestoreGState(canvas)
        
    }
    
    private func findXY(radius : CGFloat, centerX : CGFloat, centerY:CGFloat, angle:CGFloat) -> (CGFloat, CGFloat){
        let puntoX = centerX + (radius * cos(angle))
        let puntoY = centerY + (radius * sin(angle))
        return ( puntoX, puntoY)
    }
}
