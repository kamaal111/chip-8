//
//  Chip8CPU.swift
//  chip-8
//
//  Created by Kamaal Farah on 19/04/2020.
//  Copyright © 2020 Kamaal. All rights reserved.
//

import Foundation

/// The Chip-8 CPU core implementation
///
/// The specifications of Chip-8.
struct Chip8CPU {
    private let debugging = true

    /// Current operation code.
    ///
    /// CHIP-8 has 35 operation codes. which are all two bytes long and stored big-endian.
    var opcode: UInt16 = 0

    /// 16 8-bit data registers referred to as V0 to VF.
    ///
    /// VF doubles as a flag for some instructions; thus, it should be avoided.
    var vRegisters = [UInt8](repeating: 0, count: 16)

    /// 4kb (4,096 bytes) of RAM.
    ///
    /// CHIP-8 was most commonly implemented on 4K systems, such as the Cosmac VIP and the Telmac 1800.
    var memory = [UInt8](repeating: 0, count: 4096)

    /// keypad state
    ///
    /// Chip 8 has a HEX based keypad (0x0-0xF), you can use an array to store the current state of the key.
    var key = [UInt8](repeating: 0, count: 16)

    /// graphics memory (64 x 32 pixels)
    ///
    /// The graphics of the Chip 8 are black and white and the screen has a total of 2048 pixels (64 x 32).
    /// This can easily be implemented using an array that hold the pixel state (1 or 0).
    var graphics = [UInt8](repeating: 0, count: 64 * 32)

    /// A stack of 16 16-bit values, used for subroutine calls.
    var stack = [UInt16](repeating: 0, count: 16)

    /// 16-bit program counter
    var programCounter: UInt16 = 0x200

    /// 8-bit stack pointer
    var stackPointer: UInt8 = 0

    /// 8-bit delay timer
    var delayTimer: UInt8 = 0

    /// 8-bit sound timer
    var soundTimer: UInt8 = 0

    /// 16-bit index register
    var indexRegister: UInt16 = 0

    /// Whether or not to draw
    var drawFlag = false

    /// CHIP-8 fontset
    let chip8Fontset: [UInt8] = [
        0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
        0x20, 0x60, 0x20, 0x20, 0x70, // 1
        0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
        0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
        0x90, 0x90, 0xF0, 0x10, 0x10, // 4
        0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
        0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
        0xF0, 0x10, 0x20, 0x40, 0x40, // 7
        0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
        0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
        0xF0, 0x90, 0xF0, 0x90, 0x90, // A
        0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
        0xF0, 0x80, 0x80, 0x80, 0xF0, // C
        0xE0, 0x90, 0x90, 0x90, 0xE0, // D
        0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
        0xF0, 0x80, 0xF0, 0x80, 0x80  // F
    ]

    init() {
      // load fontset
      for index in 0...chip8Fontset.count-1 {
        memory[index] = chip8Fontset[index]
      }
      // reset timers
      srand48(time(nil))
    }

    /// This function loads a given rom in to memory.
    ///
    /// - Parameters:
    ///     - programName: The name of the rom to load
    mutating func loadProgram(withName programName: Chip8Games) {
        guard let path = Bundle.main.path(forResource: programName.rawValue, ofType: nil) else {
            fatalError("Could not find program with the name \(programName)")
        }
        // input stream to read file data in
        guard let inputStream = InputStream(fileAtPath: path) else {
            fatalError("Could not read file at \(path)")
        }
        // buffer to store data read
        var inputBuffer = [UInt8](repeating: 0, count: 4096-512)
        // read file into buffer
        inputStream.open()
        inputStream.read(&inputBuffer, maxLength: inputBuffer.count)
        inputStream.close()
        // load buffer into memory starting at 0x200
        for i in 0...inputBuffer.count-1 {
            memory[i + 512] = inputBuffer[i]
        }
    }

