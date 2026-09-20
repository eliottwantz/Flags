//  Database.swift
//  Flags
//
//  Created by Eliott Wantz on 20/09/2026.
//  SPDX-License-Identifier: MIT

import Foundation
import SQLiteData

extension DependencyValues {
  mutating func bootstrapDatabase() throws {
    let database = try SQLiteData.defaultDatabase()
    var migrator = DatabaseMigrator()
    #if DEBUG
      migrator.eraseDatabaseOnSchemaChange = true
    #endif
    migrator.registerMigration("Create gameResults") { db in
      try #sql(
        """
        CREATE TABLE "gameResults" (
          "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
          "playedAt" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT CURRENT_TIMESTAMP,
          "score" INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
          "rounds" INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
          "durationSeconds" INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 60
        ) STRICT
        """
      )
      .execute(db)
      try #sql(
        """
        CREATE INDEX "index_gameResults_on_playedAt" ON "gameResults"("playedAt")
        """
      )
      .execute(db)
    }
    try migrator.migrate(database)
    defaultDatabase = database
    defaultSyncEngine = try SyncEngine(for: database, tables: GameResult.self)
  }
}
