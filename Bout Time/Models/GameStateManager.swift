//
//  GameStateManager.swift
//  Bout Time
//
//  Created by Lukas Kasakaitis on 26.03.19.
//  Copyright © 2019 Lukas Kasakaitis. All rights reserved.
//

import Foundation

protocol HistoricalEvent {
    var eventDescription: String { get }
    var eventDate: Date { get }
    var eventLink: String { get }
}

protocol Game {
    var roundsToBePlayed: Int { get set }
    var numberOfRoundsPlayed: Int { get }
    var timePerQuestion: Int { get set }
    var score: Int { get set }
    var roundEvents: [HistoricalEvent] { get set }
    var events: [HistoricalEvent] { get set }
    
    init(roundsToBePlayed: Int, events: [HistoricalEvent], timePerQuestion: Int)
    func getEventsForRound() throws -> [HistoricalEvent] // 4 Events
    func playerPutEventsInCorrectOrder(_ events: [HistoricalEvent]) -> Bool
    func setPlayerEventOrder(_ firstIndex: Int, _ secondIndex: Int) -> Void
    func nextRound() -> Void
    func playAgain() -> Void
}

struct Event: HistoricalEvent {
    var eventDescription: String
    var eventDate: Date
    var eventLink: String
}

enum InventoryError: Error {
    case invalidResource
    case conversionFailure
    case invalidSelection
}

class PlistConverter {
    static func array(fromFile name: String, ofType type: String) throws -> [[String:Any]] {
        
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            throw InventoryError.invalidResource
        }
        
        guard let array = NSArray(contentsOfFile: path) as? [[String:Any]] else {
            throw InventoryError.conversionFailure
        }
        
        return array
    }
}

class EventsUnarchiver {
    static func getData(fromData data: [[String:Any]]) -> [HistoricalEvent] {
        var events: [HistoricalEvent] = []
        
        for value in data {
            if let eventDescription = value["Event"] as? String,
            let eventDate = value["Date"] as? Date,
            let eventLink = value["Link"] as? String {
                let event = Event(eventDescription: eventDescription, eventDate: eventDate, eventLink: eventLink)
                events.append(event)
            }
        }
        
        return events
    }
}


class GameManager: Game {
    
    /// Properties
    var score: Int = 0
    var numberOfRoundsPlayed: Int = 0
    var roundsToBePlayed: Int
    var timePerQuestion: Int
    var events: [HistoricalEvent]
    var roundEvents = [HistoricalEvent]()
    
    required init(roundsToBePlayed: Int, events: [HistoricalEvent], timePerQuestion: Int) {
        self.roundsToBePlayed = roundsToBePlayed
        self.events = events
        self.timePerQuestion = timePerQuestion
        self.roundEvents = getEventsForRound()
    }
    
    func getEventsForRound() -> [HistoricalEvent] {
        var roundEvents = [HistoricalEvent]()
        self.events.shuffle()
        
        for i in 0...3 {
            roundEvents.append(self.events[i])
        }
        
        return roundEvents
    }
    
    func playerPutEventsInCorrectOrder(_ events: [HistoricalEvent]) -> Bool {
        var orderIsCorrect = true
        var correctOrder = roundEvents
        
        correctOrder.sort {
            return $0.eventDate < $1.eventDate
        }
        
        for i in 0..<roundEvents.count {
            if roundEvents[i].eventDate != correctOrder[i].eventDate {
                orderIsCorrect = false
            }
        }
        
        if orderIsCorrect {
            score += 1

        }
        
        numberOfRoundsPlayed += 1
        
        return orderIsCorrect
        
    }
    
    func setPlayerEventOrder(_ firstIndex: Int, _ secondIndex: Int) {
        roundEvents.swapAt(firstIndex, secondIndex)
    }
    
    func nextRound() {
        roundEvents = getEventsForRound()
    }
    
    func playAgain() {
        score = 0
        numberOfRoundsPlayed = 0
    }
    
    
    
}
