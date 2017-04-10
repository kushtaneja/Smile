//
//  Emotion.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit

/// Supported emotion types.
enum EmotionType {
    case happy
    case sad
    case random
}

/**
 A class that represents an emotion for the game. You can set an emoji to customize your emotion.

 */

public class Emotion: Equatable {

    let type: EmotionType
    
    let emoji: String

    // Use by subclass.
    func commonInit() { }
    
    init() {
        emoji = ""
        type = .happy
        commonInit()
    }
    
    /**
     Create a new emotion with an emoji.
     
     - Parameters:
       - emoji: An emoji representation for the emotion.
       - type: Emotion type for the emotion.
     
     - Returns: 
     Emotion: A new emotion object with the specified emoji.
     */
    init(_ emoji: String, type: EmotionType = .happy) {
        self.type = type
        self.emoji = emoji
        commonInit()
    }

    public static func == (leftEmotion: Emotion, rightEmotion: Emotion) -> Bool {
        return leftEmotion.emoji == rightEmotion.emoji
    }
}

