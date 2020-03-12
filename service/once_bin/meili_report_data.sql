/*****************************************************************
 *
 *                             说明
 *
*****************************************************************/
/*
基本要求：
1、创建表一律使用 CREATE TABLE IF NOT EXISTS 前缀 
2、所有表必须有主键PRIMARY KEY 
3、表名和字段名建议全部小写，下划线分割单词 
4、最好都设置默认值 
5、每个库创建表，修改表结构，修改数据都有特定的区域，请在指定区域增加操作，便于维护
6、原则上不允许直接修改已经存在的表项，需要通过modifySqlProcess过程进行修改
7、modifySqlProcess使用说明：
功能 - 修改数据库表结构
参数 - tableName 入参，数据库表名称
       columnName 入参，数据库列名
	   flag 入参，为0表示tableName不存在columnName才执行cmd；为1表示tableName存在columnName才执行cmd
	   cmd 入参，修改表结构的数据库语句
示例：CALL modifySqlProcess('InitOption', 'syncIpListToEtcd', 0, 'alter table InitOption add syncIpListToEtcd int NOT NULL default 1;');

*/



/*****************************************************************
 *
 *                           meili_report_data
 *
*****************************************************************/
create database IF NOT EXISTS  meili_report_data;
use meili_report_data;

DROP PROCEDURE IF EXISTS modifySqlProcess;

DELIMITER $$
CREATE PROCEDURE modifySqlProcess(IN tableName varchar(32),IN columnName varchar(32), IN flag INT, IN cmd varchar(4096)) 
BEGIN
	IF tableName IS NOT NULL AND columnName IS NOT NULL AND cmd IS NOT NULL THEN
		SELECT
			COUNT(*) into @isExist
		FROM
			information_schema.COLUMNS
		WHERE
			TABLE_SCHEMA = (SELECT DATABASE())
			 AND TABLE_NAME = tableName
			 AND COLUMN_NAME = columnName;
		IF @isExist=flag THEN 
			SET @SqlCmd = cmd;
            PREPARE stmt FROM @SqlCmd; 
            EXECUTE stmt;
		END IF;
    END IF;
END $$
DELIMITER ;

/*
描述：下面区域为创建表区域
修改历史：
1、zjm - 2019:08:26 - 创建整理此脚本
*/

