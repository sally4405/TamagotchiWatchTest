//
//  TamagotchiScene.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 10/20/25.
//

import SpriteKit

class TamagotchiScene: SKScene {
    private var testNode: SKSpriteNode?
    
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = .white
        scaleMode = .aspectFit
        setupNodes( )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNodes() {
        let sprite = SKSpriteNode(color: .cyan, size: CGSize(width: 60, height: 60))
        sprite.position = CGPoint(x: size.width / 2, y: size.height / 2)
        sprite.name = "testNode"
        addChild(sprite)
        testNode = sprite
        
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 2)
        let repeatForever = SKAction.repeatForever(rotate)
        sprite.run(repeatForever)

    }
    
    func handleTap(at location: CGPoint) {
        let tappedNode = nodes(at: location)
        
        for node in tappedNode {
            if node.name == "testNode" {
                (node as? SKSpriteNode)?.color = [.cyan, .yellow, .red, .green, .blue].randomElement() ?? .cyan
            }
        }
        
    }
}
