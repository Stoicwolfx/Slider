//
//  GameViewController.swift
//  Slider
//
//  Created by Christopher Conley on 1/25/15.
//  Copyright (c) 2015 Lost Path Games. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

extension SKNode {
    class func unarchiveFromFile(_ file : NSString) -> SKNode? {
        if let path = Bundle.main.path(forResource: file as String, ofType: "sks") {
            let sceneData = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            
            let archiver = NSKeyedUnarchiver(forReadingWith: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {
    
    var leaderBoardEnabled: Bool = Bool()
    var leaderBoardLoaded: Bool = Bool()
    var leaderBoard: String = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        //if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
        if let scene = GameScene(fileNamed: "GameScene") {
            // Configure the view
            let skView = self.view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .resizeFill
            
            scene.size = skView.bounds.size
            
            skView.presentScene(scene)
            
            authenticatePlayer(game: scene)

        }
    }

    
    //authenticate the player and load the leaderboard
    func authenticatePlayer(game: GameScene) {
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            
            //sets up player to register if not present the opportunity
            if (viewController != nil) {
                self.present(viewController!, animated: true, completion: nil)
                
                
            } else if localPlayer.isAuthenticated {
                //use game center
                self.leaderBoardEnabled = true
                game.playerAuthenticated = true

                //load leaderBoard
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: {(leaderBoardIdentifier, error) in
                    
                    //leaderBoard failed to load
                    if error != nil {
                        self.leaderBoardLoaded = false
                        
                    //leaderBoardLoaded and is usable
                    } else {
                        self.leaderBoard = leaderBoardIdentifier!
                        self.leaderBoardLoaded = true
                        
                        game.leaderBoardLoaded = true
                        game.leaderBoardID = self.leaderBoard
                        
                    }
                    
                })
                
                //player unable to be authenticated
            } else {
                //don't use game center
                self.leaderBoardEnabled = false
                self.leaderBoardLoaded = false
                
                
            }
        }
    }
    
    
    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.allButUpsideDown
        } else {
            return UIInterfaceOrientationMask.all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
