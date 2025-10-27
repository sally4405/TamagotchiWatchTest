//
//  TamagotchiCharacter.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 10/27/25.
//

import SpriteKit

class TamagotchiCharacter: SKNode {
    // MARK: - Supporting Types
    private enum Side {
        case left, right
    }

    // MARK: - Properties
    private var bodyNode: SKSpriteNode?
    private var headNode: SKSpriteNode?
    private var leftArmNode: SKSpriteNode?
    private var rightArmNode: SKSpriteNode?
    private var leftLegNode: SKSpriteNode?
    private var rightLegNode: SKSpriteNode?

    override init() {
        super.init()
        setupParts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupParts() {
        // Body를 중심(0,0)으로
        let body = createSprite(name: "body")
        body.position = .zero
        body.zPosition = 1
        addChild(body)
        bodyNode = body
        
        // Head는 body 위에
        let head = createSprite(name: "head")
        head.position = CGPoint(x: 0, y: body.size.height / 2 + head.size.height / 2)
        head.zPosition = 2
        addChild(head)
        headNode = head
        
        // Arms
        let leftArm = createSprite(name: "left_arm")
        layoutArm(leftArm, side: .left, body: body)
        leftArmNode = leftArm
        
        let rightArm = createSprite(name: "right_arm")
        layoutArm(rightArm, side: .right, body: body)
        rightArmNode = rightArm
        
        // Legs
        let leftLeg = createSprite(name: "left_leg")
        layoutLeg(leftLeg, side: .left, body: body)
        leftLegNode = leftLeg
        
        let rightLeg = createSprite(name: "right_leg")
        layoutLeg(rightLeg, side: .right, body: body)
        rightLegNode = rightLeg
    }
    
    private func createSprite(name: String) -> SKSpriteNode {
        let sprite = SKSpriteNode(imageNamed: name)
        sprite.name = name
        return sprite
    }

    // MARK: - Layout
    private func layoutArm(_ arm: SKSpriteNode, side: Side, body: SKSpriteNode) {
        arm.anchorPoint = side == .left ? CGPoint(x: 1.0, y: 1.0) : CGPoint(x: 0.0, y: 1.0)
        let xOffset = side == .left ? -body.size.width / 2 : body.size.width / 2
        arm.position = CGPoint(x: xOffset, y: body.size.height / 2)
        arm.zPosition = 0
        addChild(arm)
    }
    
    private func layoutLeg(_ leg: SKSpriteNode, side: Side, body: SKSpriteNode) {
        leg.anchorPoint = side == .left ? CGPoint(x: 0.0, y: 1.0) : CGPoint(x: 1.0, y: 1.0)
        let xOffset = side == .left ? -body.size.width / 2 : body.size.width / 2
        leg.position = CGPoint(x: xOffset, y: -body.size.height / 2)
        leg.zPosition = 0
        addChild(leg)
    }

    // MARK: - Public Methods
    func handleTap(at point: CGPoint) {
        let tappedNodes = nodes(at: point)
        guard let topNode = tappedNodes.first else { return }
        
        performAction(for: topNode)
    }
    
    func getTopYPosition() -> CGFloat {
        guard let head = headNode else { return .zero }
        
        return head.position.y + head.size.height / 2
    }
    
    func calculateSize() -> CGSize {
        guard let body = bodyNode,
              let head = headNode,
              let leftArm = leftArmNode,
              let rightArm = rightArmNode,
              let leftLeg = leftLegNode,
              let rightLeg = rightLegNode else {
            return .zero
        }
        
        let width = leftArm.size.width + body.size.width + rightArm.size.width
        let height = head.size.height + body.size.height + max(leftLeg.size.height, rightLeg.size.height)
        
        return CGSize(width: width, height: height)
    }
    
    // MARK: - Actions
    private func performAction(for node: SKNode) {
        switch node.name {
        case "body":
            performBodyAction()
        case "head":
            headNode?.run(tiltAction(angle: -.pi / 16, duration: 0.6))
        case "left_arm":
            leftArmNode?.run(spreadAction(angle: -.pi / 4, duration: 0.6))
        case "right_arm":
            rightArmNode?.run(spreadAction(angle: .pi / 4, duration: 0.6))
        case "left_leg":
            leftLegNode?.run(spreadAction(angle: -.pi / 6, duration: 0.6))
        case "right_leg":
            rightLegNode?.run(spreadAction(angle: .pi / 6, duration: 0.6))
        default:
            break
        }
    }
    
    private func performBodyAction() {
        let randomValue: Int = Int.random(in: 1...3)
        switch randomValue {
        case 1:
            NotificationCenter.default.post(name: .showLightBulb, object: nil)
        case 2:
            bodyNode?.parent?.run(jumpAction(height: 100, duration: 0.4, repeatCount: 2))
            leftLegNode?.run(spreadAction(angle: -.pi / 6, duration: 0.4, repeatCount: 2))
            rightLegNode?.run(spreadAction(angle: .pi / 6, duration: 0.4, repeatCount: 2))
        default:
            leftArmNode?.run(spreadAction(angle: -.pi / 4, duration: 0.4, repeatCount: 2))
            rightArmNode?.run(spreadAction(angle: .pi / 4, duration: 0.4, repeatCount: 2))
        }
    }
    
    // MARK: - Animation Actions
    private func jumpAction(height: CGFloat, duration: TimeInterval, repeatCount: Int = 1) -> SKAction {
        let singleDuration = duration / (2 * Double(repeatCount))
        let actions = Array(
            repeating: [
                SKAction.moveBy(x: 0, y: height, duration: singleDuration),
                SKAction.moveBy(x: 0, y: -height, duration: singleDuration)
            ],
            count: repeatCount
        ).flatMap { $0 }
        return SKAction.sequence(actions)
    }
    
    private func tiltAction(angle: CGFloat, duration: TimeInterval, repeatCount: Int = 1) -> SKAction {
        let singleDuration = duration / (3 * Double(repeatCount))
        let actions = Array(
            repeating: [
                SKAction.rotate(toAngle: angle, duration: singleDuration),
                SKAction.rotate(toAngle: -angle, duration: singleDuration),
                SKAction.rotate(toAngle: 0, duration: singleDuration)
            ],
            count: repeatCount
        ).flatMap { $0 }
        return SKAction.sequence(actions)
    }
    
    private func spreadAction(angle: CGFloat, duration: TimeInterval, repeatCount: Int = 1) -> SKAction {
        let singleDuration = duration / (2 * Double(repeatCount))
        let actions = Array(
            repeating: [
                SKAction.rotate(toAngle: angle, duration: singleDuration),
                SKAction.rotate(toAngle: 0, duration: singleDuration),
            ],
            count: repeatCount
        ).flatMap { $0 }
        return SKAction.sequence(actions)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let showLightBulb = Notification.Name("showLightBulb")
}
