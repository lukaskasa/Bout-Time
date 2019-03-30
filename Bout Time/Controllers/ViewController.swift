//
//  ViewController.swift
//  Bout Time
//
//  Created by Lukas Kasakaitis on 24.03.19.
//  Copyright © 2019 Lukas Kasakaitis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var gameManager: Game
    var timer: Timer?
    let timePerQuestion = 60
    
    @IBOutlet var eventLabels: Array<UILabel>!
    @IBOutlet weak var gameControl: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        populateLabels()
        resetTimer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        do {
            let pList = try PlistConverter.array(fromFile: "Events", ofType: "plist")
            let eventData = EventsUnarchiver.getData(fromData: pList)
            self.gameManager = GameManager(roundsToBePlayed: 6, events: eventData, timePerQuestion: timePerQuestion)
            //self.roundEvents = try gameManager.getEventsForRound()
        } catch let error {
            fatalError("\(error)")
        }
        
        super.init(coder: aDecoder)
    }
    
    // MARK: - Helper Functions
    
    /**
     Reset timer.
     
     - Returns: Void
     */
    func resetTimer() {
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(startTimer), userInfo: nil, repeats: true)
        gameControl.setTitleColor(UIColor.white, for: .normal)
    }
    
    /**
     Start the timer.
     
     - Returns: Void
     */
    @objc func startTimer() {
        gameManager.timePerQuestion -= 1
        gameControl.setTitle("0:\(gameManager.timePerQuestion)", for: .normal)
        
        if gameManager.timePerQuestion == 10 {
            gameControl.setTitleColor(UIColor.red, for: .normal)
        }
        
        // Stop The Timer
        if gameManager.timePerQuestion == 0 {
            gameManager.timePerQuestion = timePerQuestion
            isPlayerCorrect()
        }
    }
    
    func populateLabels() {
        var i = 0
        for label in eventLabels {
            label.text = gameManager.roundEvents[i].eventDescription
            i += 1
        }
    }
    
    func isPlayerCorrect() {
        if gameManager.playerPutEventsInCorrectOrder(gameManager.roundEvents) {
            gameControl.setTitle("", for: .normal)
            gameControl.setBackgroundImage(UIImage(named: "next_round_success.png"), for: .normal)
            gameControl.isEnabled = true
        } else {
            gameControl.setTitle("", for: .normal)
            gameControl.setBackgroundImage(UIImage(named: "next_round_fail.png"), for: .normal)
            gameControl.isEnabled = true
        }
        timer?.invalidate()
        gameManager.timePerQuestion = timePerQuestion
    }
    
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            isPlayerCorrect()
        }
        timer?.invalidate()
    }
    
    // MARK: - Actions
    @IBAction func reOrder(_ sender: UIButton) {
        
        switch sender.tag {
        case 0, 1:
            gameManager.setPlayerEventOrder(0, 1)
            let event1 = eventLabels[0].text
            let event2 = eventLabels[1].text
            eventLabels[0].text = event2
            eventLabels[1].text = event1
        case 2, 3:
            //roundEvents.swapAt(1, 2)
            gameManager.setPlayerEventOrder(1, 2)
            let event2 = eventLabels[1].text
            let event3 = eventLabels[2].text
            eventLabels[1].text = event3
            eventLabels[2].text = event2
        case 4, 5:
            gameManager.setPlayerEventOrder(2, 3)
            let event3 = eventLabels[2].text
            let event4 = eventLabels[3].text
            eventLabels[2].text = event4
            eventLabels[3].text = event3
        default:
            eventLabels[0].text = eventLabels[0].text
            eventLabels[1].text = eventLabels[1].text
            eventLabels[2].text = eventLabels[2].text
            eventLabels[3].text = eventLabels[3].text
        }
        
        
    }
    
    
    @IBAction func nextRound() {
        gameManager.nextRound()
        //gameControl.setTitle("playing...", for: .normal)
        resetTimer()
        gameControl.setBackgroundImage(nil, for: .normal)
        gameControl.isEnabled = false
        populateLabels()
    }
    
}

