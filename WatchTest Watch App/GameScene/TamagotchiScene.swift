//
//  TamagotchiScene.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 10/20/25.
//

import SpriteKit

class TamagotchiScene: SKScene {
    // MARK: - Contants
    private enum Layout {
        static let sceneSize: CGFloat = 250
        static let topMargin: CGFloat = 10
        static let middleMargin: CGFloat = 10
        static let scaleFactor: CGFloat = 0.9   // 여유공간
    }
    
    // MARK: - Supporting Types
    private struct CharacterParts {
        let lightBulb: SKSpriteNode
        let head: SKSpriteNode
        let body: SKSpriteNode
        let leftArm: SKSpriteNode
        let rightArm: SKSpriteNode
        let leftLeg: SKSpriteNode
        let rightLeg: SKSpriteNode
    }
    
    private enum Side {
        case left, right
    }
    
    // MARK: - Properties
    private var containerNode: SKNode?
    private var bodyNode: SKSpriteNode?
    private var headNode: SKSpriteNode?
    private var leftArmNode: SKSpriteNode?
    private var rightArmNode: SKSpriteNode?
    private var leftLegNode: SKSpriteNode?
    private var rightLegNode: SKSpriteNode?
    private var lightBulbNode: SKSpriteNode?
    
    // MARK: - Initialization
    override init() {
        super.init(size: CGSize(width: Layout.sceneSize, height: Layout.sceneSize))
        backgroundColor = .clear
        scaleMode = .aspectFit
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setup() {
        let container = createContainer()
        let parts = createCharacterParts()
        layoutCharacter(parts: parts, in: container)
        scaleContainer(container, totalSize: calculateTotalSize(parts: parts))
    }
    
    // MARK: - create func
    private func createContainer() -> SKNode {
        let container = SKNode()
        container.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(container)
        containerNode = container
        return container
    }
    
    private func createCharacterParts() -> CharacterParts {
        CharacterParts(
            lightBulb: createSpriteNode(name: "light_bulb"),
            head: createSpriteNode(name: "head"),
            body: createSpriteNode(name: "body"),
            leftArm: createSpriteNode(name: "left_arm"),
            rightArm: createSpriteNode(name: "right_arm"),
            leftLeg: createSpriteNode(name: "left_leg"),
            rightLeg: createSpriteNode(name: "right_leg")
        )
    }
    
    private func createSpriteNode(name imageNamed: String) -> SKSpriteNode {
        return SKSpriteNode(imageNamed: imageNamed)
    }
    
    // MARK: - Layout func
    private func layoutCharacter(parts: CharacterParts, in container: SKNode) {
        var currentY = calculateTotalSize(parts: parts).height / 2
        
        currentY = layoutPart(parts.lightBulb, at: currentY, in: container, name: "light_bulb", zPosition: 10, topMargin: Layout.topMargin, bottomMargin: Layout.middleMargin, alpha: 0)
        currentY = layoutPart(parts.head, at: currentY, in: container, name: "head", zPosition: 2)
        currentY = layoutPart(parts.body, at: currentY, in: container, name: "body", zPosition: 1)
        layoutArm(parts.leftArm, side: .left, body: parts.body, in: container)
        layoutArm(parts.rightArm, side: .right, body: parts.body, in: container)
        layoutLeg(parts.leftLeg, side: .left, body: parts.body, in: container)
        layoutLeg(parts.rightLeg, side: .right, body: parts.body, in: container)
        
        lightBulbNode = parts.lightBulb
        headNode = parts.head
        bodyNode = parts.body
        leftArmNode = parts.leftArm
        rightArmNode = parts.rightArm
        leftLegNode = parts.leftLeg
        rightLegNode = parts.rightLeg
    }
    
    private func layoutPart(_ sprite: SKSpriteNode, at currentY: CGFloat, in container: SKNode, name: String, zPosition: CGFloat, topMargin: CGFloat = 0, bottomMargin: CGFloat = 0, alpha: CGFloat = 1) -> CGFloat {
        let y = currentY - topMargin - sprite.size.height / 2
        sprite.position = CGPoint(x: 0, y: y)
        sprite.name = name
        sprite.zPosition = zPosition
        sprite.alpha = alpha
        container.addChild(sprite)
        return y - sprite.size.height / 2 - bottomMargin
    }
    
    private func layoutArm(_ arm: SKSpriteNode, side: Side, body: SKSpriteNode, in container: SKNode) {
        arm.anchorPoint = side == .left ? CGPoint(x: 1.0, y: 1.0) : CGPoint(x: 0.0, y: 1.0)
        let xOffset = side == .left ? -body.size.width / 2 : body.size.width / 2
        arm.position = CGPoint(x: body.position.x + xOffset, y: body.position.y + body.size.height / 2)
        arm.name = side == .left ? "left_arm" : "right_arm"
        arm.zPosition = 0
        container.addChild(arm)
    }
    
    private func layoutLeg(_ leg: SKSpriteNode, side: Side, body: SKSpriteNode, in container: SKNode) {
        leg.anchorPoint = side == .left ? CGPoint(x: 0.0, y: 1.0) : CGPoint(x: 1.0, y: 1.0)
        let xOffset = side == .left ? -body.size.width / 2 : body.size.width / 2
        leg.position = CGPoint(x: body.position.x + xOffset, y: body.position.y - body.size.height / 2)
        leg.name = side == .left ? "left_leg" : "right_leg"
        leg.zPosition = 0
        container.addChild(leg)
    }
    
    // MARK: - Calculate func
    private func scaleContainer(_ container: SKNode, totalSize: CGSize) {
        let scale = calculateOptimalScale(
            characterWidth: totalSize.width,
            characterHeight: totalSize.height
        )
        container.setScale(scale)
    }
    
    private func calculateTotalSize(parts: CharacterParts) -> CGSize {
        let height = Layout.topMargin + parts.lightBulb.size.height + Layout.middleMargin +
        parts.head.size.height + parts.body.size.height +
        max(parts.leftLeg.size.height, parts.rightLeg.size.height)
        let width = parts.leftArm.size.width + parts.body.size.width + parts.rightArm.size.width
        return CGSize(width: width, height: height)
    }
    
    private func calculateOptimalScale(characterWidth: CGFloat, characterHeight: CGFloat) -> CGFloat {
        let scaleX = size.width / characterWidth
        let scaleY = size.height / characterHeight
        return min(scaleX, scaleY) * Layout.scaleFactor
    }
    
    // MARK: - Tap Handling
    func handleTap(at location: CGPoint, viewWidth: CGFloat, viewHeight: CGFloat) {
        let tappedNodes = getTappedNodes(at: location, viewWidth: viewWidth, viewHeight: viewHeight)
        guard let topNode = tappedNodes.first else { return }
        
        performAction(for: topNode)
    }
    
    private func getTappedNodes(at location: CGPoint, viewWidth: CGFloat, viewHeight: CGFloat) -> [SKNode] {
        let sceneLocation = convertToSceneCoordinates(location, viewWidth: viewWidth, viewHeight: viewHeight)
        return nodes(at: sceneLocation)
    }
    
    private func convertToSceneCoordinates(_ location: CGPoint, viewWidth: CGFloat, viewHeight: CGFloat) -> CGPoint {
        let scaleX = size.width / viewWidth
        let scaleY = size.height / viewHeight
        return CGPoint(x: location.x * scaleX, y: (viewHeight - location.y) * scaleY)
    }
    
    private func performAction(for node: SKNode) {
        switch node.name {
        case "body":
            let randomValue: Int = Int.random(in: 1...3)
            switch randomValue {
            case 1:
                lightBulbNode?.run(blinkAction(duration: 0.2, wait: 0.3))
            case 2:
                bodyNode?.parent?.run(jumpAction(height: 20, duration: 0.2, repeatCount: 2))
                leftLegNode?.run(spreadAction(angle: -.pi / 6, duration: 0.2, repeatCount: 2))
                rightLegNode?.run(spreadAction(angle: .pi / 6, duration: 0.2, repeatCount: 2))
            default:
                leftArmNode?.run(spreadAction(angle: -.pi / 4, duration: 0.2, repeatCount: 2))
                rightArmNode?.run(spreadAction(angle: .pi / 4, duration: 0.2, repeatCount: 2))
            }
        case "head":
            headNode?.run(tiltAction(angle: -.pi / 16, duration: 0.3))
        case "left_arm":
            leftArmNode?.run(spreadAction(angle: -.pi / 4, duration: 0.3))
        case "right_arm":
            rightArmNode?.run(spreadAction(angle: .pi / 4, duration: 0.3))
        case "left_leg":
            leftLegNode?.run(spreadAction(angle: -.pi / 6, duration: 0.3))
        case "right_leg":
            rightLegNode?.run(spreadAction(angle: .pi / 6, duration: 0.3))
        default:
            break
        }
    }
}

extension TamagotchiScene {
    private func jumpAction(height: CGFloat, duration: TimeInterval, repeatCount: Int = 1) -> SKAction {
        let actions = Array(
            repeating: [
                SKAction.moveBy(x: 0, y: height, duration: duration),
                SKAction.moveBy(x: 0, y: -height, duration: duration)
            ],
            count: repeatCount
        ).flatMap { $0 }
        return SKAction.sequence(actions)
    }
    
