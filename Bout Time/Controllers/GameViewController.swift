//
//  ViewController.swift
//  Bout Time
//
//  Created by Lukas Kasakaitis on 24.03.19.
//  Copyright © 2019 Lukas Kasakaitis. All rights reserved.
//

import UIKit
import WebKit

class GameViewController: UIViewController {
    
    // MARK: - Properties
    var gameManager: Game
    var timer: Timer?
    var eventLink: URL?
    let timePerQuestion = 60
    let roundsToBePlayed = 6
    
    // MARK: - Outlets
    @IBOutlet var eventLabels: Array<UILabel>!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet var linkButtons: Array<UIButton>!
    @IBOutlet var arrowButtons: Array<UIButton>!
    @IBOutlet weak var gameControl: UIButton!

    
    // MARK: - App Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateLabels()
        resetTimer()
    }
    
    // MARK: - Navigation
    
    
    /**
     Called when a segue is about to be performed.
     
     - Parameters:
     - segue: The segue object containing information about the view controllers involved in the segue.
     - sender: The object that initiated the segue. You might use this parameter to perform different actions based on which control (or other object) initiated the segue.
     
     - Returns: Void
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebViewForEvent" {
            let webViewController = segue.destination as! WebViewController
            webViewController.eventLink = eventLink
        }
        
        if segue.identifier == "displayFinalScore" {
            let scoreViewController = segue.destination as! ScoreViewController
            scoreViewController.score = String(gameManager.score) + "\\" + String(gameManager.numberOfRoundsPlayed)
        }
    }
    
    // To hide the status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    /**
     Initializes a new Game by populated the model with data from a property list
     
     - Throws: error if property list is not found or invalid
     
     - Parameters:
     - aDecoder: An abstract class that serves as the basis for objects that enable archiving and distribution of other objects.
     
     - Returns: GameManger
     */
    required init?(coder aDecoder: NSCoder) {
        do {
            let pList = try PlistConverter.array(fromFile: "Events", ofType: "plist")
            let eventData = EventsUnarchiver.getData(fromData: pList)
            self.gameManager = GameManager(roundsToBePlayed: roundsToBePlayed, events: eventData, timePerQuestion: timePerQuestion)
        } catch let error {
            fatalError("Data could not be loaded: \(error)")
        }
        
        super.init(coder: aDecoder)
    }
    
    // MARK: - Helper Methods
    
    /**
     Reset timer which initiates the timer
     
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
        
        gameControl.setTitle("0:" + String(format: "%02d", gameManager.timePerQuestion), for: .normal)
        
        if gameManager.timePerQuestion == 10 {
            gameControl.setTitleColor(UIColor.red, for: .normal)
        }
        
        // Stop The Timer
        if gameManager.timePerQuestion == 0 {
            gameManager.timePerQuestion = timePerQuestion
            toggleArrowButtons()
            toggleLinkButtons()
            isPlayerCorrect()
        }
    }
    
    /**
     Populate Labels with event desriptions
     
     - Returns: Void
     */
    func populateLabels() {
        var i = 0
        for label in eventLabels {
            label.text = gameManager.roundEvents[i].eventDescription
            i += 1
        }
    }
    
    /**
     Toggle (Enable/Disable) arrow control buttons
     
     - Returns: Void
     */
    func toggleArrowButtons() {
        for arrowButton in arrowButtons {
            arrowButton.isEnabled = !arrowButton.isEnabled
        }
    }
    
    /**
     Toggle (Enable/Disable) link control buttons
     
     - Returns: Void
     */
    func toggleLinkButtons() {
        for linkButton in linkButtons {
            linkButton.isEnabled = !linkButton.isEnabled
        }
    }

    /**
     Checks if the player order is chronological and update the UI acordingly
     
     - Returns: Void
     */
    func isPlayerCorrect() {
        infoLabel.text = "Tap events to learn more"
        
        if gameManager.playerPutEventsInCorrectOrder(gameManager.roundEvents) {
            gameControl.setTitle("", for: .normal)
            gameControl.setBackgroundImage(UIImage(named: "next_round_success.png"), for: .normal)
            gameControl.isEnabled = true
            SoundManager.playGameCorrectSound()
        } else {
            gameControl.setTitle("", for: .normal)
            gameControl.setBackgroundImage(UIImage(named: "next_round_fail.png"), for: .normal)
            gameControl.isEnabled = true
            SoundManager.playGameIncorrectSound()
        }
        timer?.invalidate()
        gameManager.timePerQuestion = timePerQuestion
    }
    
    /**
     Detects when a shake gesture is completed and checks if the event order is chronological
     
     - Parameters:
     - motion: Specifies the subtype of the event in relation to its general type.
     - event: An object that describes a single user interaction with your app.
     
     - Returns: Void
     */
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            isPlayerCorrect()
        }
        timer?.invalidate()
        toggleArrowButtons()
        toggleLinkButtons()
    }
    
    // MARK: - Actions
    
    /**
     Rearanges the events in the array and labels on screen.
     
     - Parameters:
     - sender: The button tapped
     
     - Returns: Void
     */
    @IBAction func reOrder(_ sender: UIButton) {

        SoundManager.playButtonClickSound()
        
        switch sender.tag {
        case 0, 1:
            eventLabels[0].text = gameManager.roundEvents[1].eventDescription
            eventLabels[1].text = gameManager.roundEvents[0].eventDescription
            gameManager.setPlayerEventOrder(0, 1)
        case 2, 3:
            eventLabels[1].text = gameManager.roundEvents[2].eventDescription
            eventLabels[2].text = gameManager.roundEvents[1].eventDescription
            gameManager.setPlayerEventOrder(1, 2)
        case 4, 5:
            eventLabels[2].text = gameManager.roundEvents[3].eventDescription
            eventLabels[3].text = gameManager.roundEvents[2].eventDescription
            gameManager.setPlayerEventOrder(2, 3)
        default:
            eventLabels[0].text = eventLabels[0].text
            eventLabels[1].text = eventLabels[1].text
            eventLabels[2].text = eventLabels[2].text
            eventLabels[3].text = eventLabels[3].text
        }
        
    }
    
    /**
     Goes to next round with new events and order
     
     - Returns: Void
     */
    @IBAction func nextRound() {
        
        infoLabel.text = "Shake to complete"
        
        toggleLinkButtons()
        toggleArrowButtons()
        
        if gameManager.numberOfRoundsPlayed != roundsToBePlayed {
            gameManager.nextRound()
            gameControl.setBackgroundImage(nil, for: .normal)
            gameControl.isEnabled = false
            resetTimer()
            populateLabels()
        } else {
            performSegue(withIdentifier: "displayFinalScore", sender: nil)
        }
    }
    
    /**
     Opens a webview in a new View
     
     - Parameters:
     - sender: The button tapped
     
     - Returns: Void
     */
    @IBAction func showWebsite(_ sender: UIButton) {
        eventLink = URL(string: gameManager.roundEvents[sender.tag].eventLink)
        performSegue(withIdentifier: "showWebViewForEvent", sender: nil)
    }
    
}

