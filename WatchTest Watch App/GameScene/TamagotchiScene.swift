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
        static let characterOffsetY: CGFloat = -250
    }
    
    // MARK: - Node Hierarchy
    private var containerNode: SKNode?
    private var characterNode: TamagotchiCharacter?

    // Effect Nodes
    private var effectTopNode: SKSpriteNode?
    private var effectItemNode: SKSpriteNode?
    
    // MARK: - Initialization
    override init() {
        super.init(size: CGSize(width: Layout.sceneSize, height: Layout.sceneSize))
        backgroundColor = .clear
        scaleMode = .aspectFit
        setup()
        setupNotifications()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    private func setup() {
        let container = createContainer()
        let character = createCharacter()
        container.addChild(character)
        setupEffectNodes()
        scaleContainer(container, characterSize: calculateCharacterSize())
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleShowLightBulb),
            name: .showLightBulb,
            object: nil
        )
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
        let character = TamagotchiCharacter()
        character.position = CGPoint(x: 0, y: Layout.characterOffsetY)
        characterNode = character
        return character
    }
    
    private func setupEffectNodes() {
        guard let character = characterNode else { return }
        
        let effectSize = CGSize(width: Layout.effectSize, height: Layout.effectSize)
        let characterTopY = character.position.y + character.getTopYPosition()
        
        // 위쪽 이펙트 (하트, 전구, 잠자기 등)
        let topEffect = SKSpriteNode(color: .clear, size: effectSize)
        topEffect.position = CGPoint(x: character.position.x, y:  characterTopY + effectSize.height / 2 + Layout.effectTopMargin)
        topEffect.zPosition = 100
        topEffect.alpha = 0
        topEffect.name = "effect_top"
        containerNode?.addChild(topEffect)
        effectTopNode = topEffect
        
        // 아이템 이펙트 (음식, 장난감 등)
        let itemEffect = SKSpriteNode(color: .clear, size: effectSize)
        itemEffect.position = CGPoint(x: character.position.x + Layout.effectItemOffset.x, y: characterTopY + Layout.effectItemOffset.y)
        itemEffect.zPosition = 100
        itemEffect.alpha = 0
        itemEffect.name = "effect_item"
        containerNode?.addChild(itemEffect)
        effectItemNode = itemEffect
    }
        
    // MARK: - Calculate Functions
    private func scaleContainer(_ container: SKNode, characterSize: CGSize) {
        let scaleX = size.width / characterSize.width
        let scaleY = size.height / characterSize.height
        let scale = min(scaleX, scaleY) * 0.9
        container.setScale(scale)
    }
    
    private func calculateCharacterSize() -> CGSize {
        guard let character = characterNode else { return .zero }
        
        let characterSize = character.calculateSize()
        let totalHeight = Layout.effectSize + Layout.effectTopMargin + characterSize.height
        
        return CGSize(width: characterSize.width, height: totalHeight)
    }
    
    // MARK: - Tap Handling
    func handleTap(at location: CGPoint, viewWidth: CGFloat, viewHeight: CGFloat) {
        let sceneLocation = convertToSceneCoordinates(location, viewWidth: viewWidth, viewHeight: viewHeight)
        characterNode?.handleTap(at: sceneLocation)
    }
    
    private func convertToSceneCoordinates(_ location: CGPoint, viewWidth: CGFloat, viewHeight: CGFloat) -> CGPoint {
        let scaleX = size.width / viewWidth
        let scaleY = size.height / viewHeight
        return CGPoint(x: location.x * scaleX, y: (viewHeight - location.y) * scaleY)
    }

    // MARK: - Notification Handlers
    @objc private func handleShowLightBulb() {
        showEffect(imageName: "light_bulb", position: .top, duration: 1.0)
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
    
    func showItemEffect(itemImageName: String) {
        showEffect(imageName: itemImageName, position: .item, duration: 1.0) { [weak self] in
            self?.showHeartEffect()
        }
    }
    
    func showStatChange(text: String, color: UIColor) {
        guard let characterNode = characterNode else { return }
        
        let label = SKLabelNode(text: text)
        label.fontName = ".AppleSystemUIFontBlack"
        label.fontSize = 250
        label.fontColor = color
        
        let randomX = CGFloat.random(in: -400...400)
        let randomY = CGFloat.random(in: -400...400)
        label.position = CGPoint(x: characterNode.position.x + randomX, y: characterNode.position.y + randomY)
        label.zPosition = 110
        
        containerNode?.addChild(label)
        
        let moveUp = SKAction.moveBy(x: 0, y: 200, duration: 2.0)
        let fadeOut = SKAction.fadeOut(withDuration: 2.0)
        let group = SKAction.group([moveUp, fadeOut])
        let remove = SKAction.removeFromParent()
        
        label.run(SKAction.sequence([group, remove]))
    }
    
    private func showEffect(imageName: String, position: EffectPosition, duration: TimeInterval? = nil, completion: (() -> Void)? = nil) {
        let node = position == .top ? effectTopNode : effectItemNode
        
        let texture = SKTexture(imageNamed: imageName)
        node?.texture = texture
        
        let textureSize = texture.size()
        let aspectRatio = textureSize.width / textureSize.height
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
