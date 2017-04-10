//
//  GameViewController.swift
//  Smile
//
//  Created by Kush Taneja on 23/03/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import CoreGraphics
//import PlaygroundSupport



/// Game comparison possible outcomes.
enum GameResult {
    case win
    case lose
}

enum GameError {
    case noError
    case noEmotionsDefined
    case cameraNotAllowed
}

public class GameViewController: UIViewController,PlayerViewControllerDelegate{
    
    public static func makeFromStoryboard() -> GameViewController {
        let bundle = Bundle(for: GameViewController.self)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        
        return storyboard.instantiateInitialViewController() as! GameViewController
    }
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    private let pauseView = UIView()
    
    private let emojiFactory = EmojiFactory()
    
    private let speech = Speech()
    
    
    
    fileprivate var visage : Visage?
    
    fileprivate let notificationCenter : NotificationCenter = NotificationCenter.default
    
    var gameError = GameError.noError
    
    
    public var game = Game() {
        didSet {
            if isGameEnded{
                let cameraView = visage!.visageCameraView
                cameraView.removeFromSuperview()
            }
            self.gameFreeze = true
            self.scoreUpdated = true
            scoreCount = 0
            updateViews()
            setupViews()
        }
    }
    
    private var status: GameStatus {
        set {
            game.status = newValue
        }
        get {
            return game.status
        }
    }
    
    private enum Defaults {
        static let numberOfRandomDraw = 10
        
        static let tieText = "TIE"
        
        static let winText = "YOU WIN"
        
        static let loseText = "YOU LOSE"
        
        static let nextRoundEmotionText = "Next Round"
        
        static let newGameEmotionText = "New Game"
        
        static let tryAgainEmotionText = "Try Again"
        
        static let volume = SpeechTwist.twist(normalizedValue: CGFloat(Speech().defaultVolume), forType: .volume)
        static let rate = SpeechTwist.twist(normalizedValue: Speech().normalizedSpeed, forType: .speed)
        static let pitch = SpeechTwist.twist(normalizedValue: Speech().normalizedPitch, forType: .pitch)
        
    }
    
    private var randomEmotionTimer: Timer?
    
    private var displayWinnersTimer: Timer?
    
    private var shouldInitializeFonts = true
    
    private var scoreUpdated = true
    
    private var cameraFlipButton = UIButton(frame: CGRect.zero)
    
    private var gamePauseButton = UIButton(frame: CGRect.zero)
    
    private var playAgainButton = UIButton(frame: CGRect.zero)
    
    private var scoreLabel = UILabel()
    
    private var scoreCount = 0
    
    private var checkIcon = CustomCheckIcon()
    
    private let contentLayoutGuide = UILayoutGuide()
    
    private var gameTimer: Timer?
    
    private var seconds: Int = 0
    
    private var timerLabel = UILabel()
    
    private var visualEffectView = UIVisualEffectView()
    
    private var cameraFlipped: Bool = true
    
    private var isGameEnded: Bool = false
    
    private var cameraPosition: Visage.CameraDevice = .faceTimeCamera
    
    private let playerViewController: PlayerViewController
    
    private var gameFreeze: Bool = false
    
    
    
