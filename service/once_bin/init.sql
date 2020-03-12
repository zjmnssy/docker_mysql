CREATE DATABASE IF NOT EXISTS test1 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE test1;
CREATE TABLE IF NOT EXISTS example (
    id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    member_id     INT UNSIGNED    NOT NULL default 0                 COMMENT 'user id',
    type          VARCHAR(10)     NOT NULL DEFAULT 'UNKNOWN'         COMMENT 'type inside license',
    user          VARCHAR(64)     NOT NULL DEFAULT ''                COMMENT 'user name',
    device_limit  BIGINT UNSIGNED NOT NULL DEFAULT 1                 COMMENT 'device limit inside license',
    assigned_time INT UNSIGNED    NOT NULL DEFAULT 0                 COMMENT 'this license assigned time',
    insert_time   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'insert time',
    expire_day    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'expire day inside license',
    uuid          VARCHAR(255)    NOT NULL DEFAULT ''                COMMENT 'uuid of license',
    license       VARCHAR(1024)   NOT NULL DEFAULT ''                COMMENT 'full license string',
    PRIMARY KEY (id),
    KEY `license` (license)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

insert into example set id=0;
