//
//  GameClass.swift
//  Slider
//  Lost Path Games
//
//  Created by Christopher Conley on 11/24/16.
//  Copyright © 2016 Lost Path Games. All rights reserved.
//

import Foundation
import SpriteKit


class GameClass {
    
    //control variables
    private let minGap: CGFloat = 15.0
    private let maxGap: CGFloat = 40.0
    private var sideSize0: CGFloat = 18.0
    private var sideSize: CGFloat!
    
    private let blockTextureName = "block"
    
    private let actionLayer: CGFloat = 1.0
    private let textLayer: CGFloat = 2.0
    
    private var collision: Bool = false
    private let startTime: CGFloat = 3.0
    
    private var player: PlayerClass!
    private var road: RoadClass!
    
    private var screenSize: CGRect
    
    //scroll nodes
    private var blockNode: SKNode!
    private var gameSprites: SKNode!
    
    //SKActions
    
    //physics catagories
    private let playerCat: UInt32 = 1 << 0
    private let blockCat: UInt32 = 1 << 2
    private let sideCat: UInt32 = 1 << 1
    
    //control variables
    private let scrollVelocity:CGFloat = 4.6 / UIScreen.main.bounds.height
    private var carStartSpeed: CGFloat = 78.0
    private var blockTravel:CGFloat!
    
    //score variables
    private var scoreNumber: SKLabelNode!
    private var score = NSInteger()
    
    //sounds
    private var gameSounds: SKNode!
    private var music: SKAudioNode!
    private let musicMp3: String = "music.mp3"
    private let redLightMp3: String = "redLightSound.mp3"
    private let greenLightMp3: String = "greenLightSound.mp3"
    private let lightVolume: Float = 0.08
    
    
    