    private let player = Player(color: #colorLiteral(red: 0, green: 0.6392156863, blue: 0.8509803922, alpha: 1), gender: .male)
    
    public required init?(coder aDecoder: NSCoder) {
        playerViewController = PlayerViewController(player: player, game: game)
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //        _ = SoundEffectsManager.default
        
        #if DEBUG
            setupGame()
        #endif
        
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    
    @objc private func setupGame() {
        let game = Game()
        
        for emoji in emojiFactory.get(emojisOf: 20){
            let emotion = game.addEmotion(emoji)
        }
        
        // Rules for the emotions.
        
        // rock.beats([doubleScissors, scissors])
        
        // Configurations for the game.
        game.prize = "🍦"
        
        // Colors for the game.
        game.outerRingColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        game.myColor = #colorLiteral(red: 0.960784316062927, green: 0.705882370471954, blue: 0.200000002980232, alpha: 1.0)
        game.innerCircleColor = UIColor.clear
        game.mainButtonColor = #colorLiteral(red: 0.952941179275513, green: 0.686274528503418, blue: 0.133333340287209, alpha: 1.0)
        game.backgroundColors = [#colorLiteral(red: 0.474509805440903, green: 0.839215695858002, blue: 0.976470589637756, alpha: 1.0), #colorLiteral(red: 0.976470589637756, green: 0.850980401039124, blue: 0.549019634723663, alpha: 1.0)]
        
        self.game = game
        playerViewController.game = game
        game.play()
        self.runTimer()
    }
    
    private func runTimer(){
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(updatTimer), userInfo: nil, repeats: true)
    }
    
    @objc private func updatTimer(){
        if (status != .pause && seconds != 60){
            seconds += 1
            timerLabel.text = "TIME: \(seconds)"
        }else if seconds == 60{
            gameTimer?.invalidate()
            self.gameEnded()
        }else{
            gameTimer?.invalidate()
        }
    }
    
    private func updateViews() {
        //Setup "Visage" with a camera-position (iSight-Camera (Back), FaceTime-Camera (Front)) and an optimization mode for either better feature-recognition performance (HighPerformance) or better battery-life (BatteryLife)
        visage = Visage(cameraPosition: cameraPosition, optimizeFor: Visage.DetectorAccuracy.higherPerformance)
        
        //If you enable "onlyFireNotificationOnStatusChange" you won't get a continuous "stream" of notifications, but only one notification once the status changes.
        visage!.onlyFireNotificatonOnEmotionChange = true
        
        if cameraFlipped{
            //You need to call "beginFaceDetection" to start the detection, but also if you want to use the cameraView.
            visage!.beginFaceDetection()
            //This is a very simple cameraView you can use to preview the image that is seen by the camera.
            let cameraView = visage!.visageCameraView
            self.view.insertSubview(cameraView, at: 0)
            cameraFlipped = isGameEnded ? true : false
        }else if !cameraFlipped{
            visage!.endFaceDetection()
        }
        self.updateTransparency()
    }
    
    private func setupViews(){
        
        super.viewDidLoad()
        
        if !isGameEnded{
            visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            visualEffectView.frame = self.view.bounds
            self.view.addSubview(visualEffectView)
        }else{
            playAgainButton.removeFromSuperview()
            scoreLabel.isHidden = true
            scoreLabel.transform = .identity
            scoreLabel.removeFromSuperview()
            
        }
        //Subscribing to the "visageFaceDetectedNotification" (for a list of all available notifications check out the "ReadMe" or switch to "Visage.swift") and reacting to it with a completionHandler. You can also use the other .addObserver-Methods to react to notifications.
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "visageFaceDetectedNotification"), object: nil, queue: OperationQueue.main, using: { notification in
            self.gameFreeze = false
            self.updateTransparency()
        })
        
        //The same thing for the opposite, when no face is detected things are reset.
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "visageNoFaceDetectedNotification"), object: nil, queue: OperationQueue.main, using: { notification in
            self.gameFreeze = true
            self.updateTransparency()
        })
        
        
        
        /*
         NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "visageLeftEyeClosedNotification"), object: nil, queue: OperationQueue.main, using: { notification in
         
         debugPrint("visageLeftEyeClosedNotification Recieved")
         
         self.visage!.onlyFireNotificatonOnEmotionChange = false
         
         let currentEmoji = self.playerViewController.changeEmotion(forward: false) {
         Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in
         self.visage!.onlyFireNotificatonOnEmotionChange = true
         })
         
         }
         
         })
         NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "visageRightEyeClosedNotification"), object: nil, queue: OperationQueue.main, using: { notification in
         
         debugPrint("visageRightEyeClosedNotification Recieved")
         
         self.visage!.onlyFireNotificatonOnEmotionChange = false
         
         let currentEmoji = self.playerViewController.changeEmotion() {
         Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in
         self.visage!.onlyFireNotificatonOnEmotionChange = true
         })
         
         }
         
         })
         
         NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "visageBlinkingNotification"), object: nil, queue: OperationQueue.main, using: { notification in
         
         debugPrint("Blinking Notification Recieved")
         
         self.visage!.onlyFireNotificatonOnEmotionChange = false
         
         let currentEmoji = self.playerViewController.changeEmotion {
         Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in
         self.visage!.onlyFireNotificatonOnEmotionChange = true
         })
         
         }
         
         })
         NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "visageNotBlinkingNotification"), object: nil, queue: OperationQueue.main, using: { notification in
         
         debugPrint("Not Blinking Notification Recieved")
         
         self.visage!.onlyFireNotificatonOnEmotionChange = false
         
         let currentEmoji = self.playerViewController.changeEmotion(forward: false) {
         Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in
         self.visage!.onlyFireNotificatonOnEmotionChange = true
         })
         
         }
         
         })
         */
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "visageHasSmileNotification"), object: nil, queue: OperationQueue.main, using: { notification in
            self.visage!.onlyFireNotificatonOnEmotionChange = true
            
            if (!self.gameFreeze && self.scoreUpdated){
                self.playerViewController.changeEmotion { }
            }
            // speech.speak("Emoji Changed", rate: rate, pitchMultiplier: pitch, volume: volume)
            
            self.playerViewController.emotionView.label.isAccessibilityElement = true
        })
        /*
         
         EmojiFactory().query(currentEmoji, completion: { (emojiResult:[Emoji]) in
         
         for emoji in emojiResult{
         //  let i = random(min: 0, max: emoji.tags.count-1)
         if emoji.tags.isEmpty{
         if emoji.aliases.isEmpty{
         // self.speech.speak("Emoji Changed", rate: Defaults.rate, pitchMultiplier: Defaults.pitch, volume: Defaults.volume)
         }else{
         //  self.speech.speak(emoji.aliases[0], rate: Defaults.rate, pitchMultiplier: Defaults.pitch, volume: Defaults.volume)
         }
         }else{
         // self.speech.speak(emoji.tags[0], rate: Defaults.rate, pitchMultiplier: Defaults.pitch, volume: Defaults.volume)
         }
         }
         })
         
         */
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "visageHasNoSmileNotification"), object: nil, queue: OperationQueue.main, using: { notification in
            
            self.visage!.onlyFireNotificatonOnEmotionChange = true
            if (!self.gameFreeze && self.scoreUpdated){
                self.playerViewController.changeEmotion { }
            }
        })
        
        view.addLayoutGuide(contentLayoutGuide)
        contentLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentLayoutGuide.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        playerViewController.delegate = self
        let playerView = playerViewController.view!
        playerView.translatesAutoresizingMaskIntoConstraints = false
        addChildViewController(playerViewController)
        
        view.addSubview(playerView)
        playerView.isUserInteractionEnabled = false
        self.playerViewController.view.alpha = !gameFreeze ? 1 : 0.25
        playerViewController.didMove(toParentViewController: self)
        playerView.centerXAnchor.constraint(equalTo: contentLayoutGuide.centerXAnchor).isActive = true
        playerView.centerYAnchor.constraint(equalTo: contentLayoutGuide.centerYAnchor).isActive = true
        
        switch UIDevice.current.orientation {
        case .landscapeLeft,.landscapeRight:
            playerView.widthAnchor.constraint(equalTo: playerView.heightAnchor).isActive = true
            playerView.heightAnchor.constraint(equalTo: contentLayoutGuide.heightAnchor, multiplier: 0.62).isActive = true
        default:
            playerView.heightAnchor.constraint(equalTo: playerView.widthAnchor).isActive = true
            playerView.widthAnchor.constraint(equalTo: contentLayoutGuide.widthAnchor, multiplier: 0.62).isActive = true
        }
        
        view.addSubview(cameraFlipButton)
        cameraFlipButton.addTarget(self, action: #selector(cameraFliped), for: .touchUpInside)
        cameraFlipButton.translatesAutoresizingMaskIntoConstraints = false
        cameraFlipButton.setBackgroundImage(UIImage(named:"backFlip"), for: .normal)
        cameraFlipButton.isEnabled = true
        cameraFlipButton.tintColor = UIColor.white
        cameraFlipButton.isUserInteractionEnabled = true
        cameraFlipButton.alpha = !gameFreeze ? 0.8 : 0.25
        cameraFlipButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        cameraFlipButton.widthAnchor.constraint(equalTo: cameraFlipButton.heightAnchor).isActive = true
        cameraFlipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0).isActive = true
        cameraFlipButton.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -16).isActive = true
        
        view.addSubview(gamePauseButton)
        gamePauseButton.addTarget(self, action: #selector(animatePauseButton), for: .touchUpInside)
        gamePauseButton.translatesAutoresizingMaskIntoConstraints = false
        gamePauseButton.setBackgroundImage(UIImage(named:"pause"), for: .normal)
        gamePauseButton.tintColor = UIColor.white
        gamePauseButton.alpha = 0.8
        gamePauseButton.isUserInteractionEnabled = true
        gamePauseButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        gamePauseButton.widthAnchor.constraint(equalTo: gamePauseButton.heightAnchor).isActive = true
        gamePauseButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0).isActive = true
        gamePauseButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16.0).isActive = true
        
        view.addSubview(scoreLabel)
        scoreLabel.isHidden = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.alpha = 0.6
        scoreLabel.textAlignment = .center
        scoreLabel.centerXAnchor.constraint(equalTo: contentLayoutGuide.centerXAnchor).isActive = true
        scoreLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16.0).isActive = true
        let scoreLabelfontSize = CGFloat(40.0)
        let scoreLabelFont = UIFont.systemFont(ofSize: scoreLabelfontSize, weight:10)
        scoreLabel.font = scoreLabelFont
        scoreLabel.textColor = UIColor.white
        scoreLabel.text = "0"
        
        
        view.addSubview(timerLabel)
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.alpha = 0.6
        timerLabel.textAlignment = .center
        timerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0).isActive = true
        timerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 29.0).isActive = true
        let timerLabelfontSize = CGFloat(14)
        let timerLabelFont = UIFont.systemFont(ofSize: timerLabelfontSize, weight:10)
        timerLabel.font = timerLabelFont
        timerLabel.textColor = UIColor.white
        timerLabel.text = "TIME: 0"
        isGameEnded = false
    }
    
    private func updateTransparency(){
        self.playerViewController.view.alpha = !gameFreeze ? 0.8 : 0.25
        cameraFlipButton.alpha = !(status == .pause) ? 0.8 : 0.25
        cameraFlipButton.isEnabled = !(status == .pause)
    }
    
    @objc private func cameraFliped(){
        switch cameraPosition {
        case .faceTimeCamera:
            cameraPosition = .iSightCamera
        default:
            cameraPosition = .faceTimeCamera
        }
        //This is a very simple cameraView you can use to preview the image that is seen by the camera.
        let cameraView = visage!.visageCameraView
        cameraView.removeFromSuperview()
        visage!.endFaceDetection()
        cameraFlipped = true
        updateViews()
    }
    
    @objc private func animatePauseButton(){
        if (status == .play || status == .ready){
            status = .pause
            gameFreeze = true
            self.gamePauseButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = false
            self.gamePauseButton.widthAnchor.constraint(equalTo: self.gamePauseButton.heightAnchor).isActive = false
            self.gamePauseButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20.0).isActive = false
            self.gamePauseButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16.0).isActive = false
            UIView.animate(withDuration: 1.5, animations: {
                var t = CGAffineTransform.identity
                t = t.translatedBy(x: self.playerViewController.view.center.x - 36.0, y: self.playerViewController.view.center.y - 32.0)
                t = t.rotated(by:(CGFloat.pi))
                t = t.scaledBy(x: 2.0, y: 2.0)
                self.gamePauseButton.transform = t
            })
            self.gamePauseButton.backgroundColor = UIColor.gray
            self.gamePauseButton.layer.borderColor = UIColor.gray.cgColor
            self.gamePauseButton.layer.borderWidth = 2.0
            self.gamePauseButton.layer.cornerRadius = self.gamePauseButton.frame.size.width*0.1
            visage?.endFaceDetection()
        }else if status == .pause{
            status = .play
            
            gameFreeze = false
            UIView.animate(withDuration: 1.5, animations: {
                var t = CGAffineTransform.identity
                t = t.translatedBy(x:0.0, y:2.0)
                t = t.rotated(by: -2*(CGFloat.pi))
                self.gamePauseButton.transform = t
                
            })
            self.gamePauseButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
            self.gamePauseButton.widthAnchor.constraint(equalTo: self.gamePauseButton.heightAnchor).isActive = true
            self.gamePauseButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20.0).isActive = true
            self.gamePauseButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16.0).isActive = true
            self.gamePauseButton.backgroundColor = UIColor.clear
            self.gamePauseButton.layer.borderWidth = 0.0
            visage?.beginFaceDetection()
        }
        self.updateTransparency()
        self.runTimer()
    }
    
    private func gameEnded(){
        status = .end
        isGameEnded = true
        cameraFlipped = true
        self.seconds = 0
        self.playerViewController.animateFullRing()
        self.playerViewController.view.removeFromSuperview()
        self.playerViewController.removeFromParentViewController()
        self.gamePauseButton.removeFromSuperview()
        self.cameraFlipButton.removeFromSuperview()
        self.gameTimer?.invalidate()
        self.timerLabel.removeFromSuperview()
        self.visage?.endFaceDetection()
        self.scoreUpdated = false
        UIView.animate(withDuration: 2.0) {
            var t = CGAffineTransform.identity
            t = t.translatedBy(x:0, y: self.playerViewController.view.center.y - 30.0)
            t = t.scaledBy(x: 1.5, y: 1.5)
            self.scoreLabel.transform = t
            UIView.animate(withDuration: 1.0, delay: 0.3, options: .curveEaseOut, animations: {
                self.displayPlayAgainButton()
            }, completion: { _ in
            })
        }
    }
    
    func displayPlayAgainButton(){
        view.addSubview(self.playAgainButton)
        playAgainButton.isHidden = false
        playAgainButton.addTarget(self, action: #selector(setupGame), for: .touchUpInside)
        playAgainButton.translatesAutoresizingMaskIntoConstraints = false
        playAgainButton.setBackgroundImage(UIImage(named:"play"), for: .normal)
        playAgainButton.tintColor = UIColor.white
        playAgainButton.alpha = 0.6
        playAgainButton.isUserInteractionEnabled = true
        playAgainButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        playAgainButton.widthAnchor.constraint(equalTo: playAgainButton.heightAnchor).isActive = true
        playAgainButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        playAgainButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: self.scoreLabel.bounds.height).isActive = true
    }
    
    func updateScore(){
        scoreCount = visage?.hasSmile == true ? scoreCount + 1 : scoreCount - 1
        scoreCount = scoreCount < 0 ? 0 : scoreCount
        scoreLabel.text = "\(scoreCount)"
        self.scoreUpdated = true
    }
    
    public func emotionChanged(withEmoji: String) {
        if (!gameFreeze && scoreUpdated){
            scoreUpdated = false
            updateScore()
        }
    }
}
