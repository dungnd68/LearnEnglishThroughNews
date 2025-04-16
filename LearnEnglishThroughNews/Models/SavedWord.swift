//
//  SaveWord.swift
//  LearnEnglishThroughNews
//
//  Created by Dũng on 15/3/25.
//

import Foundation
import FirebaseFirestore

struct SavedWord: Identifiable, Codable {
    @DocumentID var id: String?
    var tu_vung: String
    var nghia: String
    var created_at: Date?
}
