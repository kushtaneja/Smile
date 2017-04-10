// 
//  SpeechTwist.swift
//
//  Created by Kush Taneja on 23/03/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import AVFoundation

/**
 An enum of different twists that can be applied to an instrument.
 These can be pitch, speed, and volume.
 */
public enum SpeechTwistType {
    case pitch, speed, volume
    
    // The range that the particular twist modifier can be between.
    var twistRange: ClosedRange<Float> {
        switch self {
        case .pitch:
            return 0.5 ... 2.0
        case .speed:
            return 0.1 ... 2.0
        case .volume:
            return 0.0 ... 1.0
        }
    }
}

/// This class provides effects to twist how the speech sounds.
public struct SpeechTwist {
    
    var type: SpeechTwistType
    
    private var valueRange: ClosedRange<Int>
    
    /// Create an speech twist whose effect varies by the values (from 0 to 100). Depending on where you tap on the keyboard it will apply a different value within the range.
    public init(type: SpeechTwistType, effectFrom startValue: Int, to endValue: Int) {
        self.type = type
        
        let firstValue = startValue.clamped(to: Constants.userValueRange)
        let secondValue = endValue.clamped(to: Constants.userValueRange)
        if firstValue < secondValue {
            self.valueRange = firstValue...secondValue
        } else {
            self.valueRange = secondValue...firstValue
        }
    }
    
    // When passed in a normalized value between 0 to 1, places it within the user's specified valueRange and then converts that to the actual value for the underlying speech twist.
    func twistValue(fromNormalizedValue normalizedValue: CGFloat) -> Float {
        let valueRangeCount = CGFloat(valueRange.count)
        let normalizedValueInDefinedRange = ((normalizedValue * valueRangeCount) + CGFloat(valueRange.lowerBound)) / CGFloat(Constants.userValueRange.count)
        
        return SpeechTwist.twist(normalizedValue: normalizedValueInDefinedRange, forType: type)
    }
    
    public static func twist(normalizedValue: CGFloat, forType type: SpeechTwistType) -> Float {
        let twistRange = type.twistRange
        return (Float(normalizedValue) * (twistRange.upperBound - twistRange.lowerBound)) + twistRange.lowerBound
    }
}

