//
//  GameScene.swift
//  Slider
//  Lost Path Games
//
//  Created by Christopher Conley on 10/17/16.
//  Copyright (c) 2016 Lost Path Games. All rights reserved.
//

import SpriteKit
import GameKit

extension UIViewController {
    
    //run if high score requested but not authenticated
    func notAunthicated() {
        let unable = UIAlertController(title: "", message: "Not authenticated in Game Center", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        unable.addAction(OKAction)
        
        self.present(unable, animated: true, completion: nil)
        
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate, GKGameCenterControllerDelegate {
    
    //screen size
    let screenSize = UIScreen.main.bounds
    
    //control variables
    var game: GameClass!
    var first: Bool = true
    var notStarted: Bool = true
    let textLayer: CGFloat = 2.0
    var inMenu: Bool = true
    
    //leaderboard variables
    var playerAuthenticated: Bool = Bool()
    var leaderBoardLoaded: Bool = Bool()
    var leaderBoardID: String = ""
    
    
    //initalize the game
    func initialize() {
        self.physicsWorld.gravity           = CGVector(dx: 0.0, dy: 0.0)
        self.physicsWorld.contactDelegate   = self

    }

    
    //reporting high scores
    func submitScore(score: Int) {
        
        if playerAuthenticated && leaderBoardLoaded {
            
            let scoreReporter = GKScore(leaderboardIdentifier: leaderBoardID)
            scoreReporter.value = Int64(score)
            
            GKScore.report([scoreReporter], withCompletionHandler: {(error: Error?) -> Void in
                if error != nil {
                    return
                }
            })
            
        }
        
    }

    
    
    //start the game
    func startGame() {
        
        self.removeAllActions()
        self.removeAllChildren()
        
        self.inMenu = false
        
        //setup game
        game = GameClass(screenRect: screenSize);
        game.gameSetUp()
        
        //add game sprites and sounds to scene
        self.addChild(game.addSprites())
        self.addChild(game.addSounds())
        
        //run game
        game.run()
        
    }
    
    
    
    //first function called when game starts running
    override func didMove(to view: SKView) {

        self.initialize()

        
        //add menu here -- two choices, start game or how to play
        let temp = GameClass(screenRect: screenSize)
        temp.gameSetUp()
        self.addChild(temp.addSprites())
        
        self.makeMenu()
        
     }
    
    
   // gamecenter loaded
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: {
        
        return
        })
    }
    
    
    
    
    
    
    //how to play directions
    func howToPlay() {
        let howToTexture = SKTexture(imageNamed: "howTo")
        howToTexture.filteringMode = .nearest
        
        let howToSprite = SKSpriteNode(texture: howToTexture)
        howToSprite.setScale(self.frame.size.width / howToTexture.size().width)
        
        let xScale = self.frame.size.width / howToTexture.size().width
        let yScale = self.frame.size.height / howToTexture.size().height
        
        if (xScale < yScale) {howToSprite.setScale(xScale)}
        else {howToSprite.setScale(yScale)}
        
        howToSprite.position = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)
        howToSprite.zPosition = self.textLayer + 1
        howToSprite.name = "howTo"
        self.addChild(howToSprite)
    }
    
    
    //game credits
    func credits() {
        let creditsListTexture = SKTexture(imageNamed: "creditsList")
        creditsListTexture.filteringMode = .nearest
        
        let creditsListSprite = SKSpriteNode(texture: creditsListTexture)
        
        let xScale = self.frame.size.width / creditsListTexture.size().width
        let yScale = self.frame.size.height / creditsListTexture.size().height
        
        if (xScale < yScale) {creditsListSprite.setScale(xScale)}
        else {creditsListSprite.setScale(yScale)}
        
        creditsListSprite.position = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)
        creditsListSprite.zPosition = self.textLayer + 1
        creditsListSprite.name = "creditsList"
        self.addChild(creditsListSprite)
    }
    

    func highScore() {
        
        let vc = GKGameCenterViewController()
        vc.gameCenterDelegate = self
        vc.viewState = .leaderboards
        vc.leaderboardIdentifier = leaderBoardID
        self.view?.window?.rootViewController?.present(vc, animated: true, completion: nil)
        
    }

    
    //make the game menu
    func makeMenu() {
        
        //display start
        let startTexture = SKTexture(imageNamed: "start")
        startTexture.filteringMode = .nearest
        
        let startSprite = SKSpriteNode(texture: startTexture)
        startSprite.setScale(self.frame.size.width * 0.8 / startTexture.size().width)
        startSprite.position = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height * 2.0 / 3.0)
        startSprite.zPosition = self.textLayer
        startSprite.name = "start"
        self.addChild(startSprite)
        
        //display high score link
        let scoreTexture = SKTexture(imageNamed: "highScore")
        scoreTexture.filteringMode = .nearest
        
        let scoreSprite = SKSpriteNode(texture: scoreTexture)
        scoreSprite.setScale(self.frame.size.width * 0.33 / scoreTexture.size().width)
        scoreSprite.position = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height * 2.0 / 4.0)
        scoreSprite.zPosition = self.textLayer
        scoreSprite.name = "highScore"
        self.addChild(scoreSprite)
        
        //display how to play
        let howToPlayTexture = SKTexture(imageNamed: "howToPlay")
        howToPlayTexture.filteringMode = .nearest
        
        let howToPlaySprite = SKSpriteNode(texture: howToPlayTexture)
        howToPlaySprite.setScale(self.frame.size.width * 0.6 / howToPlayTexture.size().width)
        howToPlaySprite.position = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height * 1.0 / 3.0)
        howToPlaySprite.zPosition = self.textLayer
        howToPlaySprite.name = "howToPlay"
        self.addChild(howToPlaySprite)
        
        //display credits
        let creditsTexture = SKTexture(imageNamed: "credits")
        creditsTexture.filteringMode = .nearest
        
        let creditsSprite = SKSpriteNode(texture: creditsTexture)
        creditsSprite.setScale(self.frame.size.width * 0.1 / creditsTexture.size().width)
        creditsSprite.position = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height * 1.0 / 12.0)
        creditsSprite.zPosition = self.textLayer
        creditsSprite.name = "credits"
        self.addChild(creditsSprite)
    }
    
 
    //detect touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //touch info
        let touch = touches.first
        let point = touch!.location(in: self.view)
        
        var newPt = point
        newPt.y = self.frame.size.height - point.y
        
        //checks for menu choice for first start of game
        if (first) {
            
            for node in self.nodes(at: newPt)
            {

                if node.name == "start" {
                    first = false
                    notStarted = false
                    self.startGame()
                }
                else if node.name == "highScore"{
                    self.highScore()
                }
                else if node.name == "howToPlay" {
                    self.howToPlay()
                }
                else if node.name == "credits" {
                    self.credits()
                }
                
                if node.name == "howTo" {
                    node.removeFromParent()
                }
             //   else if node.name == "highScoreNode" {
             //       node.removeFromParent()
             //   }
                else if node.name == "creditsList" {
                    node.removeFromParent()
                }
            }
        }
        
        
        //check for side of screen and implement velocity as needed
        if (!notStarted) {game.movePlayer(xTouch: point.x)}
        
        //if restart node is present and touched, this restarts game
        for node in self.nodes(at: newPt) {
            if  node.name == "restart" {
            
                self.startGame()
            }
            else if node.name == "highScore" {
                
                self.highScore()
                
            }
        }
        
    }
    
    
    //detect touches ending
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!notStarted) {game.goStraight()}
    }
    
    
    //check player location on updates
    override func update(_ currentTime: TimeInterval) {
        
        if (!notStarted) {game.checkPlayerPosit()}
        
    }
    
    
    //detects contact between sprites
    func didBegin(_ contact: SKPhysicsContact) {

        //stop the game
        game.gameStop()
        
        //submit high score
        self.submitScore(score: game.getScore())
        
        //display game over
        let gameOverTexture = SKTexture(imageNamed: "GameOver")
        gameOverTexture.filteringMode = .nearest
        
        let gameOverSprite = SKSpriteNode(texture: gameOverTexture)
        gameOverSprite.setScale(self.frame.size.width * 0.9 / gameOverTexture.size().width)
        gameOverSprite.position = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height * 3.0 / 4.0)
        gameOverSprite.zPosition = self.textLayer
        self.addChild(gameOverSprite)
        
        
        
        //display restart
        let restartTexture = SKTexture(imageNamed: "restart")
        restartTexture.filteringMode = .nearest
        game.delay(0.5) {
            let restartSprite = SKSpriteNode(texture: restartTexture)
            restartSprite.setScale(self.frame.size.width * 0.75 / restartTexture.size().width)
            restartSprite.position = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)
            restartSprite.zPosition = self.textLayer
            let restartSpriteNode = SKSpriteNode()
            restartSpriteNode.name = "restart"
            restartSpriteNode.addChild(restartSprite)
            self.addChild(restartSpriteNode)
            
            //display high score link
            let scoreTexture = SKTexture(imageNamed: "highScore")
            scoreTexture.filteringMode = .nearest
            
            let scoreSprite = SKSpriteNode(texture: scoreTexture)
            scoreSprite.setScale(self.frame.size.width * 0.33 / scoreTexture.size().width)
            scoreSprite.position = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height * 1.0 / 3.0)
            scoreSprite.zPosition = self.textLayer
            scoreSprite.name = "highScore"
            self.addChild(scoreSprite)
        }
        
    }
    
    
}
