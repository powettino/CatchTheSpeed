//
//  ChartElement.swift
//  CatchTheSpeed
//
//  Created by Iacopo Peri on 28/08/15.
//  Copyright (c) 2015 YeApp. All rights reserved.
//

import Foundation
import UIKit


internal struct ChartElement{
    
    var name : String
    var score : Int
    var mod : String
    var level : String
    var id : String
    var chartPosition : Int = 0
    var picture : UIImage?

    init(id: String , name : String, score: Int, mod: String, level:String, chartPosition: Int)
    {
        self.name = name
        self.score = score
        self.mod = mod
        self.level = level
        self.id = id
        self.chartPosition = chartPosition
    }
}