    //delay function -- redo so that it works when the game is back out of
    func delay(_ delay: CGFloat, closure: @escaping ()->()) {
        let time = DispatchTime.now() + Double(delay)
        DispatchQueue.main.asyncAfter(deadline: time) {
            closure()
        }
    }
    
    
    //initialize global variables for the game to run correctly
    init(screenRect: CGRect) {

        screenSize = screenRect
        self.road = RoadClass(scrollSpeed: self.scrollVelocity)
        self.sideSize = self.road.sideWidth()
        
        let tempBlock = self.createBlock()
        blockTravel = tempBlock.size.height + self.screenSize.height
        
        //set up sounds
        self.gameSounds = SKNode()
        self.gameSprites = SKNode()
    }
    
    
    //create the road blocks
    private func createBlock() -> SKSpriteNode {
        //define block sprite
        let blockTexture = SKTexture(imageNamed: self.blockTextureName)
        blockTexture.filteringMode = .nearest
        
        let blockSprite = SKSpriteNode(texture: blockTexture)
        blockSprite.setScale(self.screenSize.height * 0.04 / blockTexture.size().height)
        blockSprite.zPosition = self.actionLayer
        
        blockSprite.physicsBody = SKPhysicsBody(rectangleOf: blockSprite.size)
        blockSprite.physicsBody?.isDynamic = false
        blockSprite.physicsBody?.allowsRotation = false
        blockSprite.physicsBody?.categoryBitMask = self.blockCat
        blockSprite.physicsBody?.contactTestBitMask = self.playerCat
        blockSprite.physicsBody?.collisionBitMask = 0
        
        return blockSprite
    }
    
    
    //runing game
    func run() {
        
        //start running animation
        if(self.score == 0) {
            
            //hold scroll until stoplight finishes
            self.road.stopScroll()
            
            //create lights
            let lightsTexture = SKTexture(imageNamed: "lightsOff")
            lightsTexture.filteringMode = .nearest
            let lightsSprite = SKSpriteNode(texture: lightsTexture)
            lightsSprite.setScale(self.screenSize.width * 0.15 / lightsTexture.size().width)
            lightsSprite.position = CGPoint(x: self.screenSize.width / 2.0, y: self.screenSize.height
                * 2.0 / 3.0)
            lightsSprite.zPosition = self.textLayer
            lightsSprite.name = "lights"
            
            //show light
            self.delay(self.startTime * 1.0 / 5.0) {
                self.gameSprites.addChild(lightsSprite)
            }
            
            //turn top red and play sound
            self.delay(self.startTime * 2.0 / 5.0) {
                
                lightsSprite.texture = SKTexture(imageNamed: "lights1Red")
                
                let lightPath = Bundle.main.path(forResource: self.redLightMp3, ofType: nil)!
                let lightURL = URL(fileURLWithPath: lightPath)
                let lightSnd = SKAudioNode(url: lightURL)
                lightSnd.run(SKAction.changeVolume(to: self.lightVolume, duration: 0))
                lightSnd.name = "lightSound"
                
                self.gameSounds.addChild(lightSnd)
                lightSnd.run(SKAction.play())

            }
            
            //turn second light red and play sound
            self.delay(self.startTime * 3.0 / 5.0) {
                self.gameSounds.childNode(withName: "lightSound")?.run(SKAction.stop())
                
                lightsSprite.texture = SKTexture(imageNamed: "lights2Red")
                
                self.gameSounds.childNode(withName: "lightSound")?.run(SKAction.play())
            }
            
            //show green light and play green light sound/remove red light sound
            self.delay(self.startTime * 4.0 / 5.0) {
                self.gameSounds.childNode(withName: "lightSound")?.run(SKAction.stop())
                self.gameSounds.childNode(withName: "lightSound")?.removeFromParent()
                
                lightsSprite.texture = SKTexture(imageNamed: "lightsGreen")
                
                let lightPath = Bundle.main.path(forResource: self.greenLightMp3, ofType: nil)!
                let lightURL = URL(fileURLWithPath: lightPath)
                let lightSnd = SKAudioNode(url: lightURL)
                lightSnd.run(SKAction.changeVolume(to: self.lightVolume, duration: 0))
                lightSnd.name = "lightSound"
                
                self.gameSounds.addChild(lightSnd)
                lightSnd.run(SKAction.play())
            }


            //start the game moving
            self.delay(self.startTime) {
                
                //remove lights
                self.gameSprites.childNode(withName: "lights")?.removeFromParent()
                
                //show player and road animations
                self.player.start()
                self.road.startScroll()
                
                //start background music
                let musicPath = Bundle.main.path(forResource: self.musicMp3, ofType: nil)!
                let musicURL = URL(fileURLWithPath: musicPath)
                self.music = SKAudioNode(url: musicURL)
                self.music.run(SKAction.changeVolume(to: 0.0, duration: 0))
                
                self.gameSounds.addChild(self.music)
                self.music.run(SKAction.play())
                self.music.run(SKAction.changeVolume(to: 0.02, duration: 5))
                
                //start recursive block scroll
                self.accelerateGame()
            }
            
            //stop start light and remove sprite
            self.delay(self.startTime * 1.5) {
                self.gameSounds.childNode(withName: "lightSound")?.run(SKAction.stop())
                self.gameSounds.childNode(withName: "lightSound")?.removeFromParent()
            }
        }
        
        
    }
    
    
    //decide how to move player
    func movePlayer(xTouch: CGFloat) {
        
        //set side velocity in relation to scroll speed
        let speedMultC = speedUp() * 0.9
        
        //move left
        if xTouch <= screenSize.width / 2.0 {
            if player.sprite().position.x <= sideSize {  //fix the collision detection and add physics body on edges
                player.straight()
            } else {
                player.move(right: false, speedModifier: speedMultC)
            }
        }
        
        //move right
        else if xTouch > screenSize.width / 2.0 {
            if player.sprite().position.x >= (screenSize.width - sideSize) {
                player.straight()
            } else {
                player.move(right: true, speedModifier: speedMultC)
            }
        }
        
    }
    
    
    //check player position to ensure it's not in the sides
    func checkPlayerPosit() {
        
        //left side
        if player.sprite().position.x < sideSize + (player.sprite().size.width / 2.0) {
            player.straight()
            player.sprite().position.x = sideSize + 1 + (player.sprite().size.width / 2.0)
        }
        
        //right side
        if player.sprite().position.x > (screenSize.width - sideSize - (player.sprite().size.width / 2.0)) {
            player.sprite().physicsBody?.velocity = CGVector(dx: 0,dy: 0)
            player.sprite().position.x = (screenSize.width - sideSize - 1 - (player.sprite().size.width / 2.0))
        }
    }
    
    
    //setup game
    func gameSetUp() {
        //remove all children to allow reset
        self.collision = false
        
        //set up road scroll node
        self.gameSprites.addChild(self.road.rScroller())
        
        //blocks node
        self.blockNode = SKNode()
        self.gameSprites.addChild(self.blockNode)
        
        //set up the player
        self.player = PlayerClass(speed: self.carStartSpeed, scrollSpeed: self.scrollVelocity)
        self.gameSprites.addChild(player.sprite())
        self.gameSounds.addChild(player.sounds())
        
        //set up score tracking
        self.score = 0
        self.scoreNumber = SKLabelNode(fontNamed: "Arial-BoldMT")
        self.scoreNumber.text = String(self.score)
        self.scoreNumber.fontSize = 42 * self.screenSize.width / 414
        self.scoreNumber.position = CGPoint(x: screenSize.width * 0.08, y: screenSize.height * 0.94)
        self.scoreNumber.zPosition = self.textLayer
        self.gameSprites.addChild(self.scoreNumber)
        
    }
    
    
    //increase speed of game function
    private func speedUp() -> CGFloat {
        return ((-75.0) / (pow(1.8,1.4 * CGFloat(self.score)) + 15.7)) + 5.5
    }
    
    
    //randomly determine x value between a min and max
    private func randomX(min: CGFloat, max: CGFloat) -> CGFloat {
        return min + CGFloat(arc4random_uniform(UInt32(max)))
    }
    
    
    //calculate space between road blocks
    private func gap() -> CGFloat {
        return randomX(
            min: (self.screenSize.width - 2.0 * self.sideSize) * self.minGap / 100.0,
            max: (self.screenSize.width - 2.0 * self.sideSize) * self.maxGap / 100.0)
    }
    
    
    //determine location of left block
    private func leftX(gap: CGFloat) ->CGFloat {
        return randomX(
            min: self.sideSize,
            max: self.screenSize.width - self.sideSize - gap)
    }
    
    
    //straighten player travel
    func goStraight() {
        player.straight()
    }
    
    
    //stop game -- collision
    func gameStop() {
        collision = true
        road.stopScroll()
        blockNode.speed = 0.0
        self.music.run(SKAction.stop())
        self.music.removeFromParent()
        
        player.stop()
    }
    