    private func blinkAction(duration: TimeInterval, wait: TimeInterval = 0, repeatCount: Int = 1) -> SKAction {
        let actions = Array(
            repeating: [
                SKAction.fadeAlpha(to: 1.0, duration: duration),
                SKAction.wait(forDuration: wait),
                SKAction.fadeAlpha(to: 0, duration: duration)
            ],
            count: repeatCount
        ).flatMap { $0 }
        
        return SKAction.sequence(actions)
    }
    
    private func tiltAction(angle: CGFloat, duration: TimeInterval, repeatCount: Int = 1) -> SKAction {
        let actions = Array(
            repeating: [
                SKAction.rotate(toAngle: angle, duration: duration),
                SKAction.rotate(toAngle: -angle, duration: duration),
                SKAction.rotate(toAngle: 0, duration: duration),
            ],
            count: repeatCount
        ).flatMap { $0 }
        
        return SKAction.sequence(actions)
    }
    
    private func spreadAction(angle: CGFloat, duration: TimeInterval, repeatCount: Int = 1) -> SKAction {
        let actions = Array(
            repeating: [
                SKAction.rotate(toAngle: angle, duration: duration),
                SKAction.rotate(toAngle: 0, duration: duration),
            ],
            count: repeatCount
        ).flatMap { $0 }
        
        return SKAction.sequence(actions)
    }
}
