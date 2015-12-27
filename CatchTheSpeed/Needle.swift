//
//  Needle.swift
//  CatchTheSpeed
//
//  Created by Iacopo Peri on 05/08/15.
//  Copyright (c) 2015 YeApp. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import QuartzCore

struct Needle{
    
    internal enum NeedleSpeed : NSTimeInterval{
        case fastest = 0.5
        case fast = 0.8
        case medium = 1
        case low = 1.5
    }
    
    var speed : NeedleSpeed!
    var movementAngles : (min: CGFloat, max: CGFloat)
    //    var collisionCategory : UInt32 = PhysicsCategory.NeedleP;
    //    var contactCollisionCategory  : UInt32 = PhysicsCategory.CollisionBlockP
    //    var collisionBitMask : UInt32 = PhysicsCategory.Empty
    var spriteNode : SKSpriteNode?
    var colliderNode : SKSpriteNode?
    var rotationLabel : String = "rotationAction"
    var rotating : Bool = false;
    
    init(spriteName : String, w: CGFloat, maxH:CGFloat, posX : CGFloat, posY : CGFloat, posZ : CGFloat, name: String, startingAngle : Double, minAngle : Double, maxAngle : Double, anchorPoint: CGPoint){
        speed = NeedleSpeed.low
        spriteNode = SKSpriteNode(imageNamed: spriteName);
        spriteNode!.name = name
        spriteNode!.position = CGPoint(x: posX, y: posY)
        spriteNode!.size = CGSize(width: w, height: maxH)
        spriteNode!.anchorPoint = anchorPoint
        spriteNode!.zRotation = UtilityFunction.Math.degreesToRadiant(startingAngle)
        spriteNode!.zPosition = posZ;
        movementAngles.min = UtilityFunction.Math.degreesToRadiant(minAngle)
        movementAngles.max = UtilityFunction.Math.degreesToRadiant(maxAngle)
        rotating = false;
        
        var colliderWidth : CGFloat = 10;
        var colliderHeight : CGFloat = 10;
        
        /*TODO: Per evidenziare il nodo di collisione commentare la riga sotto e decommentare la riga con
        il colore rosso nel nodo di collisione
        */
        colliderNode = SKSpriteNode(color: UIColor.clearColor(), size: CGSize(width: colliderWidth, height: colliderHeight))
        //colliderNode = SKSpriteNode(color: UIColor.redColor(), size: CGSize(width: colliderWidth, height: colliderHeight))
        colliderNode!.name = name+"Collider";
        var punto = UtilityFunction.Math.findXY(maxH , centerX: posX, centerY: posY, angle: UtilityFunction.Math.degreesToRadiant(90));
        colliderNode!.position = CGPoint(x: punto.x-spriteNode!.position.x, y: punto.y - spriteNode!.position.y)
        colliderNode!.zPosition = posZ;
        //            colliderNode!.physicsBody = SKPhysicsBody(circleOfRadius: colliderWidth/2 - 7)
        //            colliderNode!.physicsBody?.categoryBitMask = collisionCategory;
        //            colliderNode!.physicsBody?.contactTestBitMask = contactCollisionCategory;
        //            colliderNode!.physicsBody?.collisionBitMask = collisionBitMask
        //            colliderNode!.physicsBody?.dynamic = true;
        //            colliderNode!.physicsBody?.usesPreciseCollisionDetection = true;
        
        spriteNode?.addChild(colliderNode!);
    }
    
    mutating func setSpeed(newSpeed : NeedleSpeed){
        speed = newSpeed;
    }
    
    mutating func increaseSpeedTo(value: CGFloat){
        spriteNode!.runAction(SKAction.speedTo(value, duration: 0.5));
    }
    
    mutating func setStartPosition(startingAngle : Double){
        spriteNode!.zRotation = UtilityFunction.Math.degreesToRadiant(startingAngle)
    }
    
    func isRotating() -> Bool{
        return rotating
    }
    
    mutating func startRotation(){
        let forwardRotation = SKAction.rotateToAngle(movementAngles.min, duration: speed.rawValue, shortestUnitArc: false);
        let backwardRotation = SKAction.rotateToAngle(movementAngles.max, duration: speed.rawValue, shortestUnitArc: false);
        var seq = SKAction.sequence([forwardRotation, backwardRotation]);
        spriteNode?.runAction(
            SKAction.repeatActionForever(seq)
            , withKey: rotationLabel
        );
        rotating = true
    }
    
    mutating func pauseRotation(paused: Bool){
        rotating = !paused
        spriteNode?.paused = paused;
    }
    
    mutating func stopRotation(){
        spriteNode?.removeActionForKey(rotationLabel)
        rotating = false
    }
}