// 
//  Speech.swift
//
//  Created by Kush Taneja on 23/03/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import AVFoundation

public struct ClampedInteger {
    private let range: ClosedRange<Int>
    private var _integer: Int
    
    var clamped: Int {
        set {
            _integer = newValue.clamped(to: range)
        }
        get {
            return _integer
        }
    }
    
    init(_ integer: Int, in range: ClosedRange<Int>) {
        self.range = range
        self._integer = integer.clamped(to: range)
    }
}

struct Constants {
    static let userValueRange: ClosedRange<Int> = 0...200
    
    static var maxUserValue: Int {
        return userValueRange.upperBound
    }
}

/// A speech class that can speak various words and have filters and effects applied to the speech.
public class Speech{
    // MARK: Properties
    
    private var _defaultVolume = ClampedInteger(clampedUserValueWithDefaultOf: 5)
    public var defaultVolume: Int {
        get { return _defaultVolume.clamped }
        set { _defaultVolume.clamped = newValue }
    }
    
    public var normalizedVolume: CGFloat {
        return CGFloat(defaultVolume) / CGFloat(Constants.maxUserValue)
    }
    
    private var _defaultSpeed = ClampedInteger(clampedUserValueWithDefaultOf: 30)
    public var defaultSpeed: Int {
        get { return _defaultSpeed.clamped }
        set { _defaultSpeed.clamped = newValue }
    }
    
    public var normalizedSpeed: CGFloat {
        return CGFloat(defaultSpeed) / CGFloat(Constants.maxUserValue)
    }
    
    private var _defaultPitch = ClampedInteger(clampedUserValueWithDefaultOf: 33)
    public var defaultPitch: Int {
        get { return _defaultPitch.clamped }
        set { _defaultPitch.clamped = newValue }
    }
    
    public var normalizedPitch: CGFloat {
        return CGFloat(defaultPitch) / CGFloat(Constants.maxUserValue)
    }
    
    // If any effect is applied on touches across the X axis.
    public var xEffect: SpeechTwist?
    
    // MARK: Private Properties
    private var speechSynthesizer = AVSpeechSynthesizer()
    
    // MARK: Initializers
    
    public init() { }
    
    public func speak(_ text: String, rate: Float = 0.6, pitchMultiplier: Float = 1.0, volume: Float = 1.0) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate
        utterance.volume = volume
        utterance.pitchMultiplier = pitchMultiplier
        speechSynthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .word)
    }
}


extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        return clamped(min: range.lowerBound, max: range.upperBound)
    }
    
    func clamped(min: Int, max: Int) -> Int {
        return Swift.max(min, Swift.min(max, self))
    }
}

extension ClampedInteger {
    init(clampedUserValueWithDefaultOf integer: Int) {
        self.init(integer, in: Constants.userValueRange)
    }
}
