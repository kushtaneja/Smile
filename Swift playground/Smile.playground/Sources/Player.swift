//
//  Player.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit


enum Gender{
    case male
    case female
    case unknown
}

class Player: Equatable {

    var emoji: String

    var color: UIColor
    
    var identifier: String

    let gender: Gender

    var expression: FacialExpression

    var winCount: UInt = 0
    
    var isRandom = false
    
    init(_ emoji: String = "", color: UIColor = UIColor.clear, gender: Gender = .male) {
        expression = FacialExpression()
        identifier = emoji
        self.emoji = emoji
        self.gender = gender
        self.color = color
        
        if gender == .unknown {
            isRandom = true
        }
        
        
    }
    
    public static func == (leftPlayer: Player, rightPlayer: Player) -> Bool {
        return leftPlayer.identifier == rightPlayer.identifier
    }
}