    /// Every cycle, the method emulateCycle is called which emulates one cycle of the Chip 8 CPU.
    /// During this cycle, the emulator will Fetch, Decode and Execute one opcode.
    mutating func emulateCycles() {
        // Fetch Opcode
        let counter = Int(exactly: programCounter)!
        opcode = (UInt16(memory[counter]) << 8) | UInt16(memory[counter + 1])
        debugPrint(words: "opcode: \(getHEXString(number: opcode))")
        // Decode and Execurte Opcode
        switch opcode & 0xF000 {
        case 0x0000:
            switch opcode & 0x000F {
            case 0x0000: // 00E0    Clears the screen.
                debugPrint(words: "Clearing the screen")
                graphics = [UInt8](repeating: 0, count: 64 * 32)
                drawFlag = true
                programCounter += 2
                break
            case 0x000E: // 00EE    Returns from a subroutine.
                debugPrint(words: "Returning from subroutine")
                stackPointer -= 1
                programCounter = stack[Int(stackPointer)]
                programCounter += 2
                break
            default: // unknown
                debugPrint(words: "Unknown opcode \(getHEXString(number: opcode))")
                break
            }
            break
        case 0x1000: // 1NNN    Jumps to address NNN.
            programCounter = opcode & 0x0FFF
            debugPrint(words: "Jumping to address \(getHEXString(number: programCounter))")
            break
        case 0x2000: // 2NNN    Calls subroutine at NNN.
            stack[Int(stackPointer)] = programCounter
            stackPointer += 1
            programCounter = opcode & 0x0FFF
            debugPrint(words: "Calling subroutine at \(getHEXString(number: programCounter))")
            break
        case 0x3000: // 3XNN    Skips the next instruction if VX equals NN.
            let X = Int((opcode & 0x0F00) >> 8)
            let NN = UInt8(opcode & 0x00FF)
            debugPrint(words: "Skipping next instruction if vRegisters[\(X)] == \(getHEXString(number: NN))")
            if vRegisters[X] == NN {
                programCounter += 4
            } else {
                programCounter += 2
            }
            break
        case 0x4000: // 4XNN    Skips the next instruction if VX doesn't equal NN.
            let X = Int((opcode & 0x0F00) >> 8)
            let NN = UInt8(opcode & 0x00FF)
            debugPrint(words: "Skipping next instruction if vRegisters[\(X)] != \(getHEXString(number: NN))")
            if vRegisters[X] != NN {
                programCounter += 4
            } else {
                programCounter += 2
            }
            break
        case 0x5000: // 5XY0    Skips the next instruction if VX equals VY.
            let X = Int((opcode & 0x0F00) >> 8)
            let Y = Int((opcode & 0x00F0) >> 4)
            debugPrint(words: "Skipping next instruction if vRegisters[\(X)] == vRegisters[\(Y)]")
            if vRegisters[X] == vRegisters[Y] {
                programCounter += 4
            } else {
                programCounter += 2
            }
            break
        case 0x6000: // 6XNN    Sets VX to NN.
            let X = Int((opcode & 0x0F00) >> 8)
            let NN = UInt8(opcode & 0x00FF)
            debugPrint(words: "Setting vRegisters[\(X)] = \(getHEXString(number: NN))")
            vRegisters[X] = NN
            programCounter += 2
            break
        case 0x7000: // 7XNN    Adds NN to VX.
          
          let X = Int((opcode & 0x0F00) >> 8)
          let NN = UInt8(opcode & 0x00FF)
          
          debugPrint(words: "Adding \(getHEXString(number: NN)) to vRegisters[\(X)]")
          
          vRegisters[X] = vRegisters[X] &+ NN
          
          programCounter += 2
          
          break
          
        case 0x8000:
          
          switch opcode & 0x000F {
            
          case 0x0000: // 8XY0    Sets VX to the value of VY.
            
            let X = Int((opcode & 0x0F00) >> 8)
            let Y = Int((opcode & 0x00F0) >> 4)
            
            debugPrint(words: "Setting vRegisters[\(X)] to vRegisters[\(Y)]")
            
            vRegisters[X] = vRegisters[Y]
            
            programCounter += 2
            
            break
            
          case 0x0001: // 8XY1    Sets VX to VX or VY.
            
            let X = Int((opcode & 0x0F00) >> 8)
            let Y = Int((opcode & 0x00F0) >> 4)
            
            debugPrint(words: "Setting vRegisters[\(X)] to vRegisters[\(X)] | vRegisters[\(Y)]")
            
            vRegisters[X] |= vRegisters[Y]
            
            programCounter += 2
            
            break
            
          case 0x0002: // 8XY2    Sets VX to VX and VY.
            
            let X = Int((opcode & 0x0F00) >> 8)
            let Y = Int((opcode & 0x00F0) >> 4)
            
            debugPrint(words: "Setting vRegisters[\(X)] to vRegisters[\(X)] & vRegisters[\(Y)]")
            
            vRegisters[X] &= vRegisters[Y]
            
            programCounter += 2
            
            break
            
          case 0x0003: // 8XY3    Sets VX to VX xor VY.
            
            let X = Int((opcode & 0x0F00) >> 8)
            let Y = Int((opcode & 0x00F0) >> 4)
            
            debugPrint(words: "Setting vRegisters[\(X)] to vRegisters[\(X)] ^ vRegisters[\(Y)]")
            
            vRegisters[X] ^= vRegisters[Y]
            
            programCounter += 2
            
            break
            
          case 0x0004: // 8XY4    Adds VY to VX. VF is set to 1 when there's a carry, and to 0 when there isn't.
            
            let X = Int((opcode & 0x0F00) >> 8)
            let Y = Int((opcode & 0x00F0) >> 4)
            
            debugPrint(words: "Adding vRegisters[\(Y)] to vRegisters[\(X)]")
            
            if vRegisters[Y] > (0xFF - vRegisters[X]) {
              vRegisters[0xF] = 1
            } else {
              vRegisters[0xF] = 0
            }
            
            vRegisters[X] = vRegisters[X] &+ vRegisters[Y]
            
            programCounter += 2
            
            break
            
          case 0x0005: // 8XY5    VY is subtracted from VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
            
            let X = Int((opcode & 0x0F00) >> 8)
            let Y = Int((opcode & 0x00F0) >> 4)
            
            debugPrint(words: "Subtracting vRegisters[\(Y)] from vRegisters[\(X)]")
            
            if vRegisters[Y] > vRegisters[X] {
              vRegisters[0xF] = 0
            } else {
              vRegisters[0xF] = 1
            }
            
            vRegisters[X] = vRegisters[X] &- vRegisters[Y]
            
            programCounter += 2
            
            break
            
          case 0x0006: // 8XY6    Shifts VX right by one. VF is set to the value of the least significant bit of VX before the shift.
            
            let X = Int((opcode & 0x0F00) >> 8)
            
            debugPrint(words: "Shifting vRegisters[\(X)] right by 1")
            
            vRegisters[0xF] = vRegisters[X] & 0x1
            
            vRegisters[X] >>= 1
            
            programCounter += 2
            
            break
            
          case 0x0007: // 8XY7    Sets VX to VY minus VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
            
            let X = Int((opcode & 0x0F00) >> 8)
            let Y = Int((opcode & 0x00F0) >> 4)
            
            debugPrint(words: "Setting vRegisters[\(X)] to vRegisters[\(Y)] minus vRegisters[\(X)]")
            
            if vRegisters[X] > vRegisters[Y] {
              vRegisters[0xF] = 0
            } else {
              vRegisters[0xF] = 1
            }
            
            vRegisters[X] = vRegisters[Y] &- vRegisters[X]
            
            programCounter += 2
            
            break
            
          case 0x000E: // 8XYE    Shifts VX left by one. VF is set to the value of the most significant bit of VX before the shift.
            
            let X = Int((opcode & 0x0F00) >> 8)
            
            debugPrint(words: "Shifting vRegisters[\(X)] left by 1")
            
            vRegisters[0xF] = vRegisters[X] >> 7
            
            vRegisters[X] <<= 1
            
            programCounter += 2
            
            break
            
          default: // unknown
            print("Unknown opcode \(opcode)")
            break
          }
          
          break
          
        case 0x9000: // 9XY0    Skips the next instruction if VX doesn't equal VY.
          
          let X = Int((opcode & 0x0F00) >> 8)
          let Y = Int((opcode & 0x00F0) >> 4)
          
          debugPrint(words: "Skipping next instruction if vRegisters[\(X)] != vRegisters[\(Y)]")
          
          if vRegisters[X] != vRegisters[Y] {
            programCounter += 4
          } else {
            programCounter += 2
          }
          
          break
          
        case 0xA000: // ANNN    Sets I to the address NNN.
          
          indexRegister = opcode & 0x0FFF
          
          debugPrint(words: "Setting I to \(getHEXString(number: indexRegister))")
          
          programCounter += 2
          
          break
          
        case 0xB000: // BNNN    Jumps to the address NNN plus V0.
          
          programCounter = (opcode & 0x0FFF) + UInt16(vRegisters[0])
          
          debugPrint(words: "Jumping to \(getHEXString(number: programCounter))")
          
          break
          
        case 0xC000: // CXNN    Sets VX to the result of a bitwise and operation on a random number and NN.
          
          let X = Int((opcode & 0x0F00) >> 8)
          let NN = UInt8(opcode & 0x00FF)
          let rn = UInt8(arc4random() % 0xFF)
          
          debugPrint(words: "Setting vRegisters[\(X)] to \(getHEXString(number: NN)) & \(getHEXString(number: rn))")
          
          vRegisters[X] = NN & rn
          
          programCounter += 2
          
          break
          
        case 0xD000: // Draws a sprite at coordinate (VX, VY) that has a width of 8 pixels and a height of N pixels. Each row of 8 pixels is read as bit-coded starting from memory location I; I value doesn’t change after the execution of this instruction. As described above, VF is set to 1 if any screen pixels are flipped from set to unset when the sprite is drawn, and to 0 if that doesn’t happen
          let x = UInt16(vRegisters[Int((opcode & 0x0F00) >> 8)])
          let y = UInt16(vRegisters[Int((opcode & 0x00F0) >> 4)])
          let height = UInt16(opcode & 0x000F)
          var pixel: UInt16 = 0
          debugPrint(words: "Drawing sprite at (\(x), \(y)) h:\(height)")
          vRegisters[0xF] = 0
          for yLine in 0...height-1 {
            pixel = UInt16(memory[Int(indexRegister + yLine)])
            for xLine in 0...7 {
              if (pixel & UInt16(0x80 >> UInt8(xLine)) != 0) {
                let gfxLocation = (Int(x) + xLine + Int((y + yLine) * 64))
//                if gfxLocation <= graphics.count {
                if graphics[gfxLocation] == 1 {
                   vRegisters[0xF] = 1
                 }
                 graphics[gfxLocation] = graphics[gfxLocation] ^ 1
//                }
              }
            }
          }
          drawFlag = true
          programCounter += 2
          break
        case 0xE000:
          
          switch opcode & 0x000F {
            
          case 0x000E: // EX9E    Skips the next instruction if the key stored in VX is pressed.
            
            let X = Int((opcode & 0x0F00) >> 8)
            
            if key[Int(vRegisters[X])] != 0 {
              programCounter += 4
            } else {
              programCounter += 2
            }
            
            break
            
          case 0x0001: // EXA1    Skips the next instruction if the key stored in VX isn't pressed.
            
            let X = Int((opcode & 0x0F00) >> 8)
            
            if key[Int(vRegisters[X])] == 0 {
              programCounter += 4
            } else {
              programCounter += 2
            }
            
            break
            
          default: // unknown
            print("Unknown opcode \(opcode)")
            break
          }
          
          break
          
        case 0xF000:
          
          switch opcode & 0x00FF {
            
          case 0x0007: // FX07    Sets VX to the value of the delay timer.
            
            let X = Int((opcode & 0x0F00) >> 8)
            
            vRegisters[X] = delayTimer
            
            programCounter += 2
            
            break
            
          case 0x000A: // FX0A    A key press is awaited, and then stored in VX.
            
            let X = Int((opcode & 0x0F00) >> 8)
            var keyPressed = false
            
            for i in 0...key.count-1 {
              if key[i] != 0 {
                vRegisters[X] = UInt8(i)
                keyPressed = true
              }
            }
            
            if keyPressed == false {
              return;
            }
            
            programCounter += 2
            
            break
            
          case 0x0015: // FX15    Sets the delay timer to VX.
            
            let X = Int((opcode & 0x0F00) >> 8)
            
            delayTimer = vRegisters[X]
            
            programCounter += 2
            
            break
            
          case 0x0018: // FX18    Sets the sound timer to VX.
            
            let X = Int((opcode & 0x0F00) >> 8)
            
            soundTimer = vRegisters[X]
            
            programCounter += 2
            
            break
            
          case 0x001E: // FX1E    Adds VX to I.
            
            let X = Int((opcode & 0x0F00) >> 8)
            
            if(indexRegister + UInt16(vRegisters[X]) > 0xFFF) {    // VF is set to 1 when range overflow (I+VX>0xFFF), and 0 when there isn't.
              vRegisters[0xF] = 1
            } else {
              vRegisters[0xF] = 0
            }
            
            indexRegister += UInt16(vRegisters[X])
            
            programCounter += 2
            
            break
            
          case 0x0029: // FX29  Sets I to the location of the sprite for the character in VX. Characters 0-F (in hexadecimal) are represented by a 4x5 font.
            
            let X = Int((opcode & 0x0F00) >> 8)
            
            indexRegister = UInt16(vRegisters[X] * 0x5)
            
            programCounter += 2
            
            break
            
          case 0x0033: // FX33  Stores the binary-coded decimal representation of VX, with the most significant of three digits at the address in I, the middle digit at I plus 1, and the least significant digit at I plus 2.
            
            let xIndex = Int((opcode & 0x0F00) >> 8)
            let mIndex = Int(indexRegister)
            
            // TODO: look into this
            
            memory[mIndex] =      (vRegisters[xIndex] / 100)
            memory[mIndex + 1] =  (vRegisters[xIndex] / 10) % 10
            memory[mIndex + 2] =  (vRegisters[xIndex] % 100) % 10
            
            programCounter += 2
            
            break
            
          case 0x0055: // FX55  Stores V0 to VX (including VX) in memory starting at address I.
            
            let X = Int((opcode & 0x0F00) >> 8)
            
            for i in 0...X {
              let mIndex = Int(indexRegister) + i
              memory[mIndex] = vRegisters[i]
            }
            
            indexRegister += ((opcode & 0x0F00) >> 8) + 1
            
            programCounter += 2
            
            break
            
          case 0x0065: // FX65  Fills V0 to VX (including VX) with values from memory starting at address I.
            
            let X = Int((opcode & 0x0F00) >> 8)
            
            for i in 0...X {
              let mIndex = Int(indexRegister) + i
              vRegisters[i] = memory[mIndex]
            }
            
            indexRegister += ((opcode & 0x0F00) >> 8) + 1
            
            programCounter += 2
            
            break
            
          default: // unknown
            print("Unknown opcode \(opcode)")
            break
          }
          
          break
          
        default: // unknown
          print("Unknown opcode \(opcode)")
          break
        }
        // Update timers
        if delayTimer > 0 {
          delayTimer = delayTimer - 1
        }
        
        if soundTimer > 0 {
          if soundTimer == 1 {
            print("BEEP!")
          }
          soundTimer = soundTimer - 1
        }
    }

    func printGfx() {
      
      var str = ""
      
      for y in 0...31 {
        for x in 0...63 {
          str += (graphics[x + (64 * y)] == 1 ? "O" : " ")
        }
        
        str += "\n"
      }
      
      print(str)
    }

    private func getHEXString(number: UInt16) -> String {
      return String(format:"%2X", number)
    }
    
    private func getHEXString(number: UInt8) -> String {
      return String(format:"%2X", number)
    }
    
    private func debugPrint(words: String) {
      if debugging {
        print(words)
      }
    }
}
