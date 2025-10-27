//
//  TamagotchiScene.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 10/20/25.
//

import SpriteKit

class TamagotchiScene: SKScene {
    // MARK: - Constants
    private enum Layout {
        static let sceneSize: CGFloat = 250
        static let effectSize: CGFloat = 400
        static let effectTopMargin: CGFloat = 30
        static let effectItemOffset: CGPoint = CGPoint(x: -250, y: 20)
    }
    
    private enum Side {
        case left, right
    }
    
    // MARK: - Node Hierachy
    private var containerNode: SKNode?
    private var characterNode: SKNode?
    
    // Character parts
    private var bodyNode: SKSpriteNode?
    private var headNode: SKSpriteNode?
    private var leftArmNode: SKSpriteNode?
    private var rightArmNode: SKSpriteNode?
    private var leftLegNode: SKSpriteNode?
    private var rightLegNode: SKSpriteNode?
    
    // Effect Nodes
    private var effectTopNode: SKSpriteNode?
    private var effectItemNode: SKSpriteNode?
    
    // MARK: - Initialization
    override init() {
        super.init(size: CGSize(width: Layout.sceneSize, height: Layout.sceneSize))
        backgroundColor = .clear
        scaleMode = .aspectFit
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setup() {
        let container = createContainer()
        let character = createCharacter()
        container.addChild(character)
        setupEffectNodes()
        scaleContainer(container, characterSize: calculateCharacterSize())
    }
    
    // MARK: - Create Functions
    private func createContainer() -> SKNode {
        let container = SKNode()
        container.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(container)
        containerNode = container
        return container
    }
    
    private func createCharacter() -> SKNode {
        let character = SKNode()
        character.position = CGPoint(x: 0, y: -250)
        characterNode = character
        
        // Body를 중심(0,0)으로
        let body = createSprite(name: "body")
        body.position = .zero
        body.zPosition = 1
        character.addChild(body)
        bodyNode = body
        
        // Head는 body 위에
        let head = createSprite(name: "head")
        head.position = CGPoint(x: 0, y: body.size.height / 2 + head.size.height / 2)
        head.zPosition = 2
        character.addChild(head)
        headNode = head
        
        // Arms
        let leftArm = createSprite(name: "left_arm")
        layoutArm(leftArm, side: .left, body: body, in: character)
        leftArmNode = leftArm
        
        let rightArm = createSprite(name: "right_arm")
        layoutArm(rightArm, side: .right, body: body, in: character)
        rightArmNode = rightArm
        
        // Legs
        let leftLeg = createSprite(name: "left_leg")
        layoutLeg(leftLeg, side: .left, body: body, in: character)
        leftLegNode = leftLeg
        
        let rightLeg = createSprite(name: "right_leg")
        layoutLeg(rightLeg, side: .right, body: body, in: character)
        rightLegNode = rightLeg
        
        return character
    }
    
    private func createSprite(name: String) -> SKSpriteNode {
        let sprite = SKSpriteNode(imageNamed: name)
        sprite.name = name
        return sprite
    }
    
    private func setupEffectNodes() {
        guard let character = characterNode,
              let head = headNode else { return }
        
        let effectSize = CGSize(width: Layout.effectSize, height: Layout.effectSize)
        let characterTop = character.position.y + head.position.y + head.size.height / 2
        
        // 위쪽 이펙트 (하트, 전구, 잠자기 등)
        let topEffect = SKSpriteNode(color: .clear, size: effectSize)
        topEffect.position = CGPoint(x: character.position.x, y:  characterTop + effectSize.height / 2 + Layout.effectTopMargin)
        topEffect.zPosition = 100
        topEffect.alpha = 0
        topEffect.name = "effect_top"
        containerNode?.addChild(topEffect)
        effectTopNode = topEffect
        
        // 아이템 이펙트 (음식, 장난감 등)
        let itemEffect = SKSpriteNode(color: .clear, size: effectSize)
        itemEffect.position = CGPoint(x: character.position.x + Layout.effectItemOffset.x, y: characterTop + Layout.effectItemOffset.y)
        itemEffect.zPosition = 100
        itemEffect.alpha = 0
        itemEffect.name = "effect_item"
        containerNode?.addChild(itemEffect)
        effectItemNode = itemEffect
    }
    
    // MARK: - Layout Functions
    private func layoutArm(_ arm: SKSpriteNode, side: Side, body: SKSpriteNode, in parent: SKNode) {
        arm.anchorPoint = side == .left ? CGPoint(x: 1.0, y: 1.0) : CGPoint(x: 0.0, y: 1.0)
        let xOffset = side == .left ? -body.size.width / 2 : body.size.width / 2
        arm.position = CGPoint(x: xOffset, y: body.size.height / 2)
        arm.zPosition = 0
        parent.addChild(arm)
    }
    
    private func layoutLeg(_ leg: SKSpriteNode, side: Side, body: SKSpriteNode, in parent: SKNode) {
        leg.anchorPoint = side == .left ? CGPoint(x: 0.0, y: 1.0) : CGPoint(x: 1.0, y: 1.0)
        let xOffset = side == .left ? -body.size.width / 2 : body.size.width / 2
        leg.position = CGPoint(x: xOffset, y: -body.size.height / 2)
        leg.zPosition = 0
        parent.addChild(leg)
    }
    
    // MARK: - Calculate Functions
    private func scaleContainer(_ container: SKNode, characterSize: CGSize) {
        let scaleX = size.width / characterSize.width
        let scaleY = size.height / characterSize.height
        let scale = min(scaleX, scaleY) * 0.9
        container.setScale(scale)
    }
    
    private func calculateCharacterSize() -> CGSize {
        guard let body = bodyNode,
              let head = headNode,
              let leftArm = leftArmNode,
              let rightArm = rightArmNode,
              let leftLeg = leftLegNode,
              let rightLeg = rightLegNode else {
            return .zero
        }
        
        let width = leftArm.size.width + body.size.width + rightArm.size.width
        let height = Layout.effectSize + Layout.effectTopMargin + head.size.height + body.size.height + max(leftLeg.size.height, rightLeg.size.height)
        
        return CGSize(width: width, height: height)
    }
    
    // MARK: - Tap Handling
    func handleTap(at location: CGPoint, viewWidth: CGFloat, viewHeight: CGFloat) {
        let sceneLocation = convertToSceneCoordinates(location, viewWidth: viewWidth, viewHeight: viewHeight)
        let tappedNodes = nodes(at: sceneLocation)
        guard let topNode = tappedNodes.first else { return }
        
        performAction(for: topNode)
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
                showEffect(imageName: "light_bulb", position: .top, duration: 1.0)
            case 2:
                bodyNode?.parent?.run(jumpAction(height: 30, duration: 0.4, repeatCount: 2))
                leftLegNode?.run(spreadAction(angle: -.pi / 6, duration: 0.4, repeatCount: 2))
                rightLegNode?.run(spreadAction(angle: .pi / 6, duration: 0.4, repeatCount: 2))
            default:
                leftArmNode?.run(spreadAction(angle: -.pi / 4, duration: 0.4, repeatCount: 2))
                rightArmNode?.run(spreadAction(angle: .pi / 4, duration: 0.4, repeatCount: 2))
            }
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
    
    // MARK: - Effect Actions
    func showSleepIndicator() {
        showEffect(imageName: "sleep1", position: .top)
    }
    
    func hideSleepIndicator() {
        hideEffect(position: .top)
    }
    
    func showHeartEffect() {
        showEffect(imageName: "heart1", position: .top, duration: 1.0)
    }
    
    func showItemEffect(itemIamgeName: String) {
        showEffect(imageName: itemIamgeName, position: .item, duration: 1.0) { [weak self] in
            self?.showHeartEffect()
        }
    }
    
    private func showEffect(imageName: String, position: EffectPosition, duration: TimeInterval? = nil, completion: (() -> Void)? = nil) {
        let node = position == .top ? effectTopNode : effectItemNode
        
        let texture = SKTexture(imageNamed: imageName)
        node?.texture = texture
        
        let aspectRatio = texture.size().width / texture.size().height
        node?.size = CGSize(width: Layout.effectSize * aspectRatio, height: Layout.effectSize)
        
        if let duration = duration {
            let sequence = SKAction.sequence([
                SKAction.fadeAlpha(to: 1, duration: 0.2),
                SKAction.wait(forDuration: duration - 0.4),
                SKAction.fadeAlpha(to: 0, duration: 0.2)
            ])
            node?.run(sequence) {
                completion?()
            }
        } else {
            node?.run(SKAction.fadeAlpha(to: 1, duration: 0.2))
        }
    }
    
    private func hideEffect(position: EffectPosition) {
        let node = position == .top ? effectTopNode : effectItemNode
        node?.run(SKAction.fadeAlpha(to: 0, duration: 0.2))
    }
    
    private enum EffectPosition {
        case top
        case item
    }
}

extension TamagotchiScene {
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
