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
        static let targetCharacterHeight: CGFloat = 175  // 화면상 캐릭터 목표 높이
        static let characterYOffset: CGFloat = -115  // 고정 오프셋 : 컨테이너 하단(-125)에서 10만큼 위
        static let effectSize: CGFloat = 80  // 고정 크기
        static let effectTopMargin: CGFloat = 20  // 고정 여백
        static let effectItemOffset = CGPoint(x: -80, y: 20)  // 고정 오프셋
        static let statChangeFontSize: CGFloat = 50  // 고정 폰트 크기
        static let statChangeRandomRange: CGFloat = 100  // 고정 랜덤 범위
        static let statChangeMoveUp: CGFloat = 80  // 고정 이동 거리
    }

    // MARK: - Node Hierarchy
    private var containerNode: SKNode?
    private var characterNode: TamagotchiCharacter?

    // Effect Nodes (씬의 직접 자식)
    private var effectTopNode: SKSpriteNode?
    private var effectItemNode: SKSpriteNode?

    // MARK: - Initialization
    init(imageSetName: String) {
        super.init(size: CGSize(width: Layout.sceneSize, height: Layout.sceneSize))
        backgroundColor = .clear
        scaleMode = .aspectFit
        setup(imageSetName: imageSetName)
        setupNotifications()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup
    private func setup(imageSetName: String) {
        let container = createContainer()
        let character = createCharacter(imageSetName: imageSetName)
        container.addChild(character)
        setupEffectNodes()
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

    private func createCharacter(imageSetName: String) -> SKNode {
        let character = TamagotchiCharacter(imageSetName: imageSetName)
        
        let characterSize = character.calculateSize()
        let scale = Layout.targetCharacterHeight / characterSize.height
        character.setScale(scale)
        
        let bottomY = character.getBottomYPosition() * scale
        character.position = CGPoint(x: 0, y: Layout.characterYOffset - bottomY)

        characterNode = character
        return character
    }

    private func setupEffectNodes() {
        guard let character = characterNode else { return }
        
        let effectSize = CGSize(width: Layout.effectSize, height: Layout.effectSize)

        // 캐릭터 최상단 (로컬 좌표)
        let characterTopY = character.position.y + character.getTopYPosition() * character.yScale

        // 위쪽 이펙트 (하트, 전구, 잠자기 등)
        let topEffect = SKSpriteNode(color: .clear, size: effectSize)
        topEffect.position = CGPoint(x: 0, y: characterTopY + Layout.effectTopMargin)
        topEffect.zPosition = 100
        topEffect.alpha = 0
        topEffect.name = "effect_top"
        containerNode?.addChild(topEffect)  // containerNode의 자식
        effectTopNode = topEffect

        // 아이템 이펙트 (음식, 장난감 등)
        let itemEffect = SKSpriteNode(color: .clear, size: effectSize)
        itemEffect.position = CGPoint(
            x: Layout.effectItemOffset.x,
            y: characterTopY + Layout.effectItemOffset.y
        )
        itemEffect.zPosition = 100
        itemEffect.alpha = 0
        itemEffect.name = "effect_item"
        containerNode?.addChild(itemEffect)  // containerNode의 자식
        effectItemNode = itemEffect
    }


    // MARK: - Tap Handling
    func handleTap(at location: CGPoint, viewWidth: CGFloat, viewHeight: CGFloat) {
        let sceneLocation = convertToSceneCoordinates(location, viewWidth: viewWidth, viewHeight: viewHeight)
        characterNode?.handleTap(at: sceneLocation)
    }

    private func convertToSceneCoordinates(_ location: CGPoint, viewWidth: CGFloat, viewHeight: CGFloat) -> CGPoint {
        let scaleX = size.width / viewWidth
        let scaleY = size.height / viewHeight
        var scenePoint = CGPoint(x: location.x * scaleX, y: (viewHeight - location.y) * scaleY)

        // containerNode의 위치 오프셋 제거
        if let container = containerNode {
            scenePoint.x -= container.position.x
            scenePoint.y -= container.position.y
        }

        // characterNode의 위치 오프셋 제거 및 스케일 적용
        if let character = characterNode {
            scenePoint.x -= character.position.x
            scenePoint.y -= character.position.y

            // characterNode의 스케일을 역으로 적용
            scenePoint.x /= character.xScale
            scenePoint.y /= character.yScale
        }

        return scenePoint
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
        guard let character = characterNode else { return }

        let label = SKLabelNode(text: text)
        label.fontName = ".AppleSystemUIFontBlack"
        label.fontSize = Layout.statChangeFontSize
        label.fontColor = color

        // 캐릭터 위치 기준 (로컬 좌표)
        let randomX = CGFloat.random(in: -Layout.statChangeRandomRange...Layout.statChangeRandomRange)
        let randomY = CGFloat.random(in: -Layout.statChangeRandomRange...Layout.statChangeRandomRange)
        label.position = CGPoint(x: character.position.x + randomX, y: character.position.y + randomY)
        label.zPosition = 110

        containerNode?.addChild(label)  // containerNode의 자식

        let moveUp = SKAction.moveBy(x: 0, y: Layout.statChangeMoveUp, duration: 2.0)
        let fadeOut = SKAction.fadeOut(withDuration: 2.0)
        let group = SKAction.group([moveUp, fadeOut])
        let remove = SKAction.removeFromParent()

        label.run(SKAction.sequence([group, remove]))
    }

    private func showEffect(imageName: String, position: EffectPosition, duration: TimeInterval? = nil, completion: (() -> Void)? = nil) {
        guard let node = position == .top ? effectTopNode : effectItemNode else { return }

        let texture = SKTexture(imageNamed: imageName)
        node.texture = texture

        // 이미지 비율 유지, 높이는 고정
        let textureSize = texture.size()
        let aspectRatio = textureSize.width / textureSize.height
        node.size = CGSize(width: Layout.effectSize * aspectRatio, height: Layout.effectSize)

        if let duration = duration {
            let sequence = SKAction.sequence([
                SKAction.fadeAlpha(to: 1, duration: 0.2),
                SKAction.wait(forDuration: duration - 0.4),
                SKAction.fadeAlpha(to: 0, duration: 0.2)
            ])
            node.run(sequence) {
                completion?()
            }
        } else {
            node.run(SKAction.fadeAlpha(to: 1, duration: 0.2))
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

    // MARK: - Public Methods
    func updateCharacter(imageSetName: String) {
        // 기존 이펙트 노드 제거
        effectTopNode?.removeFromParent()
        effectItemNode?.removeFromParent()

        // 캐릭터 이미지셋 변경
        characterNode?.loadImageSet(imageSetName)

        // characterNode 스케일 재계산
        if let character = characterNode {
            let characterSize = character.calculateSize()
            let scale = Layout.targetCharacterHeight / characterSize.height
            character.setScale(scale)
        }

        // 이펙트 노드 재설정
        setupEffectNodes()
    }
}
