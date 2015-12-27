//
//  ChartWatchController.swift
//  CatchTheSpeed
//
//  Created by Iacopo Peri on 30/09/15.
//  Copyright (c) 2015 YeApp. All rights reserved.
//

import WatchKit
import Foundation

class ChartRowController : NSObject {
    
    @IBOutlet weak var position: WKInterfaceLabel!
    @IBOutlet weak var player: WKInterfaceLabel!
    @IBOutlet weak var points: WKInterfaceLabel!
    @IBOutlet weak var mod: WKInterfaceLabel!
    
    func setInfo(chartPosition: String, playerName: String, actualPoints: String, gameMod: String){
        self.position.setText(chartPosition)
        self.player.setText(playerName)
        self.points.setText(actualPoints)
        self.mod.setText(gameMod)
    }
}