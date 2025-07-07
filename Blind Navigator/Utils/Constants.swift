//
//  Constants.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 5/29/25.
//

import Foundation

enum Constants {
    static let materials = ["concrete", "subway grate", "brick", "dirt", "manhole", "tactile", "cellar door"]
    static let apiURL = URL(string:"https://sidewalkapi-278558760994.us-east4.run.app/process_audio")
    static let localURL = URL(string:"http://127.0.0.1:5000/process_audio")
    static let audioConfig = (sampleRate: 44100, duration: 2.0)
    static let numSegments = 2;
    static let globalFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss-SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
}
