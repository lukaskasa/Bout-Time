//
//  ScoreViewController.swift
//  Bout Time
//
//  Created by Lukas Kasakaitis on 30.03.19.
//  Copyright © 2019 Lukas Kasakaitis. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController {
    
    // MARK: - Properties
    var score: String = ""
    
    // MARK: - Outlets
    @IBOutlet weak var scoreLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoreLabel?.text = score
    }

    /**
     To start a new game
     
     - Returns: Void
     */
    @IBAction func playAgain(_ sender: Any) {
         performSegue(withIdentifier: "playAgain", sender: nil)
    }
    
}
