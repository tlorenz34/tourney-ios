//
//  Onboarding.swift
//  Tourney
//
//  Created by Thaddeus Lorenz on 4/4/21.
//  Copyright © 2021 Will Cohen. All rights reserved.
//

import Foundation

let tabs = [
    Page(image: "featuredcompetitions_example", title: "Featured Competitions", text: "Watch or join competitions hosted by real brands"),
    
    Page(image: "competitions_example", title: "Join Competitions", text: "Join by recording and uploading an 8-second video"),

    Page(image: "profile_example", title: "Create a Profile", text: "Create a profile to track your progress!"),
    
    Page(image: "submissions_example", title: "Competition Rules", text: "Choose any competition. Watch the challenge video and record your best attempt!"),
    
    Page(image: "recordvideo_example", title: "Competition Rules Continued", text: "Get as many votes as you can after 4 days!"),
    
    Page(image: "leaderboard_example", title: "Leaderboard", text: "Check the leaderboard of any competition."),

    
    ]

struct Page {
    
    let image: String
    let title: String
    let text: String
}
