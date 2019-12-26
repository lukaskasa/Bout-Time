//
//  SoundManager.swift
//  Bout Time
//
//  Created by Lukas Kasakaitis on 29.03.19.
//  Copyright © 2019 Lukas Kasakaitis. All rights reserved.
//

import AudioToolbox

struct SoundManager {
    
    // MARK: - Computed properties
    
    // Sound properties represent each sound file
    private static var gameCorrectSound: SystemSoundID {
        let correctSoundPath = Bundle.main.path(forResource: "CorrectDing", ofType: "wav")
        let soundUrl = URL(fileURLWithPath: correctSoundPath!)
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundID)
        return soundID
    }
    
    private static var gameIncorrectSound: SystemSoundID {
        let incorrectSoundPath = Bundle.main.path(forResource: "IncorrectBuzz", ofType: "wav")
        let soundUrl = URL(fileURLWithPath: incorrectSoundPath!)
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundID)
        return soundID
    }
    
    private static var buttonClickSound: SystemSoundID {
        let buttonClickSoundPath = Bundle.main.path(forResource: "ButtonClick", ofType: "wav")
        let soundUrl = URL(fileURLWithPath: buttonClickSoundPath!)
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundID)
        return soundID
    }
    
    // MARK: - Methods to play each sound
    
    static func playGameCorrectSound() {
        AudioServicesPlaySystemSound(gameCorrectSound)
    }
    
    static func playGameIncorrectSound() {
        AudioServicesPlaySystemSound(gameIncorrectSound)
    }
    
    static func playButtonClickSound() {
        AudioServicesPlaySystemSound(buttonClickSound)
    }
    
}
