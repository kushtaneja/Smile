//
//  Game.swift
//  Smile
//
//  Created by Kush Taneja on 23/03/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit


/// Different game statuses for the game.
enum GameStatus {
    case ready
    case interupted
    case play
    case pause
    case end
}

/**
 A class that contains the configurations for the game.
 
 - `emotions`: An array of emotions for the game.
 - `backgroundColors`: Gradient colors for the background of the game. A gradient stop is generated automatically for every color added to the array.
 - `changeEmotionButtonsColor`: Color for the Next and Previous buttons. If not set, `changeEmotionButtonsColor` defaults to the same color as `outerRingColor`
 - `innerCircleColor`: Color for the inner circle for all players.
 - `mainButtonColor`: Color for the main button for the game.
 - `myColor`: Color for the main player. This color shows rounds that the main player has won and is used for the particles shown when the main player wins a game.
 - `outerRingColor`: Color for the ring around the inner circle for all players.
 - `resultLabelColor`: Color for the label displayed when a round ends. If not set, `resultLabelColor` defaults to the same color as `mainButtonColor`
 - `roundsToWin`: The number of rounds a player needs to win in order to win the whole game.
 - `prize`: The emoji to show when a player wins a game.
 
 - `addEmotion(_ emoji: String)`: Create a new emotion for the game.
 - `addHiddenEmotion(_ emoji: String)`: Create a new hidden emotion for the game. A hidden emotion appears only if you’ve chosen the random emotion.
 - `addOpponent(_ emoji: String, color: UIColor)`: Add an opponent to the game. The maximum number of opponents for the game is four.
 */



public class Game{
    
    /// The emoji to show when a player wins a game.
    public var prize = "🏆"
    
    /// An array of emotions for the game.
    public var emotions = [Emotion]()

    
    /// Color for the main player. This color shows rounds that the main player has won and is used for the particles shown when the main player wins a game.
    public var myColor: UIColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.8509803922, alpha: 1)
    
    /// Color for the label displayed when a round ends. If not set, `resultLabelColor` defaults to the same color as `mainButtonColor`
    public var resultLabelColor = #colorLiteral(red: 0, green: 0.7457480216, blue: 1, alpha: 0)
    
    /// Color for the Next and Previous buttons. If not set, `changeEmotionButtonsColor` defaults to the same color as `outerRingColor`
    public var changeEmotionButtonsColor = #colorLiteral(red: 0, green: 0.7457480216, blue: 1, alpha: 0)
    
    /// Color for the main button for the game.
    public var mainButtonColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.8509803922, alpha: 1)
    
    /// Color for the ring around the inner circle for all players.
    public var outerRingColor = #colorLiteral(red: 0.7450980392, green: 0.8352941176, blue: 0.8980392157, alpha: 1)
    
    /// Color for the inner circle for all players.
    public var innerCircleColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    
    
    /// Gradient colors for the background of the game. A gradient stop is generated automatically for every color added to the array.
    public var backgroundColors = [#colorLiteral(red: 0.7843137255, green: 0.9058823529, blue: 1, alpha: 1), #colorLiteral(red: 0.9647058824, green: 0.9843137255, blue: 1, alpha: 1)]
    
    public var useDefaults = false
    
    public var canPlay = false
    
    
    var status: GameStatus = .ready
    
    var roundResult = GameResult.lose
    

    
    public init() { }
    
    
    private func addEmotion(_ emoji: String, type: EmotionType) -> Emotion {
        let emotion = Emotion(emoji, type: type)
        self.emotions += [emotion]

        return emotion
    }



    /**
     Create a new emotion for the game.
     
     - Parameters:
     - emoji: An emoji representation of the Emotion.
     
     - Returns:
     Emotion: A new emotion object with the specified emoji.
     */
    
    public func addEmotion(_ emoji: String) -> Emotion {
        return addEmotion(emoji, type: .happy)
    }
    


    /// Load default game settings.
    public func loadDefaultSettings() {
        useDefaults = true
    }
    
    /**
     Start playing the game.
     */
    public func play() {
        canPlay = true
    }


}
