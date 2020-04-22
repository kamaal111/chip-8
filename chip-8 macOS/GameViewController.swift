//
//  GameViewController.swift
//  chip-8 macOS
//
//  Created by Kamaal Farah on 19/04/2020.
//  Copyright © 2020 Kamaal. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit
import SwiftUI

class GameViewController: NSViewController {

    lazy var controlsContentView: NSHostingView<ControlsContentView> = {
        let contentView = ControlsContentView()
        let hostingView = NSHostingView(rootView: contentView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        return hostingView
    }()

    lazy var gameSceneView: GameSceneView = {
        let scene = GameSceneView(frame: NSRect(x: 0, y: 0, width: 64, height: 64), currentGame: .PONG2)
        scene.translatesAutoresizingMaskIntoConstraints = false
        return scene
    }()

    lazy var gameTitle: NSText = {
        let text = NSText()
        text.string = "PONG2"
        text.textColor = .green
        text.font = .boldSystemFont(ofSize: 34)
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupConstraints()
    }

    private func setupViews() {
        view.addSubview(gameTitle)
        view.addSubview(gameSceneView)
        view.addSubview(controlsContentView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 716),
            view.widthAnchor.constraint(equalToConstant: 560),
        ])
        NSLayoutConstraint.activate([
            gameTitle.topAnchor.constraint(equalTo: view.topAnchor),
            gameTitle.heightAnchor.constraint(equalToConstant: 40),
            gameTitle.leftAnchor.constraint(equalTo: view.leftAnchor),
            gameTitle.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        NSLayoutConstraint.activate([
            gameSceneView.topAnchor.constraint(equalTo: gameTitle.bottomAnchor),
            gameSceneView.widthAnchor.constraint(equalToConstant: 560),
            gameSceneView.heightAnchor.constraint(equalToConstant: 560),
        ])
        NSLayoutConstraint.activate([
            controlsContentView.widthAnchor.constraint(equalToConstant: 560),
            controlsContentView.topAnchor.constraint(equalTo: gameSceneView.bottomAnchor, constant: -26),
            controlsContentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 26),
        ])
    }

}

class GameSceneView: SKView {

    var currentGame: Chip8Games?
    var gameScene: GameScene?
    var gameSceneHasBeenSet = false

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    convenience init(frame: NSRect, currentGame: Chip8Games) {
        self.init(frame: frame)
        self.currentGame = currentGame
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        let click = NSClickGestureRecognizer(target: self, action: #selector(tapHandler))
        click.numberOfClicksRequired = 1
        addGestureRecognizer(click)
        ignoresSiblingOrder = true
//        showsFPS = true
//        showsNodeCount = true
    }

    @objc func tapHandler(gesture: NSClickGestureRecognizer) {
        if gesture.state == .ended && !gameSceneHasBeenSet {
            gameSceneHasBeenSet = true
            gameScene = GameScene.newGameScene(size: frame.size, currentGame: currentGame ?? .PONG2)
            presentScene(gameScene)
        }
    }

}

struct PlayerControls: Identifiable {
    let id: UUID
    let key: String
    let instruction: String
    let keyIsLeft: Bool
}

let player1Controls = [
    PlayerControls(id: UUID(), key: "W", instruction: "To go up", keyIsLeft: true),
    PlayerControls(id: UUID(), key: "S", instruction: "To go down", keyIsLeft: true),
]
let player2Controls = [
    PlayerControls(id: UUID(), key: "I", instruction: "To go up", keyIsLeft: true),
    PlayerControls(id: UUID(), key: "K", instruction: "To go down", keyIsLeft: true),
]

struct ControlsContentView: View {
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text("Player 1 Controls")
                    Text("􀛹")
                }
                ForEach(player1Controls) {
                    ControlKeysView(key: $0.key, instruction: $0.instruction, keyIsLeft: $0.keyIsLeft)
                }
            }
            .padding()
            Spacer()
            Text("Click on the grey screen to start")
            Spacer()
            VStack {
                HStack {
                    Text("􀛹")
                    Text("Player 2 Controls")
                }
                ForEach(player2Controls) {
                    ControlKeysView(key: $0.key, instruction: $0.instruction, keyIsLeft: $0.keyIsLeft)
                }
            }
            .padding()
        }
        .foregroundColor(.green)
        .background(Color.black)
    }
}

struct ControlKeysView: View {
    let key: String
    let instruction: String
    let keyIsLeft: Bool

    var body: some View {
        HStack {
            if keyIsLeft {
                Text(instruction)
            }
            ZStack {
                Rectangle()
                    .cornerRadius(4)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.gray)
                Text(key)
            }
            if !keyIsLeft {
                Text(instruction)
            }
        }
        .foregroundColor(.green)
        .frame(width: 120, alignment: keyIsLeft ? .trailing : .leading)
    }
}
