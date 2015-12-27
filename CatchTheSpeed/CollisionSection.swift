//
//  CollisionSection.swift
//  CatchTheSpeed
//
//  Created by Iacopo Peri on 05/08/15.
//  Copyright (c) 2015 YeApp. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit


struct CollisionSection {
    var referenceAngles : (angles: (max: CGFloat, min: CGFloat, dim: CGFloat), radius : CGFloat)!
    var collisionShape : SKShapeNode?
    var collisionName : String!
    var colliderNode : SKSpriteNode?
    var centerPoint : (x: CGFloat, y: CGFloat)
    
    init(startingLevel: Int, minDegree : Double, maxDegree : Double, minDimension: Double,  centerX: CGFloat, centerY: CGFloat, rad: CGFloat, collisionSectionName : String){
        referenceAngles = (CollisionSection.calcAngleOnLevel(startingLevel, minDegreeAngle: minDegree, maxDegreeAngle: maxDegree, minSectionDimension: minDimension), rad);
        centerPoint.x = centerX;
        centerPoint.y = centerY;
        collisionName = collisionSectionName;
        updateNodes()
    }
    
    mutating func updateSection(level: Int, refMinDegree : Double, refMaxDegree : Double, radius : CGFloat, minDimension: Double){
        referenceAngles = (CollisionSection.calcAngleOnLevel(level, minDegreeAngle: refMinDegree, maxDegreeAngle: refMaxDegree, minSectionDimension: minDimension), radius);
        updateNodes();
    }
    
    mutating func updateNodes(){
        let pathToDraw = CGPathCreateMutable()
        
        CGPathMoveToPoint(pathToDraw, nil, centerPoint.x, centerPoint.y)
        CGPathAddArc(pathToDraw, nil, centerPoint.x, centerPoint.y, referenceAngles.radius, referenceAngles.angles.max, referenceAngles.angles.min, true);
        
        CGPathAddLineToPoint(pathToDraw, nil, centerPoint.x, centerPoint.y)
        collisionShape = SKShapeNode(path:pathToDraw)
        collisionShape!.name = collisionName;
        collisionShape!.path = pathToDraw
        collisionShape!.strokeColor = SKColor.orangeColor()
        collisionShape!.glowWidth = 0.6
        collisionShape!.fillColor = SKColor.orangeColor().colorWithAlphaComponent(0.6);
        
        let offset : CGFloat = 0;
        let punto = UtilityFunction.Math.findXY(referenceAngles.radius-offset, centerX: centerPoint.x, centerY: centerPoint.y, angle: referenceAngles.angles.max);
        let corda = (2  * (referenceAngles.radius-offset)) * (sin(referenceAngles.angles.dim/2));
        
        /*
        TODO: Per evidenziare la zone di collisione commentare la riga sotto e decommentare quella con
        il colore nero del blocco
        */
        colliderNode = SKSpriteNode(color: UIColor.clearColor(), size: CGSize(width: corda, height: 10));
        //colliderNode = SKSpriteNode(color: UIColor.blackColor(), size: CGSize(width: corda, height: 10));
        colliderNode!.name = collisionName+"Collider";
        colliderNode!.position = CGPoint(x: punto.x, y: punto.y);
        colliderNode!.anchorPoint = CGPoint(x: 0, y: 1);
        colliderNode!.zRotation = (referenceAngles.angles.max - (referenceAngles.angles.dim/2)) - UtilityFunction.Math.degreesToRadiant(90)
        //            colliderNode!.physicsBody = SKPhysicsBody(rectangleOfSize: colliderNode!.frame.size)
        //            colliderNode!.physicsBody?.categoryBitMask = PhysicsCategory.CollisionBlockP
        //            colliderNode!.physicsBody?.contactTestBitMask = PhysicsCategory.NeedleP
        //            colliderNode!.physicsBody?.collisionBitMask = PhysicsCategory.Empty;
        //            colliderNode!.physicsBody?.dynamic=false;
        //            colliderNode!.physicsBody?.usesPreciseCollisionDetection=true;
        collisionShape?.addChild(colliderNode!)
    }
    
    private static func calcAngleOnLevel(level : Int, minDegreeAngle : Double, maxDegreeAngle: Double, minSectionDimension: Double) -> (max : CGFloat, min : CGFloat, dim : CGFloat){
        
        // si applica una correzione di 90 gradi dovuta agli assi del piano di presentazione
        // NSLog("Calcolo dai punti di riferimento: \(minDegreeAngle+90) - \(maxDegreeAngle+90)");
        let fixedAngles : (min: Double, max: Double) = (minDegreeAngle + 90, maxDegreeAngle + 90)
        var dimensionAngle = (fixedAngles.max - fixedAngles.min) / Double((level + 7))
        
        //NSLog("Dimensione angolo: \(dimensionAngle) - minimo: \( fixedAngles.min )");
        dimensionAngle = dimensionAngle < minSectionDimension ? minSectionDimension : dimensionAngle;
        
        let rnd: Double = UtilityFunction.Math.randomDouble( (fixedAngles.min + dimensionAngle),  max: (fixedAngles.max))
        //NSLog("Punto random: \(rnd)");
        
        return ( UtilityFunction.Math.degreesToRadiant(rnd), UtilityFunction.Math.degreesToRadiant(rnd-dimensionAngle), UtilityFunction.Math.degreesToRadiant(dimensionAngle));
    }
}
