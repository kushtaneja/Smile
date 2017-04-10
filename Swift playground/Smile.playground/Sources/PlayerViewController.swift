//
//  PlayerViewController.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit
import CoreGraphics

public protocol PlayerViewControllerDelegate{
    func emotionChanged(withEmoji: String)
}

class PlayerViewController: UIViewController, CAAnimationDelegate{
    
    enum Defaults {
        static let prizeTimerInterval: TimeInterval = 2
        
        static let animationIDKey = "id"

        static let strokeEndAnimationKey = "strokeEnd"
        
        static let increaseWinRingAnimationValue = "increaseWinRingAnimationValue"
        
        static let emotionCollectionViewCellIdentifier = "EmotionCollectionViewCellIdentifier"
    }

    var game: Game{
        
        didSet {

            let playerColor = game.myColor.cgColor
            player.color = game.myColor
            roundsWonLayer.strokeColor = playerColor
            trackShapeLayer.strokeColor = game.outerRingColor.cgColor
            emotionView.label.textColor = player.color
            innerCircleShapeLayer.fillColor = game.innerCircleColor.cgColor
            prizeLabel?.text = game.prize
            displayableEmotions = game.emotions
            
            emotionCollectionView.reloadData()
            
            guard game.emotions.count > 0 else {
                return
            }
            emotion = game.emotions.first!
        }
    }
    
    let player: Player
    
    var delegate: PlayerViewControllerDelegate?
    
    let emotionView = EmotionView()
    
    private let ringGradientMaskLayer = CAGradientLayer()
    
    let roundsWonLayer = CAShapeLayer()
    
    let innerCircleShapeLayer = CAShapeLayer()
    
    let trackShapeLayer = CAShapeLayer()
    
    var prizeLabel: UILabel?
    
    private var winnerParticleView: BubbleParticleView?

    private var winnerTimer: Timer?

    var ringTrackMultiplier: CGFloat = 0
    
    var ringTrackStrokeWidth: CGFloat = 0

    var innerCircleMultiplier: CGFloat = 0
    
    var emotion: Emotion
    
    fileprivate var lastScrollX: CGFloat = 0
    
    fileprivate var currentCenterIndexPath: IndexPath?
    
    fileprivate var emotionCollectionView: UICollectionView
    
    fileprivate let emotionCollectionViewFlowLayout = HorizontalCollectionViewFlowLayout()
    
    private var previousRandomEmotion: Emotion?
    
    private var panGestureRecognizer: UIPanGestureRecognizer!
    
    fileprivate var displayableEmotions = [Emotion]()
    

    init(player: Player, game: Game) {
        self.player = player
        self.game = game
        self.emotion = Emotion()
        
        emotionCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: emotionCollectionViewFlowLayout)
        innerCircleMultiplier = 0.71
        ringTrackMultiplier = 0.12

        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        func path(withRadius radius: CGFloat) -> CGPath {
            let centerPoint = CGPoint(x: view.frame.width / 2 , y: view.frame.height / 2)
            return UIBezierPath(arcCenter:centerPoint, radius: radius, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(M_PI_2 * 3), clockwise: true).cgPath
            
        }
        
        ringTrackStrokeWidth = floor(view.bounds.width * ringTrackMultiplier)
        
        let defaultRadius = floor((view.bounds.width - ringTrackStrokeWidth) / 2)
        let innerCircleSize = floor(view.bounds.width * innerCircleMultiplier)
        
        innerCircleShapeLayer.path = path(withRadius: (innerCircleSize / 2))
        
        trackShapeLayer.path = path(withRadius: defaultRadius)
        trackShapeLayer.lineWidth = ringTrackStrokeWidth
        
        roundsWonLayer.path = path(withRadius: defaultRadius)
        roundsWonLayer.lineWidth = ringTrackStrokeWidth
        roundsWonLayer.strokeEnd = completionPercentage(withWins: player.winCount)
        
        
        
