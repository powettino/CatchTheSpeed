//
//  Speedo.swift
//  CatchTheSpeed
//
//  Created by Iacopo Peri on 09/03/15.
//  Copyright (c) 2015 YeApp. All rights reserved.
//

import Foundation
import SpriteKit
import QuartzCore


protocol ScoreDelegate{
    func setPoint();
    func setFail();
}

protocol StartingActionDelegate{
    func startedGame();
}

protocol TimerDelegate{
    func timerEnded();
}


class Speedo : SKScene{
    
    struct PhysicsCategory {
        static let NeedleP : UInt32 = 0b1
        static let CollisionBlockP : UInt32 = 0b10
        static let Empty : UInt32 = 0b0
    }
    
    private final let lightNodeName : String = "lightNode"
    private final let collisionSectionShapeName : String = "yellowNode"
    private final let gridNodeName :String = "gridNode"
    private final let vetroNodeName :String = "vetroNode"
    private final let needleNodeName : String = "needleNode"
    private final let labelNodeName : String = "labelNode"
    private final let smokeNodeName : String = "smokeNode"
    private final let labelStandardText : String = "SPEED UP"
    private final let timerNodeFirstName : String = "timerNodeFirst"
    private final let timerNodeSecondName : String = "timerNodeSecond"
    
    private var enableFail = false;
    private var enableTouchStartGame = false;
    private var enableTimer = false;
    private final let minDegreeNeedleAngle : Double = -136   //-46
    private final let maxDegreeNeedleAngle : Double = 136   //226
    //    private final let radius : CGFloat = 132;
    private var currentLevel : Int = 1
    private var colliso : Bool = false;
    private var running : Bool = false
    private final let offset : (w: CGFloat, h: CGFloat) = (35,35)
    
    
    private var label: SKLabelNode!
    private var grid : SKSpriteNode!
    private var ambientLight : SKLightNode!
    private var vetro : SKSpriteNode!
    private var needle : Needle!
    private var collisionSection : CollisionSection!
    private var timerCounter : TimerCounter!
    private var maxAngle : CGFloat!
    private var minAngle : CGFloat!
    private var minSectionDimension : Double = 10;
    private var centerX : CGFloat!;
    private var centerY : CGFloat!;
    
    var scoreDelegate : ScoreDelegate?
    var startingActionDelegate : StartingActionDelegate?
    var timerDelegate : TimerDelegate?
    
