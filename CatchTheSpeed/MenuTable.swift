//
//  CustomTable.swift
//  CatchTheSpeed
//
//  Created by Iacopo Peri on 01/07/15.
//  Copyright (c) 2015 YeApp. All rights reserved.
//

import Foundation
import UIKit


protocol OptionMenuDelegate{
    func changedSurvival()
    func changedTimer()
    func changedSounds()
    func changedEffects()
    func restartGame()
    func closeMenu()
}

class MenuTable : UITableView{
    
    var menuDelegate : OptionMenuDelegate?
    
    @IBOutlet weak var effectsSetter: UISwitch!
    @IBOutlet weak var audioSetter: UISwitch!
    @IBAction func closeClick(sender: AnyObject) {
        self.menuDelegate?.closeMenu()
    }
    
    @IBAction func restartClick(sender: AnyObject) {
        self.menuDelegate?.restartGame();
        self.menuDelegate?.closeMenu()
    }
    
    @IBAction func changingEffects(sender: AnyObject) {
        self.menuDelegate?.changedEffects();
    }
    
    @IBAction func changingSound(sender: AnyObject) {
        self.menuDelegate?.changedSounds();
    }
    
    @IBAction func changingTimer(sender: AnyObject) {
        self.menuDelegate?.changedTimer();
    }
    
    @IBAction func changingSurvival(sender: AnyObject) {
        self.menuDelegate?.changedSurvival();
    }
    
    func setAudioSwitch(status: Bool){
        self.audioSetter.setOn(status, animated: false)
    }
    
    func setEffectsSwitch(status: Bool){
        self.effectsSetter.setOn(status, animated: false)
    }
    
}