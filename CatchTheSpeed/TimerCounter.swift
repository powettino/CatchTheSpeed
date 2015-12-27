//
//  TimerCounter.swift
//  CatchTheSpeed
//
//  Created by Iacopo Peri on 05/08/15.
//  Copyright (c) 2015 YeApp. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit


struct TimerCounter{
    var second1: SKSpriteNode?
    var second2: SKSpriteNode?
    var current : Int
    var fire : Double
    var second1ActionName : String = "second1Action"
    var second2ActionName : String = "second2Action"
    var internalSpeedo : Speedo
    init(speedo : Speedo, nameFirst : String, nameSecond : String, fireTimer : Double, w: CGFloat, h: CGFloat, posX : CGFloat, posY : CGFloat, posZ : CGFloat){
        current = 60
        internalSpeedo = speedo;
        fire = fireTimer
        second1 = SKSpriteNode(imageNamed: "risorse/speedo/numbers/number"+String(current / 10)+".png");
        second2 = SKSpriteNode(imageNamed: "risorse/speedo/numbers/number"+String(current % 10)+".png");
        second1?.name = nameFirst;
        second2?.name = nameSecond;
        second1?.size = CGSize(width: w, height: h)
        second2?.size = CGSize(width: w, height: h)
        second1?.anchorPoint = CGPoint(x:1,y:0)
        second2?.anchorPoint = CGPoint(x: 0, y: 0)
        second1?.position = CGPoint(x: posX, y: posY)
        second2?.position = CGPoint(x: posX, y: posY)
        second1?.zPosition = posZ;
        second2?.zPosition = posZ;
    }
    
    mutating func restoreTimer(){
//        println("llll  1 \(self.current)")
        second1?.texture = SKTexture(imageNamed: "risorse/speedo/numbers/number"+String(self.current / 10)+".png");
        self.second2?.texture = SKTexture(imageNamed: "risorse/speedo/numbers/number"+String(self.current % 10)+".png");
    }
    
    mutating func startCounter(){
        var block1 = SKAction.sequence([
            SKAction.animateWithTextures([
                SKTexture(imageNamed: "risorse/speedo/numbers/number6.png")],
                timePerFrame: self.fire),
            SKAction.animateWithTextures([
                SKTexture(imageNamed: "risorse/speedo/numbers/number5.png")],
                timePerFrame: self.fire*10),
            SKAction.animateWithTextures([
                SKTexture(imageNamed: "risorse/speedo/numbers/number4.png")],
                timePerFrame: self.fire*10),
            SKAction.animateWithTextures([
                SKTexture(imageNamed: "risorse/speedo/numbers/number3.png")],
                timePerFrame: self.fire*10),
            SKAction.animateWithTextures([
                SKTexture(imageNamed: "risorse/speedo/numbers/number2.png")],
                timePerFrame: self.fire*10),
            SKAction.animateWithTextures([
                SKTexture(imageNamed: "risorse/speedo/numbers/number1.png")],
                timePerFrame: self.fire*10),
            SKAction.animateWithTextures([
                SKTexture(imageNamed: "risorse/speedo/numbers/number0.png")],
                timePerFrame: self.fire*10)
            ])
        
        var block2 = SKAction.sequence([
            SKAction.animateWithTextures([
                SKTexture(imageNamed: "risorse/speedo/numbers/number0.png")],
                timePerFrame: self.fire),
            SKAction.runBlock({
                if(self.current==0){
                    self.stopCounter()
                    self.internalSpeedo.timerDelegate?.timerEnded();
                }
                self.current--
            }),
            SKAction.animateWithTextures([
                SKTexture(imageNamed: "risorse/speedo/numbers/number9.png")],
                timePerFrame: self.fire),
            SKAction.runBlock({
                self.current--
            }),
            SKAction.animateWithTextures([
                SKTexture(imageNamed: "risorse/speedo/numbers/number8.png")],
                timePerFrame: self.fire),
            SKAction.runBlock({
                self.current--
            }),
            SKAction.animateWithTextures([
                SKTexture(imageNamed: "risorse/speedo/numbers/number7.png")],
                timePerFrame: self.fire),
            SKAction.runBlock({
                self.current--
            }),
            SKAction.animateWithTextures([
                SKTexture(imageNamed: "risorse/speedo/numbers/number6.png")],
                timePerFrame: self.fire),
            SKAction.runBlock({
                self.current--
            }),
            SKAction.animateWithTextures([
                SKTexture(imageNamed: "risorse/speedo/numbers/number5.png")],
                timePerFrame: self.fire),
            SKAction.runBlock({
                self.current--
            }),
            SKAction.animateWithTextures([
                SKTexture(imageNamed: "risorse/speedo/numbers/number4.png")],
                timePerFrame: self.fire),
            SKAction.runBlock({
                self.current--
            }),
            SKAction.animateWithTextures([
                SKTexture(imageNamed: "risorse/speedo/numbers/number3.png")],
                timePerFrame: self.fire),
            SKAction.runBlock({
                self.current--
            }),
            SKAction.animateWithTextures([
                SKTexture(imageNamed: "risorse/speedo/numbers/number2.png")],
                timePerFrame: self.fire),
            SKAction.runBlock({
                self.current--
            }),
            SKAction.animateWithTextures([
                SKTexture(imageNamed: "risorse/speedo/numbers/number1.png")],
                timePerFrame: self.fire),
            SKAction.runBlock({
                self.current--
            })
        ])
        
        second1?.runAction(
            SKAction.repeatAction(
                block1,
                count: 1),
            withKey: self.second1ActionName)
        second2?.runAction(
            SKAction.repeatAction(
                block2,
                count: 7),
            withKey: self.second2ActionName)
        
    }
    
    mutating func pauseCounter(paused : Bool){
        second1?.paused = paused
        second2?.paused = paused
    }
    
    mutating func stopCounter(){
        second1?.removeAllActions()
        second2?.removeAllActions()
    }
}