CREATE TABLE IF NOT EXISTS  `AbnormalWorkTimeMonitor` (
  `id`          bigint(32) unsigned NOT NULL AUTO_INCREMENT,
  `user_name`   varchar(256)        NOT NULL DEFAULT '',
  `device_id`   varchar(256)        NOT NULL DEFAULT '0',
  `device_name` varchar(256)        NOT NULL DEFAULT '',
  `os_type`     varchar(256)        NOT NULL DEFAULT '',
  `device_ips`  varchar(256)        NOT NULL DEFAULT '',
  `env_ids`     varchar(256)        NOT NULL DEFAULT '',
  `status`      int(11)             NOT NULL DEFAULT 0,
  `login_time`  bigint(32)                   DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS  `BruteForceMonitor` (
  `id`           bigint(32) unsigned NOT NULL AUTO_INCREMENT,
  `env_id`       bigint(32)          NOT NULL DEFAULT 0,
  `ip`           varchar(256)        NOT NULL DEFAULT '',
  `number`       bigint(32)          NOT NULL DEFAULT 0,
  `proc_name`    varchar(256)        NOT NULL DEFAULT '',
  `monitor_time` bigint(32)          NOT NULL DEFAULT 0,
  `window_begin` bigint(32)          NOT NULL DEFAULT 0,
  `window_end`   bigint(32)          NOT NULL DEFAULT 0,
  `status`       int(11)             NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS  `EnvActiveLog` (
  `id`          bigint(32) unsigned NOT NULL AUTO_INCREMENT,
  `user_name`   varchar(256) NOT NULL,
  `device_id`   varchar(256) NOT NULL,
  `device_name` varchar(256) NOT NULL,
  `os_type`     varchar(256) NOT NULL,
  `user_ip`     varchar(256) NOT NULL,
  `env_id`      bigint(64) NOT NULL DEFAULT 0,
  `proc_name`   varchar(256) NOT NULL,
  `result`      varchar(256) NOT NULL,
  `time`        bigint(32) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `time` (`time`),
  KEY `user_name` (`user_name`(255)),
  KEY `device_id` (`device_id`(255))
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS  `FrequentActiveFailMonitor` (
  `id`           bigint(32) unsigned NOT NULL AUTO_INCREMENT,
  `env_id`       bigint(32)          NOT NULL DEFAULT 0,
  `number`       bigint(32)          NOT NULL DEFAULT 0,
  `proc_name`    varchar(256)        NOT NULL DEFAULT '',
  `monitor_time` bigint(32)          NOT NULL DEFAULT 0,
  `window_begin` bigint(32)          NOT NULL DEFAULT 0,
  `window_end`   bigint(32)          NOT NULL DEFAULT 0,
  `status`       int(11)             NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS  `LoginLog` (
  `id`          bigint(32) unsigned NOT NULL AUTO_INCREMENT,
  `user_name`   varchar(256)        NOT NULL,
  `device_id`   varchar(256)        NOT NULL,
  `device_name` varchar(256)        NOT NULL,
  `os_type`     varchar(256)        NOT NULL,
  `device_ips`  varchar(256)        NOT NULL,
  `env_ids`     varchar(256)        NOT NULL,
  `login_time`  bigint(32) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `login_time` (`login_time`),
  KEY `user_name` (`user_name`(255)),
  KEY `device_id` (`device_id`(255))
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS  `NetworkLog` (
  `id`          bigint(32) unsigned NOT NULL AUTO_INCREMENT,
  `user_name`   varchar(256)        NOT NULL,
  `device_id`   varchar(256)        NOT NULL,
  `device_name` varchar(256)        NOT NULL,
  `local_ip`    varchar(256)        NOT NULL,
  `local_port`  int(11)             NOT NULL,
  `remote_ip`   varchar(256)        NOT NULL,
  `remote_port` int(11)             NOT NULL,
  `protocol`    int(11)             NOT NULL,
  `direction`   varchar(256)        NOT NULL,
  `env_id`      bigint(64)          NOT NULL DEFAULT 0,
  `proc_name`   varchar(256)        NOT NULL,
  `permission`  varchar(256)        NOT NULL,
  `time`        bigint(32) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `time` (`time`),
  KEY `user_name` (`user_name`(255)),
  KEY `device_id` (`device_id`(255))
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS  `OutgoTaskResult` (
  `id`           bigint(32) unsigned NOT NULL AUTO_INCREMENT,
  `user_name`    varchar(128)        NOT NULL DEFAULT '',
  `policy_id`    bigint(32) unsigned NOT NULL DEFAULT 0,
  `domain_id`    bigint(32) unsigned NOT NULL DEFAULT 0,
  `outgo_type`   varchar(50)         NOT NULL DEFAULT '',
  `filename`     varchar(1024)       NOT NULL DEFAULT '',
  `fingerprint`  varchar(1024)       NOT NULL DEFAULT '',
  `outgo_result` varchar(64)         NOT NULL DEFAULT '',
  `reason`       varchar(1024)       NOT NULL DEFAULT '',
  `time`         bigint(32)          NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `policy_id` (`policy_id`),
  KEY `filename` (`filename`(255)),
  KEY `fingerprint` (`fingerprint`(255)),
  KEY `time` (`time`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS  `ScanIpMonitor` (
  `id`           bigint(32) unsigned NOT NULL AUTO_INCREMENT,
  `env_id`       bigint(32)          NOT NULL DEFAULT 0,
  `proc_name`    varchar(256)        NOT NULL DEFAULT '',
  `number`       bigint(32)          NOT NULL DEFAULT 0,
  `ips`          varchar(2000)       NOT NULL DEFAULT '',
  `monitor_time` bigint(32)          NOT NULL DEFAULT 0,
  `window_begin` bigint(32)          NOT NULL DEFAULT 0,
  `window_end`   bigint(32)          NOT NULL DEFAULT 0,
  `status`       int(11)             NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS  `SoftwarePb` (
  `id`            bigint(32) unsigned NOT NULL AUTO_INCREMENT,
  `software_name` varchar(256)        NOT NULL DEFAULT '',
  `publisher`     varchar(256)        NOT NULL DEFAULT '0',
  `binary_name`   varchar(256)        NOT NULL DEFAULT '',
  `product_name`  varchar(256)        NOT NULL DEFAULT '',
  `company_name`  varchar(256)        NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS  `access_server_statistics` (
  `id`               bigint(32) unsigned NOT NULL AUTO_INCREMENT,
  `project`          varchar(256)        NOT NULL DEFAULT '',
  `mtable`           varchar(256)        NOT NULL DEFAULT '',
  `topic`            varchar(256)        NOT NULL DEFAULT '',
  `dest`             varchar(128)        NOT NULL DEFAULT '',
  `access_server_ip` varchar(20)         NOT NULL DEFAULT '',
  `report_ip`        varchar(20)         NOT NULL DEFAULT '',
  `report_time`      bigint(32)          NOT NULL DEFAULT 0,
  `status`           varchar(128)        NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS  `echar_active` (
  `id`           bigint(32) unsigned NOT NULL AUTO_INCREMENT,
  `domain_id`    bigint(32) unsigned NOT NULL,
  `number`       bigint(32) unsigned NOT NULL DEFAULT 0,
  `window_begin` bigint(32)          NOT NULL,
  `window_end`   bigint(32)          NOT NULL,
  `time`         bigint(32)          NOT NULL,
  PRIMARY KEY (`id`),
  KEY `window_begin` (`window_begin`),
  KEY `window_end` (`window_end`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `echar_network` (
  `id`           bigint(32) unsigned NOT NULL AUTO_INCREMENT,
  `domain_id`    bigint(32) unsigned NOT NULL,
  `number`       bigint(32) unsigned NOT NULL DEFAULT 0,
  `window_begin` bigint(32)          NOT NULL,
  `window_end`   bigint(32)          NOT NULL,
  `time`         bigint(32)          NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `window_begin` (`window_begin`),
  KEY `window_end` (`window_end`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS  `echar_process` (
  `id`           bigint(32) unsigned NOT NULL AUTO_INCREMENT,
  `domain_id`    bigint(32) unsigned NOT NULL,
  `number`       bigint(32) unsigned NOT NULL DEFAULT 0,
  `window_begin` bigint(32)          NOT NULL,
  `window_end`   bigint(32)          NOT NULL,
  `time`         bigint(32)          NOT NULL,
  PRIMARY KEY (`id`),
  KEY `window_begin` (`window_begin`),
  KEY `window_end` (`window_end`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS  `flume_statistics` (
  `id`                       bigint(32) unsigned NOT NULL AUTO_INCREMENT,
  `flume_ip`                 varchar(128)        NOT NULL DEFAULT '',
  `channel_capacity`         bigint(32)          NOT NULL DEFAULT 0,
  `channel_fill_percentage`  float               NOT NULL DEFAULT 0,
  `channel_size`             bigint(32)          NOT NULL DEFAULT 0,
  `event_take_success_count` bigint(32)          NOT NULL DEFAULT 0,
  `event_put_success_count`  bigint(32)          NOT NULL DEFAULT 0,
  `event_received_count`     bigint(32)          NOT NULL DEFAULT 0,
  `event_accepted_count`     bigint(32)          NOT NULL DEFAULT 0,
  `report_time`              bigint(32)          NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS  `operate_log` (
  `id`       bigint(32) unsigned NOT NULL AUTO_INCREMENT,
  `type`     text                NOT NULL,
  `time`     bigint(20)          NOT NULL,
  `operater` text                NOT NULL,
  `content`  text                NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS  `user_device_statistics` (
  `id`            bigint(32) unsigned NOT NULL AUTO_INCREMENT,
  `time`          bigint(20)          NOT NULL,
  `domainId`      int(11)             NOT NULL,
  `userOnline`    int(11)             NOT NULL,
  `deviceOnline`  int(11)             NOT NULL,
  `userTotal`     int(11)             NOT NULL,
  `deviceTotal`   int(11)             NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS  `warn_log` (
  `id`        bigint(32) unsigned NOT NULL AUTO_INCREMENT,
  `log_type`  bigint(32)          NOT NULL,
  `log_level` bigint(32)          NOT NULL,
  `operater`  text                NOT NULL,
  `warn_ids`  text                NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `ClipboardOutgo` (
  `id`                  bigint(32) unsigned     NOT NULL    AUTO_INCREMENT,
  `device_outgo_sn`     varchar(256)            NOT NULL,
  `user_name`           varchar(256)            NOT NULL,
  `device_id`           varchar(256)            NOT NULL,
  `src_domain_id`       BIGINT(32)              NOT NULL,
  `src_process_name`    varchar(256)            NOT NULL,
  `dest_domain_id`      BIGINT(32)              NOT NULL,
  `dest_process_name`   varchar(256)            NOT NULL,
  `content`             mediumtext              NOT NULL,
  `commit_timestamp`    BIGINT(32) unsigned     NOT NULL    DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `device_outgo_sn_idx` (`device_outgo_sn`(255)),
  KEY `user_name_idx` (`user_name`(255)),
  KEY `device_id_idx` (`device_id`(255))
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `update_task_log` (
  `id`          BIGINT(32) UNSIGNED     NOT NULL    AUTO_INCREMENT,
  `task_name`   VARCHAR(256)            NOT NULL    DEFAULT '',
  `os`          VARCHAR(128)            NOT NULL    DEFAULT '',
  `arch`        VARCHAR(128)            NOT NULL    DEFAULT '',
  `version`     VARCHAR(128)            NOT NULL    DEFAULT '',
  `start_time`  TIMESTAMP               NOT NULL    DEFAULT CURRENT_TIMESTAMP,
  `expire_time` TIMESTAMP               NOT NULL    DEFAULT CURRENT_TIMESTAMP,
  `end_time`    TIMESTAMP               NOT NULL    DEFAULT CURRENT_TIMESTAMP,
  `status`      TINYINT(1)              NOT NULL    DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `task_name` (`task_name`(255))
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `update_unit_log` (
  `id`              BIGINT(32) UNSIGNED     NOT NULL    AUTO_INCREMENT,
  `task_name`       VARCHAR(256)            NOT NULL    DEFAULT '',
  `user_name`       VARCHAR(256)            NOT NULL    DEFAULT '',
  `SN`              VARCHAR(256)            NOT NULL    DEFAULT '',
  `current_version` VARCHAR(128)            NOT NULL    DEFAULT '',
  `target_version`  VARCHAR(128)            NOT NULL    DEFAULT '',
  `status`          TINYINT(1)              NOT NULL    DEFAULT 0,
  `detail`          TEXT,
  PRIMARY KEY (`id`),
  UNIQUE KEY `task_name` (`task_name`(255),`user_name`(255),`SN`(255))
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

/*
描述：下面区域为修改表结构区域
修改历史：
1、zjm - 2019:08:26 - 创建整理此脚本
*/






/*
描述：下面区域为修改数据区域
修改历史：
1、zjm - 2019:08:26 - 创建整理此脚本
2、zjm - 2019:08:26 - 修改strategy_device_relation表所有设备、人、程序的ID值
*/





/* 注意：所有操作都需要在此语句之前 */
DROP PROCEDURE IF EXISTS modifySqlProcess;


