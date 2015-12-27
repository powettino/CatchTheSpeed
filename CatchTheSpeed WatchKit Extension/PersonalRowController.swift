//
//  ChartWatchController.swift
//  CatchTheSpeed
//
//  Created by Iacopo Peri on 30/09/15.
//  Copyright (c) 2015 YeApp. All rights reserved.
//

import WatchKit
import Foundation

class PersonalRowController : NSObject {
    
    @IBOutlet weak var mod: WKInterfaceLabel!
    
    @IBOutlet weak var score: WKInterfaceLabel!
    @IBOutlet weak var level: WKInterfaceLabel!
    func setInfo(actualPoints: String, gameMod: String, level: String){
        self.mod.setText(gameMod)
        self.score.setText(actualPoints)
        self.level.setText("Level: \(level)")
    }
}