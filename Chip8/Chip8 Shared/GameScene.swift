//
//  GameScene.swift
//  Chip8 Shared
//
//  Created by Kamaal M Farah on 08/02/2023.
//

import SpriteKit

class GameScene: SKScene {
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }

        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill

        return scene
    }

    func setUpScene() { }

    override func didMove(to view: SKView) {
        self.setUpScene()
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) { }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { }
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {
    override func mouseDown(with event: NSEvent) { }

    override func mouseDragged(with event: NSEvent) { }

    override func mouseUp(with event: NSEvent) { }
}
#endif
