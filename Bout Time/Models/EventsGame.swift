//
//  GameStateManager.swift
//  Bout Time
//
//  Created by Lukas Kasakaitis on 26.03.19.
//  Copyright © 2019 Lukas Kasakaitis. All rights reserved.
//

import Foundation

// MARK: - Protocols, enums and structs

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
    
    init(roundsToBePlayed: Int, timePerQuestion: Int)
    func getEventsFromPropertyList() -> [HistoricalEvent]
    func getEventsForRound() throws -> [HistoricalEvent] // 4 Events
    func playerPutEventsInCorrectOrder(_ events: [HistoricalEvent]) -> Bool
    func setPlayerEventOrder(_ firstIndex: Int, _ secondIndex: Int) -> Void
    func nextRound() -> Void
}

struct Event: HistoricalEvent {
    var eventDescription: String
    var eventDate: Date
    var eventLink: String
}

enum ConversionError: Error {
    case invalidResource
    case conversionFailure
}


class PlistConverter {
    
    /**
     Converts a property list into an array of dictionaries
     
     - Parameters:
     - name: Filename
     - type: Type of data
     
     - Returns: [[String:Any]]
     */
    static func array(fromFile name: String, ofType type: String) throws -> [[String:Any]] {
        
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            throw ConversionError.invalidResource
        }
        
        guard let array = NSArray(contentsOfFile: path) as? [[String:Any]] else {
            throw ConversionError.conversionFailure
        }
        
        return array
    }
}

class EventsUnarchiver {
    
    /**
     Converts array of dictionaries into an array of HistoricalEvent dictionaries
     
     - Parameters:
     - data: Array of dictionaries
     
     - Returns: [HistoricalEvent]
     */
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
    
    // MARK: - Game Properties
    var score: Int = 0
    var numberOfRoundsPlayed: Int = 0
    var roundsToBePlayed: Int
    var timePerQuestion: Int
    var events = [HistoricalEvent]()
    var roundEvents = [HistoricalEvent]()
    
    /**
     Initializes a new Game
     
     - Parameters:
     - roundsToBePlayed:
     - events:
     - timePerQuestion:
     
     - Returns: Void
     */
    required init(roundsToBePlayed: Int, timePerQuestion: Int) {
        self.roundsToBePlayed = roundsToBePlayed
        self.timePerQuestion = timePerQuestion
        self.events = getEventsFromPropertyList()
        self.roundEvents = getEventsForRound()
    }
    
    /**
     Gets all the events in the property list
     
     - Returns: [HistoricalEvent]
     */
    internal func getEventsFromPropertyList() -> [HistoricalEvent] {
        do {
            let propertyList = try PlistConverter.array(fromFile: "Events", ofType: "plist")
            return EventsUnarchiver.getData(fromData: propertyList)
        } catch let error {
            fatalError("Property list converted/found: \(error)")
        }
    }
    
    /**
     Gets 4 Random Historical events
     
     - Returns: [HistoricalEvent]
     */
    internal func getEventsForRound() -> [HistoricalEvent] {
        var roundEvents = [HistoricalEvent]()
        self.events.shuffle()
        
        for i in 0...3 {
            roundEvents.append(self.events[i])
        }
        
        return roundEvents
    }
    
    /**
     Checks if player order of events is chronological
     
     - Parameters:
     - events: Array of HistoricalEvent
     
     - Returns: Bool
     */
    public func playerPutEventsInCorrectOrder(_ events: [HistoricalEvent]) -> Bool {
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
    
    /**
     Rearanges array
     
     - Parameters:
     - firstIndex: Int
     - secondIndex: Int
     
     - Returns: Void
     */
    public func setPlayerEventOrder(_ firstIndex: Int, _ secondIndex: Int) {
        roundEvents.swapAt(firstIndex, secondIndex)
    }
    
    /**
     Gets new set of random events

     - Returns: Void
     */
    public func nextRound() {
        roundEvents = getEventsForRound()
    }

}
