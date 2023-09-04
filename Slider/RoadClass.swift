//
//  RoadClass.swift
//  Slider
//  Lost Path Games
//
//  Created by Christopher Conley on 10/20/16.
//  Copyright © 2016 Lost Path Games. All rights reserved.
//

import Foundation
import SpriteKit



class RoadClass {
    
    var roadTexture: SKTexture!
    var roadScroll: SKAction!
    var roadScroller: SKNode!
    
    private let roadTextureName: String = "roadAndSides"
   
    var scrollSpeed: CGFloat = 0.0
    
    private let sideSize0: CGFloat = 18.0
    private var sideSize: CGFloat!
    
    //function to set up static road
    init(scrollSpeed: CGFloat) {
        
        roadScroller = SKNode()
        
        roadTexture = SKTexture(imageNamed: roadTextureName)
        roadTexture.filteringMode = .nearest
        
        let roadScale: CGFloat = UIScreen.main.bounds.width / roadTexture.size().width
        sideSize = sideSize0 * roadScale
        
        
        //fill screen vertically with road graphics
        for i in 0...Int((2.0 + UIScreen.main.bounds.height / (roadTexture.size().height * roadScale))) {
            
            let roadSprite = SKSpriteNode(texture: roadTexture)
            roadSprite.setScale(roadScale)
            roadSprite.position = CGPoint(x: UIScreen.main.bounds.width / 2.0, y: CGFloat(i) * roadSprite.size.height)
            
            //display
            roadScroller.addChild(roadSprite)
            
        }
        
        //road animations
        let moveRoad = SKAction.moveBy(x: 0.0,
                                       y: -roadTexture.size().height * roadScale,
                                       duration: TimeInterval(scrollSpeed * roadTexture.size().height * roadScale))
        let resetRoad = SKAction.moveBy(x: 0.0,
                                        y: roadTexture.size().height * roadScale,
                                        duration: TimeInterval(0.0))
        roadScroll = SKAction.repeatForever(SKAction.sequence([moveRoad,resetRoad]))
        roadScroller.run(roadScroll)
        roadScroller.speed = 0.0
        //end road animations
        
    }

    
    //start the road scrolling
    func startScroll() {
        roadScroller.speed = 1.0
    }
    
    
    //stop the road scrolling
    func stopScroll() {
        roadScroller.speed = 0.0
    }
    
    
    //return road sprites to calling process
    func rScroller() -> SKNode {
        return roadScroller
    }
    
    
    //speed up road scroll
    func accelerate(_ modifier: CGFloat) {
        roadScroller.speed = modifier
    }
    
    
    //get side size
    func sideWidth() -> CGFloat {
        return sideSize
    }
    
}
