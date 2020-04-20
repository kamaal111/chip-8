//
//  GameScene.swift
//  chip-8 Shared
//
//  Created by Kamaal Farah on 19/04/2020.
//  Copyright © 2020 Kamaal. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    var chip8CPU = Chip8CPU(kowalskiAnalysis: false)
    var graphics = [SKShapeNode?](repeating: nil, count: 64 * 32)
    var currentGame: Chip8Games = .PONG2
    var gameColor: SKColor = .green

    class func newGameScene(size: CGSize) -> GameScene {
        let scene = GameScene(size: size)
        return scene
    }

    func setUpScene(view: SKView) {
        chip8CPU.loadProgram(withName: currentGame)
        initializeGrid(size: view.frame.size)
    }

    func initializeGrid(size: CGSize) {
        let minds = min(size.width, size.height)
        let pixelSize = CGSize(width: minds / 64, height: minds / 32)
        for i in 0..<graphics.count {
            guard let node = graphics[i] else { continue }
            node.removeFromParent()
        }

        for x in 0..<64 {
            for y in 0..<32 {
                let xConverted = (CGFloat(x) * pixelSize.width)
                let yConverted = size.height - (CGFloat(y) * pixelSize.height)
                let shape = SKShapeNode(rect: CGRect(
                    x: xConverted,
                    y: yConverted,
                    width: pixelSize.width,
                    height: pixelSize.height))
                shape.fillColor = gameColor
                shape.strokeColor = .clear
                addChild(shape)
                graphics[x + (64 * y)] = shape
            }
        }
    }

    #if os(watchOS)
    override func sceneDidLoad() {
        setUpScene()
    }
    #else
    override func didMove(to view: SKView) {
        setUpScene(view: view)
    }
    #endif

    override func update(_ currentTime: TimeInterval) {
        while !chip8CPU.drawFlag {
            chip8CPU.emulateCycles()
        }

        for x in 0..<64 {
            for y in 0..<32 {
                graphics[x + (64 * y)]!.fillColor = (chip8CPU.graphics[x + (64 * y)] == 1 ? gameColor : .clear)
            }
        }

        chip8CPU.drawFlag = false
    }

}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}
#endif

#if os(OSX)
extension GameScene {
    override func keyDown(with event: NSEvent) {
        switch currentGame {
        case .INVADERS:
            switch event.keyCode {
            case 0x31: // Spacebar key
                chip8CPU.key[5] = 1 // shoot
            case 0x0: // A key
                chip8CPU.key[4] = 1 // left
            case 0x2: // D key
                chip8CPU.key[6] = 1 // right
            default:
                print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
            }
        case .PONG:
            switch event.keyCode {
            case 0xD: // W key
                chip8CPU.key[1] = 1 // player 1 up
            case 0x1: // S key
                chip8CPU.key[4] = 1 // player 1 down
            case 0x22 : // I key
                chip8CPU.key[12] = 1 // player 2 up
            case 0x28: // K key
                chip8CPU.key[13] = 1 // player 2 down
            default:
                print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
            }
        case .PONG2:
            switch event.keyCode {
            case 0xD: // W key
                chip8CPU.key[1] = 1 // player 1 up
            case 0x1: // S key
                chip8CPU.key[4] = 1 // player 1 down
            case 0x22 : // I key
                chip8CPU.key[12] = 1 // player 2 up
            case 0x28: // K key
                chip8CPU.key[13] = 1 // player 2 down
            default:
                print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
            }
        case .TANK:
            switch event.keyCode {
            case 0x31: // Spacebar key
                chip8CPU.key[5] = 1 // shoot
            case 0x0: // A key
                chip8CPU.key[4] = 1 // left
            case 0x2: // D key
                chip8CPU.key[6] = 1 // right
            case 0xD: // W key
                chip8CPU.key[8] = 1 // up
            case 0x1: // S key
                chip8CPU.key[2] = 1 // down
            default:
                print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
            }
        case .TETRIS:
            switch event.keyCode {
            case 0x0: // A key
                chip8CPU.key[5] = 1 // left
            case 0x2: // D key
                chip8CPU.key[6] = 1 // right
            default:
                print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
            }
//        default:
//            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }

    override func keyUp(with event: NSEvent) {
        for i in 0..<16 {
            chip8CPU.key[i] = 0
        }
    }
}
#endif

