//
//  SubmissionManager.swift
//  Tourney
//
//  Created by German Espitia on 10/8/20.
//  Copyright © 2020 Will Cohen. All rights reserved.
//

import Foundation


import Foundation
import Firebase
/**
 Interface for `Submission` between database and client.
 */
struct SubmissionManager {
    
    let db = Firestore.firestore()
    private let submissionsCollectionKey = "submissions"
    private var baseQuery: Query {
        return db.collection(submissionsCollectionKey)
    }
    private var submissionsCollectionRef: CollectionReference {
        return db.collection(submissionsCollectionKey)
    }
    
    /**
     Fetch `Submission` objects belonging to a specific tournament.
     */
    func fetchSubmissionsForTournament(tournamentId: String, completion: @escaping (([Submission]?) -> Void)) {
        baseQuery.whereField("tournamentId", isEqualTo: tournamentId).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                completion(nil)
                return
            }
            completion(self.parseDocumentsToSubmissions(documents: snapshot.documents))
        }
        completion(nil)
    }
    /**
     Creates new document for submission.
     */
    public func saveNew(_ submission: Submission) {
        submissionsCollectionRef.addDocument(data: submission.dictionary)
    }
    /**
     Parse array of `QueryDocumentSnapshot` objects to array of `Submission` objects
     */
    private func parseDocumentsToSubmissions(documents: [QueryDocumentSnapshot]) -> [Submission] {
        var submissions: [Submission] = []
        for document in documents {
            if let tournament = parseDocumentToSubmission(document: document) {
                submissions.append(tournament)
            }
        }
        return submissions
    }
    /**
     Parse `QueryDocumentSnapshot` to `Submission`
     */
    private func parseDocumentToSubmission(document: QueryDocumentSnapshot) -> Submission? {
        if let submission = Submission(id: document.documentID, dictionary: document.data()) {
            return submission
        } else {
            return nil
        }
    }
}