    override func didMoveToView(view: SKView) {
        self.view?.allowsTransparency = true
        self.backgroundColor = UIColor.clearColor()
        
        self.centerX = self.size.width/2;
        self.centerY = self.size.height/2;
        
        self.grid = SKSpriteNode(imageNamed: "risorse/speedo/speedo.png");
        self.grid.name = self.gridNodeName;
        self.grid.position = CGPoint(x: self.centerX, y: self.centerY)
        self.grid.size = CGSize(width: self.size.width - self.offset.w, height: self.size.width - self.offset.h);
        self.grid.physicsBody = nil;
        self.addChild(self.grid)
        
        self.needle = Needle(spriteName: "risorse/speedo/needle.png", w: ((self.size.width - self.offset.w)/2 - 30)/3, maxH: ((self.size.width - self.offset.w)/2 - 30), posX: self.centerX, posY: self.centerY, posZ: CGFloat(1), name: self.needleNodeName, startingAngle: maxDegreeNeedleAngle, minAngle:minDegreeNeedleAngle, maxAngle: maxDegreeNeedleAngle, anchorPoint: CGPoint(x: 0.5,y: 0.15));
        
        self.collisionSection = CollisionSection(startingLevel: self.currentLevel, minDegree: self.minDegreeNeedleAngle, maxDegree: self.maxDegreeNeedleAngle, minDimension: minSectionDimension, centerX: self.centerX, centerY: self.centerY, rad: ((self.size.width - self.offset.w)/2 - 17), collisionSectionName: self.collisionSectionShapeName);
        
        self.timerCounter = TimerCounter(speedo: self, nameFirst: timerNodeFirstName, nameSecond: timerNodeSecondName,fireTimer: 1, w: self.size.width / 9, h: self.size.height/10, posX: self.centerX , posY: self.centerY - (self.size.height/10) - 25, posZ: 0)
        
        if let needleNode = self.needle.spriteNode {
            self.addChild(needleNode);
        }
        
        if let  yellowNode = self.collisionSection.collisionShape {
            self.addChild(yellowNode);
        }
        
        self.vetro = SKSpriteNode(imageNamed: "risorse/speedo/vetro3.png");
        self.vetro.name = self.vetroNodeName;
        self.vetro.position = CGPoint(x: self.centerX, y: self.centerY)
        self.vetro.size = CGSize(width: self.size.width - self.offset.w - 20, height: self.size.width - self.offset.h - 20);
        
        self.vetro.physicsBody = nil;
        //        self.vetro.normalTexture = SKTexture(imageNamed: "risorse/normalMaps/lightNormalGlass.jpg")
        self.vetro.normalTexture = SKTexture(imageNamed: "risorse/normalMaps/brokenGlass.jpg")
        self.vetro.lightingBitMask = 1;
        self.vetro.zPosition = 2
        
        self.addChild(self.vetro)
        
        //        self.label = SKLabelNode(fontNamed: "BradleyHandITCTT-Bold")
        //        self.label = SKLabelNode(fontNamed: "BudmoJiggler-Regular")
        //        self.label = SKLabelNode(fontNamed: "Flame");
        self.label = SKLabelNode(fontNamed: "Blazed");
        self.label.text = self.labelStandardText
        self.label.name = self.labelNodeName;
        self.label.fontColor = UIColor.redColor();
        self.label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center;
        self.label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center;
        self.label.position = CGPointMake(-self.label.frame.width, self.centerY+50);
        self.label.fontSize = 20;
        
        self.label.physicsBody = nil;
        self.addChild(self.label);
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        
        self.ambientLight = SKLightNode()
        self.ambientLight.name = self.lightNodeName
        self.ambientLight.falloff = 0;
        self.ambientLight.position = CGPoint(x: 250, y: 60)
        //        self.ambientLight.position = CGPoint(x: 20, y: 300)
        self.ambientLight.categoryBitMask = 1
        self.addChild(self.ambientLight)
        
    }
    
