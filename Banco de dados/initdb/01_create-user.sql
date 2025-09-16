CREATE USER IF NOT EXISTS 'delphi'@'%' IDENTIFIED WITH mysql_native_password BY 'delphi123';
GRANT ALL PRIVILEGES ON pedidosdb.* TO 'delphi'@'%';
FLUSH PRIVILEGES;

