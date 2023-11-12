//
//  Chip8CPU.swift
//  Chip8
//
//  Created by Kamaal M Farah on 11/11/2023.
//

import Foundation

enum Chip8CPUSpec {
    static let keyboardButtons = 16
    static let displayDimensions = (width: 64, height: 32)
    static let memorySize = 4096
    static let registers = 16
}

enum Chip8Inputs: UInt8 {
    case on = 0
    case off = 1
}

class Chip8CPU {
    /// For the CHIP8 virtual machine, the input comes from a 16-button keyboard (pretty convenient that the number of keys falls within a nibble).
    /// The machine is also fed with the programs it is supposed to run.
    private var keyInputs: [Chip8Inputs]
    /// For output, the machine uses a 64x32 display, and a simple sound buzzer. The display is basically just an array of pixels that are either in the on or off state.
    private var displayBuffer: [Chip8Inputs]
    /// CHIP8 has memory that can hold up to 4096 bytes. This includes the interpreter itself, the fonts (more on this later), and where it loads the program it is
    /// supposed to run (from input).
    private var memory: [Chip8Inputs]
    /// The CHIP8 has 16 8-bit registers (usually referred to as Vx where x is the register number in Cogwood's reference). These are generally used to store
    /// values for operations. The last register, Vf, is mostly used for flags and should be avoided for use in programs.
    private var gpio: [Chip8Inputs]
    /// 8-bit sound timer
    private var soundTimer: Chip8Inputs
    /// 8-bit delay timer
    private var delayTimer: Chip8Inputs
    /// 16-bit index register
    private var indexRegister: UInt16
    /// 16-bit program counter
    private var programCounter: UInt16
    /// A stack of at most 16 16-bit values, used for subroutine calls.
    private var stackPointer: [UInt16]

    init() {
        self.keyInputs = .init(repeating: .off, count: Chip8CPUSpec.keyboardButtons)
        self.displayBuffer = .init(
            repeating: .off,
            count: Chip8CPUSpec.displayDimensions.width * Chip8CPUSpec.displayDimensions.height
        )
        self.memory = .init(repeating: .off, count: Chip8CPUSpec.memorySize)
        self.gpio = .init(repeating: .off, count: Chip8CPUSpec.registers)
        self.soundTimer = .off
        self.delayTimer = .off
        self.indexRegister = 0
        self.programCounter = 0
        self.stackPointer = []
    }
}