    //questa funziona sovrascrive l'aggiornamento dell'oggetto spritekit
    //per aggiornare la collisione tra i due oggetti
    override func update(currentTime: NSTimeInterval) {
        var intersecato = self.needle.colliderNode!.intersectsNode(self.collisionSection.colliderNode!);
        if(intersecato && !self.colliso){
            self.colliso = true;
        }
        if(!intersecato && self.colliso){
            self.colliso=false;
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if(self.running){
            if (            self.needle!.isRotating()){
                if(self.colliso){
                    self.colliso = false;
                    self.currentLevel++;
                    self.scoreDelegate?.setPoint();
                }else if(self.enableFail){
                    self.scoreDelegate?.setFail();
                }
            }
        }else{
            if(self.enableTouchStartGame){
                self.running = true;
                self.startingActionDelegate?.startedGame();
                
            }
        }
    }
    
    func brakeGlass(){
        self.vetro.normalTexture = SKTexture(imageNamed: "risorse/normalMaps/brokenGlass.jpg")
    }
    
    func normalGlass(){
        self.vetro.normalTexture = SKTexture(imageNamed: "risorse/normalMaps/lightNormalGlass.jpg")
    }
    
    func setNeedleSpeed(speed : Needle.NeedleSpeed){
        self.needle.setSpeed(speed);
    }
    
    func increaseSpeedTo(value : CGFloat){
        self.needle.increaseSpeedTo(value);
    }
    
    func enableTouchStartGame(enable: Bool){
        self.enableTouchStartGame = enable;
    }
    
    func enableFailDelegate(enable : Bool){
        self.enableFail = enable;
    }
    
    func enableTimer(enable : Bool)
    {
        if(enable && !self.enableTimer){
            if let second1 = self.timerCounter.second1 {
                self.addChild(second1)
            }
            
            if let second2 = self.timerCounter.second2 {
                self.addChild(second2)
            }
        }
        if(!enable && self.enableTimer){
            UtilityFunction.SpriteKitUtility.removeNodesFromParentWIthNames(self, nodesName: [self.timerNodeFirstName, self.timerNodeSecondName])
        }
        
        self.enableTimer = enable;
    }
    
    func animateText(text : String?){
        if let emitter = self.childNodeWithName(self.smokeNodeName) {
            NSLog("Skip emitter")
        }else{
            
            if let tempText = text {
                self.label.text = tempText
            }
            
            var originalPosition = self.label.position
            
            var midPoint = CGPointMake(self.centerX, self.centerY+50)
            var startingPoint = CGPointMake(-self.label.frame.width-10, self.centerY+50)
            var endingPoint = CGPointMake(self.size.width+self.label.frame.width+10, self.label.position.y)
            
            var inc = SKTMoveEffect(node: self.label, duration: 0.8, startPosition: startingPoint, endPosition:midPoint)
            inc.timingFunction = SKTTimingFunctionBackEaseOut
            
            var out = SKTMoveEffect(node: self.label, duration: 0.8, startPosition: self.label.position, endPosition: endingPoint)
            out.timingFunction = SKTTimingFunctionBackEaseIn
            
            self.label.runAction(SKAction.sequence([
                SKAction.actionWithEffect(inc),
                SKAction.waitForDuration(0.5),
                SKAction.actionWithEffect(out)]), completion:{
                    self.label.position = originalPosition
                    self.label.text = self.labelStandardText
            });
            
            var smokeEmitter = SKEmitterNode(fileNamed: "SmokeBrake");
            smokeEmitter.particleTexture = SKTexture(imageNamed: "risorse/visual_effects/spark.png")
            smokeEmitter.name = self.smokeNodeName
            smokeEmitter.position = CGPointMake(self.centerX+(self.label.frame.width/2), self.centerY+50)
            
            self.runAction(SKAction.waitForDuration(0.3), completion: {self.addChild(smokeEmitter)});
            self.runAction(SKAction.waitForDuration(2), completion:{
                smokeEmitter.removeFromParent();
            });
        }
    }
    
    func startSpeedo(){
        if(self.enableTimer){
            self.timerCounter.startCounter();
        }
        self.needle.startRotation();
        self.running=true;
//        NSLog("velocita: \(self.needle.speed.rawValue)");
    }
    
    func stopSpeedo(){
        self.running=false;
        self.needle.stopRotation();
        self.timerCounter.stopCounter();
    }
    
    func isRunning() -> Bool{
        return self.running
    }
    
    func resetSpeedo(){
        self.stopSpeedo();
        self.needle.increaseSpeedTo(1.0);
        self.needle.setStartPosition(maxDegreeNeedleAngle)
        self.currentLevel = 1;
        self.updateCollisionSection(self.currentLevel);
        self.timerCounter.restoreTimer()
    }
    
    func pauseSpeedo(paused: Bool){
        self.needle.pauseRotation(paused)
        self.timerCounter.pauseCounter(paused)
    }
    
    func setLevel(level: Int){
        self.currentLevel = level;
    }
    
    func updateCollisionSection(level : Int?){
        if let tempLevel = level{
            self.setLevel(tempLevel);
        }
        self.enumerateChildNodesWithName(self.collisionSectionShapeName) {
            node, stop in
            node.removeFromParent();
        }
        
        self.collisionSection.updateSection(self.currentLevel, refMinDegree: self.minDegreeNeedleAngle, refMaxDegree: self.maxDegreeNeedleAngle, radius : (self.grid.size.height/2)-18, minDimension: minSectionDimension);
        self.addChild(self.collisionSection.collisionShape!);
    }
    
    func isMinimunSectionDimension() -> Bool{
        return (self.collisionSection.referenceAngles.angles.dim == UtilityFunction.Math.degreesToRadiant(self.minSectionDimension));
    }
}