        emotionCollectionView.layer.cornerRadius = emotionCollectionView.bounds.width / 2.0
        if !emotionCollectionViewFlowLayout.itemSize.equalTo(emotionCollectionView.bounds.size) {
            emotionCollectionViewFlowLayout.itemSize = emotionCollectionView.bounds.size
            
            var rect = CGRect.zero
            rect.origin = emotionCollectionView.contentOffset
            rect.size = emotionCollectionViewFlowLayout.itemSize
            _ = emotionCollectionViewFlowLayout.shouldInvalidateLayout(forBoundsChange: rect)
            
            emotionCollectionViewFlowLayout.invalidateLayout()
            emotionCollectionViewFlowLayout.updateContentOffsetIfNeeded()
        }

    }

    func setupViews() {
        view.layer.addSublayer(trackShapeLayer)
        trackShapeLayer.fillColor = nil
        trackShapeLayer.strokeColor = game.outerRingColor.cgColor
        trackShapeLayer.strokeStart = 0.0
        trackShapeLayer.strokeEnd = 1
        trackShapeLayer.opacity = 0.7
        
        view.layer.addSublayer(innerCircleShapeLayer)
        innerCircleShapeLayer.lineWidth = 1
        innerCircleShapeLayer.strokeColor = UIColor(white: 0.85, alpha: 1).cgColor
        innerCircleShapeLayer.fillColor = game.innerCircleColor.cgColor
        
        let playerColor = player.color.cgColor

        roundsWonLayer.strokeColor = playerColor
        roundsWonLayer.lineCap = kCALineCapRound
        roundsWonLayer.fillColor = nil
        view.layer.addSublayer(roundsWonLayer)

        view.addSubview(emotionView)
        emotionView.translatesAutoresizingMaskIntoConstraints = false
        emotionView.label.textColor = player.color
        emotionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emotionView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        emotionView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: innerCircleMultiplier).isActive = true
        emotionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: innerCircleMultiplier).isActive = true
        
        
        emotionView.isHidden = true
        emotionCollectionViewFlowLayout.scrollDirection = .horizontal
        emotionCollectionViewFlowLayout.minimumLineSpacing = 0
        emotionCollectionViewFlowLayout.minimumInteritemSpacing = 0
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(viewPanned))
        emotionView.addGestureRecognizer(panGestureRecognizer)
        
        view.addSubview(emotionCollectionView)
        emotionCollectionView.translatesAutoresizingMaskIntoConstraints = false
        emotionCollectionView.showsVerticalScrollIndicator = false
        emotionCollectionView.showsHorizontalScrollIndicator = false
        emotionCollectionView.alwaysBounceHorizontal = true
        emotionCollectionView.register(EmotionCollectionViewCell.self, forCellWithReuseIdentifier: Defaults.emotionCollectionViewCellIdentifier)
        
        emotionCollectionView.delegate = self
        emotionCollectionView.dataSource = self
        emotionCollectionView.leadingAnchor.constraint(equalTo: emotionView.leadingAnchor).isActive = true
        emotionCollectionView.trailingAnchor.constraint(equalTo: emotionView.trailingAnchor).isActive = true
        emotionCollectionView.topAnchor.constraint(equalTo: emotionView.topAnchor).isActive = true
        emotionCollectionView.bottomAnchor.constraint(equalTo: emotionView.bottomAnchor).isActive = true
        emotionCollectionView.backgroundColor = UIColor.clear

    }
    
    func resetToDefault() {
        emotionView.alpha = 1
        view.alpha = 1
        prizeLabel?.removeFromSuperview()
        prizeLabel = nil
        winnerTimer?.invalidate()
        winnerTimer = nil
        
        emotionCollectionView.alpha = 1
        var addEmotion = emotion
        if player.isRandom, let previousRandomEmotion = previousRandomEmotion {
            addEmotion = previousRandomEmotion
        }
        
        emotion = addEmotion
    }
    
    func prepareViewsForCurrentStatus() {
    
        
        let playGame = game.status != .ready && game.status != .end
        emotionCollectionView.isHidden = playGame
        emotionView.isHidden = !playGame
        
        guard playGame else {
            player.isRandom = false
            return
        }
        
        var row: Int = -1
        
        if let indexPath = emotionCollectionViewFlowLayout.updateContentOffset() {
            row = indexPath.row
        }
        
        if row > -1 {
            emotion = displayableEmotions[row]
            
            if emotion.type == .random {
                player.isRandom = true
            }
            
            previousRandomEmotion = player.isRandom ? emotion : nil
        }

    }
    
    private func completionPercentage(withWins winCount: UInt) -> CGFloat {
        return CGFloat(winCount)
    }
    

    func gameEnded() {

        winnerTimer = Timer.scheduledTimer(withTimeInterval: Defaults.prizeTimerInterval, repeats: false) { _ in
            self.emotionView.alpha = 0
            
            let prizeLabel = UILabel()
            self.prizeLabel = prizeLabel
            self.view.addSubview(prizeLabel)
            
            prizeLabel.translatesAutoresizingMaskIntoConstraints = false
            prizeLabel.centerXAnchor.constraint(equalTo: self.emotionView.centerXAnchor).isActive = true
            prizeLabel.centerYAnchor.constraint(equalTo: self.emotionView.centerYAnchor).isActive = true
            prizeLabel.widthAnchor.constraint(equalTo: self.emotionView.widthAnchor, multiplier: 0.7).isActive = true
            prizeLabel.heightAnchor.constraint(equalTo: self.emotionView.heightAnchor, multiplier: 0.7).isActive = true
            prizeLabel.font = UIFont.systemFont(ofSize: 300, weight: 5)
            prizeLabel.text = self.game.prize
            prizeLabel.adjustsFontSizeToFitWidth = true
            prizeLabel.minimumScaleFactor = 0.01
            prizeLabel.textAlignment = .center
            prizeLabel.baselineAdjustment = .alignCenters
            prizeLabel.numberOfLines = 1
            prizeLabel.transform = prizeLabel.transform.scaledBy(x: 0.1, y: 0.1)
            
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 8, options: .curveEaseInOut, animations: {
                prizeLabel.transform = prizeLabel.transform.scaledBy(x: 10, y: 10)
            })
        }
    }
    
    func increaseWinCount() {
        let animation = CABasicAnimation(keyPath: Defaults.strokeEndAnimationKey)
        animation.beginTime = CACurrentMediaTime()
        animation.duration = 0.3
        animation.fromValue = completionPercentage(withWins: player.winCount)
        animation.delegate = self
        animation.setValue(Defaults.increaseWinRingAnimationValue, forKey: Defaults.animationIDKey)
        player.winCount += 1
        animation.toValue = completionPercentage(withWins: player.winCount)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        roundsWonLayer.strokeEnd = completionPercentage(withWins: player.winCount)
        roundsWonLayer.add(animation, forKey: Defaults.strokeEndAnimationKey)
    }
    
    func animateFullRing() {
        let animation = CABasicAnimation(keyPath: Defaults.strokeEndAnimationKey)
        animation.beginTime = CACurrentMediaTime() + 1
        animation.duration = 0.5
        animation.delegate = self
        animation.setValue(Defaults.increaseWinRingAnimationValue, forKey: Defaults.animationIDKey)
        animation.fillMode = kCAFillModeForwards
        animation.fromValue = completionPercentage(withWins: player.winCount)
        animation.isRemovedOnCompletion = false
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        roundsWonLayer.add(animation, forKey: Defaults.strokeEndAnimationKey)
    }
    
    func reset() {
        let animationDuration = 0.8
        
        if let winnerParticleView = winnerParticleView {
            UIView.animate(withDuration: animationDuration, animations: {
                winnerParticleView.alpha = 0
            }) { _ in
                winnerParticleView.removeFromSuperview()
                self.winnerParticleView = nil
            }
        }
        
        let animation = CABasicAnimation(keyPath: Defaults.strokeEndAnimationKey)
        animation.duration = animationDuration
        animation.fromValue = completionPercentage(withWins: player.winCount)
        
        player.winCount = 0
        animation.toValue = 0
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        roundsWonLayer.strokeEnd = completionPercentage(withWins: player.winCount)
        roundsWonLayer.add(animation, forKey: Defaults.strokeEndAnimationKey)
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
  
        let animationId = anim.value(forKey: Defaults.animationIDKey) as? String
    
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        var emitterColor = player.color
        
        if player.color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            emitterColor = UIColor(hue: hue * 0.95, saturation: saturation, brightness: brightness, alpha: alpha)
        }

        let winnerParticleView = BubbleParticleView(frame: view.bounds, color: emitterColor)
        self.winnerParticleView = winnerParticleView
        
        winnerParticleView.birthrate = Float(round(view.bounds.width * 0.06))
        winnerParticleView.scaleRange = CGFloat(round(view.bounds.width * 0.010))
