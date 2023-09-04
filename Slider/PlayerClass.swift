//
//  PlayerClass.swift
//  Slider
//  Lost Path Games
//
//  Created by Christopher Conley on 10/20/16.
//  Copyright © 2016 Lost Path Games. All rights reserved.
//

import Foundation
import SpriteKit


class PlayerClass {
    
    //player sprite
    var playerTexture: SKTexture!
    var playerSprite: SKSpriteNode!
    
    //animations
    var carStopped: SKAction!
    var carAnimation: SKAction!
    var carSpeed: CGFloat = 0.0
    
    //control variables
    private var playerScale: CGFloat = 0.08
    private var gameRunning: Bool = true

    //control constants
    private let playerTextureName: String = "car_stopped"
    private let carRun1: String = "car_go1"
    private let carRun2: String = "car_go2"
    
    private let playerPosY: CGFloat = 0.15
    private let wheelSize: CGFloat = 6.0
    private var startSpeed: CGFloat!
    
    private let actionLayer: CGFloat = 1.0
    private let playerCat: UInt32 = 1 << 0
    private let blockCat: UInt32 = 1 << 2 // update to look the block class when it's made
    
    //endgine sounds
    private var playerSnds: SKNode!
    private var engineSnd: SKAudioNode!
    private var crashSnd: SKAudioNode!
    
    //private var engineSnd: AVAudioPlayer!
    private let engineMp3: String = "engine.mp3"
    private let crashMp3: String = "crash.mp3"
    
    
    
    //initializing player
    init(speed: CGFloat, scrollSpeed: CGFloat) {
        
        startSpeed = speed
        gameRunning = true
        
        //set up texture
        playerTexture = SKTexture(imageNamed: playerTextureName)
        playerTexture.filteringMode = .nearest
        
        //set up sprite
        playerSprite = SKSpriteNode(texture: playerTexture)
        playerScale = UIScreen.main.bounds.width * playerScale / playerTexture.size().width
        playerSprite.setScale(playerScale)
        playerSprite.zPosition = actionLayer
        playerSprite.position = CGPoint(
            x: UIScreen.main.bounds.width / 2.0,
            y: UIScreen.main.bounds.height * playerPosY)
        
        //set up physics
        playerSprite.physicsBody = SKPhysicsBody(texture: playerTexture, size: playerSprite.size)
        playerSprite.physicsBody?.isDynamic = true
        playerSprite.physicsBody?.allowsRotation = false
        
        //set collision properties
        playerSprite.physicsBody?.categoryBitMask = playerCat
        playerSprite.physicsBody?.contactTestBitMask = blockCat
        playerSprite.physicsBody?.collisionBitMask = 0
        
        //animations for car
        let car1 = SKTexture(imageNamed: carRun1)
        let car2 = SKTexture(imageNamed: carRun2)
        car1.filteringMode = .nearest
        car2.filteringMode = .nearest
        
        carAnimation = SKAction.animate(
            with: [car1,car2],
            timePerFrame: TimeInterval(wheelSize * playerScale * scrollSpeed))
        carStopped = SKAction.animate(
            with: [playerTexture],
            timePerFrame: 0.0)
        
        //create sounds
        playerSnds = SKNode()
        
    }
    
    
    //send sprites to calling process
    func sprite() -> SKSpriteNode {
        return playerSprite
    }
    
    
    //send sounds to calling process
    func sounds() -> SKNode {
        return playerSnds
    }

    
    //start player animation and sounds
    func start() {
        
        let enginePath = Bundle.main.path(forResource: engineMp3, ofType: nil)!
        let engineURL = URL(fileURLWithPath: enginePath)
        engineSnd = SKAudioNode(url: engineURL)
        engineSnd.run(SKAction.changeVolume(to: 0.1, duration: 0))
        playerSnds.addChild(engineSnd)
        engineSnd.run(SKAction.play())
        
        playerSprite.run(SKAction.repeatForever(carAnimation))
        carSpeed = startSpeed
        playerSprite.speed = 1.0
    }
    
    
    //move player right or left
    func move(right: Bool, speedModifier: CGFloat) {
        if gameRunning {
            if right {
                playerSprite.physicsBody?.velocity = CGVector(dx: carSpeed * speedModifier, dy: 0.0)
            } else {
                playerSprite.physicsBody?.velocity = CGVector(dx: -carSpeed * speedModifier, dy: 0.0)
            }
        }
    }
    
    
    //stop side movement
    func straight() {
        playerSprite.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
    }
    
    
    //stop player, road and sounds, play crash sound
    func stop() {
        
        //stop player and road animation
        playerSprite.removeAllActions()
        playerSprite.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
        playerSprite.texture = playerTexture
        playerSprite.speed = 0.0
        gameRunning = false
        
        //stop engine sound
        engineSnd.run(SKAction.stop())
        
        //set up and play crash sound
        let crashPath = Bundle.main.path(forResource: crashMp3, ofType: nil)!
        let crashURL = URL(fileURLWithPath: crashPath)
        crashSnd = SKAudioNode(url: crashURL)
        crashSnd.run(SKAction.changeVolume(to: 1.0, duration: 0))
        crashSnd.autoplayLooped = false
        playerSnds.addChild(crashSnd)
        
        crashSnd.run(SKAction.play())
        
    }


    
}