    func getScore() -> Int {
        return self.score
    }
    
    
    //return the sprites to the main process
    func addSprites() -> SKNode {
        return gameSprites
    }
    
    
    //return the sounds to the main process
    func addSounds() -> SKNode {
        return gameSounds
    }
    
    
    //accelerate scrolling
    func accelerateGame() {
        
        var va = self.speedUp()
        
        let leftBlock = self.createBlock()
        let rightBlock = self.createBlock()
        
        //position the blocks
        let gap = self.gap()
        
        //left block x locations
        var x1 = leftX(gap: gap)
        if (x1 + gap > self.screenSize.width - self.sideSize) {
            x1 = self.screenSize.width - self.sideSize - gap
        } else if (x1 < self.sideSize) {
            x1 = self.sideSize
        }
        
        //right block x location
        var x2 = x1 + gap
        if (x2 > self.screenSize.width - self.sideSize) {
            x2 = self.screenSize.width - self.sideSize
        }
        
        //position the blocks
        let yLoc = self.screenSize.height + 0.5 * leftBlock.size.height
        leftBlock.position = CGPoint(
            x: x1 - 0.5 * leftBlock.size.width,
            y: yLoc)
        rightBlock.position = CGPoint(
            x: x1 + gap + 0.5 * rightBlock.size.width,
            y: yLoc)
        
        //enable display of blocks
        self.blockNode.addChild(leftBlock)
        self.blockNode.addChild(rightBlock)
        
        leftBlock.run(SKAction.moveBy(
            x: 0.0,
            y: -self.blockTravel,
            duration: TimeInterval(self.scrollVelocity * self.blockTravel)))
        rightBlock.run(SKAction.moveBy(
            x: 0.0,
            y: -self.blockTravel,
            duration: TimeInterval(self.scrollVelocity * self.blockTravel)))
        
        //call next block and accelerate
        self.road.accelerate(va)
        self.blockNode.speed = va
        
        let fullDelay = self.scrollVelocity / va * self.blockTravel
        
        if self.collision {
            return
        } else {
            
            self.delay(fullDelay * 2.0 / 3.0) {
                
                if self.collision {
                    return
                } else {
                    
                    // counter.removeFromParent()
                    self.accelerateGame()
                    
                    va = self.speedUp()
                    
                    self.blockNode.speed = va
                    self.road.accelerate(va)
                    
                    if self.collision {
                        return
                    } else {
                        
                        let tempV = self.scrollVelocity / va
                        let tempTR = (self.player.sprite().position.y)
                        self.delay(
                            tempV * tempTR
                            )
                        {
                            if self.collision {
                                return
                            } else {
                                self.score += 1
                                self.scoreNumber.text = String(self.score)
                            }
                        }
                        
                        self.delay(fullDelay / 3.0) {
                            if self.collision {
                                return
                            } else {
                                leftBlock.removeFromParent()
                                rightBlock.removeFromParent()
                                
                            }
                        }
                    }
                }
            }
            
        }
    }

    
    
}