//        winnerParticleView.isUserInteremotionEnabled = false
        
        if !emotionView.label.isHidden {
            view.insertSubview(winnerParticleView, belowSubview: emotionView)
        }
        else {
            view.addSubview(winnerParticleView)
        }
        
        winnerParticleView.translatesAutoresizingMaskIntoConstraints = false
        winnerParticleView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        winnerParticleView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        winnerParticleView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        winnerParticleView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        winnerParticleView.alpha = 0
        
        UIView.animate(withDuration: 0.6) {
            winnerParticleView.alpha = 1
        }
    }
    
    
    
    private func userWantsToContinuePlay() {
        if game.status == .end || game.status == .end {
//            delegate?.humanPlayerViewControllerUserWantsToContinuePlay(self)
        }
    }
    
    @objc private func viewTapped(_ tapRecognizer: UITapGestureRecognizer) {
        if game.status == .ready {
            let touchPoint = tapRecognizer.location(in: view)
            let isForward = touchPoint.x > (view.bounds.size.width / 2)
//            changeEmotion(forward: isForward)
        }
        else if game.status == .end || game.status == .end{
            userWantsToContinuePlay()
        }
    }
    
    @objc private func viewPanned(_ panRecognizer: UIPanGestureRecognizer) {
        if game.status == .end || game.status == .end {
            userWantsToContinuePlay()
        }
    }

    
    func changeEmotion(forward: Bool = true,completion: @escaping ((Void) -> Void)){

        let contentOffset = emotionCollectionView.contentOffset
        let itemWidth = emotionCollectionViewFlowLayout.itemSize.width
        let offsetRemainder = contentOffset.x.truncatingRemainder(dividingBy: itemWidth)
        var newContentOffset = emotionCollectionView.contentOffset
        
        if offsetRemainder == 0 || itemWidth - offsetRemainder < 1 {
            if forward {
                newContentOffset.x += itemWidth
            }
            else {
                newContentOffset.x -= itemWidth
            }
        }
        else {
            if forward {
                newContentOffset.x += (itemWidth - offsetRemainder)
            }
            else {
                newContentOffset.x -= offsetRemainder
            }
        }
        
        
        emotionCollectionView.setContentOffset(newContentOffset, animated: true)
        completion()
    }
    
    func presentEmoji()->String{
            let cell = emotionCollectionView.visibleCells.first as! EmotionCollectionViewCell
            let presentEmoji = cell.emotion.emoji
            return presentEmoji
    }
    
}

extension PlayerViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        var centerPoint = scrollView.center
        centerPoint = scrollView.convert(centerPoint, from: scrollView.superview)
        
        guard let centerIndexPath = emotionCollectionView.indexPathForItem(at: centerPoint) else {
            return
        }
        
        
        currentCenterIndexPath = centerIndexPath
        var emoji = "🙏"
//        if currentCenterIndexPath != nil {
//            emoji = (emotionCollectionView.cellForItem(at: currentCenterIndexPath!) as! EmotionCollectionViewCell).emotion.emoji
//        }
         delegate?.emotionChanged(withEmoji: emoji)
    }
    
    
}

extension PlayerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayableEmotions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: Defaults.emotionCollectionViewCellIdentifier, for: indexPath) as! EmotionCollectionViewCell
        collectionViewCell.emotion = displayableEmotions[indexPath.row]
        collectionViewCell.emotionView.label.textColor = player.color
        
        return collectionViewCell
    }
}
