#include <QDebug>
#include "databasemanager.h"

DatabaseManager::DatabaseManager()
{
    database = QSqlDatabase::addDatabase("QSQLITE");
    database.setDatabaseName("/usr/share/harbour-wunderfitz/db/heinzelliste.db");

    if (!database.open())
    {
       qDebug() << "Error: connection with database failed";
    }
    else
    {
       qDebug() << "Database: connection OK";
    }
}

bool DatabaseManager::isOpen() const
{
    return database.isOpen();
}
