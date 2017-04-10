//: Playground - noun: a place where people can play
import CoreGraphics
import PlaygroundSupport

//#-hidden-code
//
//  Contents.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//
//#-end-hidden-code
/*:
 # Rock, Paper, Scissors (Roshambo!)
 Rock, Paper, Scissors is a game for two players—you and a robot opponent. Each player chooses an action that represents an object (rock ✊, paper 🖐, or scissors✌️), and each action beats one of the other actions:
 * ✊ beats ✌️ (rock crushes scissors)
 * ✌️ beats 🖐 (scissors cut paper)
 * 🖐 beats ✊ (paper covers rock)
 
 The robot opponent chooses actions randomly.
 
 If both players choose the same action, that round ends in a tie. The first player to win three rounds wins the game.
 
 When you’re ready, move on to the next page to personalize your game.
 */
//#-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(literal, show, array, boolean, color, integer, string)
//#-code-completion(bookauxiliarymodule, show)
//#-code-completion(identifier, show, if, for, while, func, var, let, ., =, (, ))
//#-code-completion(identifier, hide, GameViewController, viewController, GameResult, Game, Action, canPlay, Play())


let viewController = GameViewController.makeFromStoryboard()
PlaygroundPage.current.liveView = viewController
//#-end-hidden-code
let game = Game()
//#-editable-code
game.loadDefaultSettings()
game.play()
//#-end-editable-code
//#-hidden-code
// Actions for the game.

let emojiFactory = EmojiFactory()

for emoji in emojiFactory.get(emojisOf: 10){
    let emotion = game.addEmotion(emoji)
}

if game.canPlay && game.useDefaults {
    viewController.game = game
}
//#-end-hidden-code
