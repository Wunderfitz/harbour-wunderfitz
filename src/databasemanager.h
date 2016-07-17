#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QSqlDatabase>

class DatabaseManager
{
public:
    DatabaseManager();
    bool isOpen() const;
private:
    QSqlDatabase database;

};

#endif // DATABASEMANAGER_H
