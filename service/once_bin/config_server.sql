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
 *                           config_server
 *
*****************************************************************/
create database if not exists config_server;
use config_server;

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

CREATE TABLE IF NOT EXISTS `member` (
  `id`         bigint unsigned NOT NULL AUTO_INCREMENT,
  `accunt`     varchar(128)    NOT NULL,
  `name`       varchar(128)    NOT NULL DEFAULT '',
  `passwd`     varchar(255)    NOT NULL DEFAULT '',
  `salt1`      varchar(255)    NOT NULL DEFAULT '',
  `salt2`      varchar(255)    NOT NULL DEFAULT '',
  `saltHash2`  varchar(255)    NOT NULL DEFAULT '',
  `role`       varchar(128)    NOT NULL DEFAULT '',
  `department` varchar(255)    NOT NULL DEFAULT '',
  `phone`      varchar(64)     NOT NULL DEFAULT '',
  `email`      varchar(255)    NOT NULL DEFAULT '',
  `registTime` bigint unsigned NOT NULL DEFAULT 0,
  `surname`    varchar(128)    NOT NULL DEFAULT '',
  `givename`   varchar(255)    NOT NULL DEFAULT '',
  `orignal_pw` varchar(255)    NOT NULL default '',
  `cm_pw_time` bigint unsigned NOT NULL default 0,
  `pw_state`   int NOT NULL default 2,
  `is_delete`  int(16) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `accunt` (`accunt`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `domain` (
  `id`          bigint unsigned NOT NULL AUTO_INCREMENT,
  `shortName`   varchar(32)     NOT NULL,
  `name`        varchar(128)    NOT NULL,
  `safe_level`  varchar(32)     NOT NULL,
  `colour`      varchar(32)     NOT NULL,
  `description` varchar(256)    NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `shortName` (`shortName`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `device` (
  `id`          bigint unsigned NOT NULL AUTO_INCREMENT,
  `name`        varchar(255)    NOT NULL,
  `SN`          varchar(128)    NOT NULL,
  `hostName`    varchar(255)    NOT NULL,
  `OS`          varchar(255)    NOT NULL,
  `arch`        varchar(128)    NOT NULL DEFAULT '',
  `version`     varchar(128)    NOT NULL DEFAULT '',
  `lastLogin`   bigint unsigned NOT NULL,
  `description` varchar(255)    NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `SN` (`SN`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `strategy` (
  `id`            bigint unsigned NOT NULL AUTO_INCREMENT,
  `strategyType`  varchar(32)     NOT NULL,
  `strategyLevel` bigint unsigned NOT NULL DEFAULT 0,
  `applyId`       bigint unsigned NOT NULL,
  `createrId`     bigint unsigned NOT NULL,
  `expiryStart`   bigint unsigned NOT NULL,
  `expiryEnd`     bigint unsigned NOT NULL,
  `effectStart`   varchar(64)     NOT NULL,
  `effectEnd`     varchar(64)     NOT NULL,
  `rate`          varchar(64)     NOT NULL,
  `applyTime`     bigint unsigned NOT NULL,
  `isActive`      tinyint(1)      NOT NULL,
  `state`         varchar(64)     NOT NULL,
  `notifyState`   varchar(64)     NOT NULL,
  `position`      text            NOT NULL,
  `reason`        text            NOT NULL,
  `remarks`       text            NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `strategyLevel` (`strategyLevel`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `program` (
  `id`             bigint unsigned NOT NULL AUTO_INCREMENT,
  `name`           varchar(128)    NOT NULL,
  `binary_name`    text            NOT NULL,
  `product_name`   text            NOT NULL,
  `company_name`   text            NOT NULL,
  `binary_sha1`    varchar(512)    NOT NULL DEFAULT '',
  `original_name`  varchar(512)    NOT NULL DEFAULT '',
  `signature_name` varchar(512)    NOT NULL DEFAULT '',
  `type`           text            NOT NULL,
  `state`          text            NOT NULL,
  `notifyState`    text            NOT NULL,
  `applyTime`      bigint unsigned NOT NULL,
  `createrId`      bigint unsigned NOT NULL,
  `reason`         text            NOT NULL,
  `remarks`        text            NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `ip_list` (
  `id`        bigint unsigned NOT NULL AUTO_INCREMENT,
  `domain_id` bigint unsigned NOT NULL,
  `type`      text            NOT NULL,
  `value`     text            NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `default_strategy` (
  `id`           bigint unsigned NOT NULL AUTO_INCREMENT,
  `domain_id`    bigint unsigned NOT NULL,
  `strategyType` text            NOT NULL,
  `createTime`   bigint unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `domain_id` (`domain_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `env_info` (
  `id`       bigint unsigned NOT NULL AUTO_INCREMENT,
  `userId`   bigint unsigned NOT NULL,
  `deviceId` bigint unsigned NOT NULL,
  `domainId` bigint unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `manager_domain_relation` (
  `id`        bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id`   bigint unsigned NOT NULL,
  `domain_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `domain_member_relation` (
  `id`          bigint unsigned NOT NULL AUTO_INCREMENT,
  `member_id`   bigint unsigned NOT NULL,
  `domain_id`   bigint unsigned NOT NULL,
  `state`       text            NOT NULL,
  `notifyState` text            NOT NULL,
  `applyTime`   bigint unsigned NOT NULL,
  `reason`      text            NOT NULL,
  `remarks`     text            NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `strategy_process_relation` (
  `id`          bigint unsigned NOT NULL AUTO_INCREMENT,
  `strategy_id` bigint unsigned NOT NULL,
  `process_id`  bigint unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `strategy_domain_relation` (
  `id`          bigint unsigned NOT NULL AUTO_INCREMENT,
  `strategy_id` bigint unsigned NOT NULL,
  `domain_id`   bigint unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `strategy_member_relation` (
  `id`          bigint unsigned NOT NULL AUTO_INCREMENT,
  `strategy_id` bigint unsigned NOT NULL,
  `member_id`   bigint unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `strategy_device_relation` (
  `id`          bigint unsigned NOT NULL AUTO_INCREMENT,
  `strategy_id` bigint unsigned NOT NULL,
  `device_id`   bigint unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `device_member_relation` (
  `id`        bigint unsigned NOT NULL AUTO_INCREMENT,
  `device_id` bigint unsigned NOT NULL,
  `member_id` bigint unsigned NOT NULL,
  `lastTime`  bigint unsigned NOT NULL,
  `state`     text            NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `domain_device_relation` (
  `id`        bigint unsigned NOT NULL AUTO_INCREMENT,
  `device_id` bigint unsigned NOT NULL,
  `domain_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `route_dns` (
  `id`          bigint unsigned NOT NULL AUTO_INCREMENT,
  `type`        varchar(128)    NOT NULL,
  `ip_dns`      text            NOT NULL,
  `gateway`     varchar(128)    NOT NULL DEFAULT '',
  `create_time` bigint unsigned NOT NULL DEFAULT 0,
  `description` varchar(256)    NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `apply_receipt` (  
  `id`            bigint unsigned NOT NULL AUTO_INCREMENT,  
  `receipt_type`  varchar(128)    NOT NULL,  
  `receipt_id`    bigint unsigned NOT NULL,  
  `applyer_name`  varchar(128)    NOT NULL,  
  `applyer_id`    bigint unsigned NOT NULL,  
  `cm_time`       bigint unsigned NOT NULL,  
  `approver_name` varchar(128)    NOT NULL,  
  `approver_id`   bigint unsigned NOT NULL,  
  `status`        varchar(64)     NOT NULL,  
  `reason`        varchar(512)    NOT NULL,  
  `remarks`       varchar(512)    NOT NULL DEFAULT '',  
  PRIMARY KEY (`id`), 
  KEY `receipt_type` (`receipt_type`),  
  KEY `receipt_id` (`receipt_id`),  
  KEY `applyer_name` (`applyer_name`),  
  KEY `approver_name` (`approver_name`),  
  KEY `status` (`status`)  
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;  

CREATE TABLE IF NOT EXISTS `outgo_policy` (  
  `id`           bigint unsigned NOT NULL AUTO_INCREMENT,  
  `type`         varchar(255)    NOT NULL, 
  `sdomain_name` varchar(255)    NOT NULL, 
  `sdomain_id`   bigint unsigned NOT NULL, 
  `deviceSN`     varchar(255)    NOT NULL, 
  `time_begin`   bigint unsigned NOT NULL,  
  `time_end`     bigint unsigned NOT NULL,  
  `cm_time`      bigint unsigned NOT NULL,  
  `etcd_flag`    bigint unsigned NOT NULL DEFAULT 0,  
  PRIMARY KEY (`id`),  
  KEY `sdomain_id` (`sdomain_id`),  
  KEY `time_begin` (`time_begin`),  
  KEY `time_end` (`time_end`),
  KEY `etcd_flag` (`etcd_flag`)    
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;  

CREATE TABLE IF NOT EXISTS `outgo_file` (  
  `id`             bigint unsigned NOT NULL AUTO_INCREMENT,  
  `policy_id`      bigint unsigned NOT NULL,  
  `path`           varchar(255)    NOT NULL,  
  `fingerprint`    varchar(255)    NOT NULL,  
  `run_result`     varchar(64)     NOT NULL DEFAULT 'ready',  
  `run_info`       varchar(255)    NOT NULL DEFAULT '',  
  `volume_letter`  varchar(64)     NOT NULL DEFAULT '',
  PRIMARY KEY (`id`), 
  KEY `policy_id` (`policy_id`),  
  KEY `path` (`path`)  
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;  

CREATE TABLE IF NOT EXISTS `clipboard_data` (  
  `id`        bigint unsigned NOT NULL AUTO_INCREMENT,  
  `user_name` varchar(128)    NOT NULL, 
  `time`      bigint unsigned NOT NULL, 
  `content`   varchar(8192)   NOT NULL, 
  `status`    varchar(64)     NOT NULL, 
  PRIMARY KEY (`id`),  
  KEY `user_name` (`user_name`),  
  KEY `time` (`time`),
  KEY `status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;  

CREATE TABLE IF NOT EXISTS `default_license_config` (  
  `id`           bigint unsigned NOT NULL AUTO_INCREMENT,  
  `device_limit` bigint unsigned NOT NULL, 
  `insert_time`  bigint unsigned NOT NULL, 
  `expire_day`   bigint unsigned NOT NULL, 
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;  

CREATE TABLE IF NOT EXISTS license (
    id            bigint unsigned NOT NULL AUTO_INCREMENT,
    member_id     bigint unsigned not null default 0,
    type          varchar(10)     NOT NULL DEFAULT 'UNKNOWN'         COMMENT 'type inside license',
    user          varchar(64)     NOT NULL DEFAULT ''                COMMENT 'user name',
    device_limit  bigint unsigned NOT NULL DEFAULT 1                 COMMENT 'device limit inside license',
    assigned_time bigint unsigned NOT NULL DEFAULT 0                 COMMENT 'this license assigned time',
    insert_time   timestamp       NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'insert time',
    expire_day    timestamp       NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'expire day inside license',
    uuid          varchar(255)    NOT NULL DEFAULT ''                COMMENT 'uuid of license',
    license       varchar(1024)   NOT NULL DEFAULT ''                COMMENT 'full license string',
    PRIMARY KEY (id),
	UNIQUE KEY `uuid` (uuid)
) ENGINE=InnoDB AUTO_INCREMENT=1 default charset=utf8;

CREATE TABLE IF NOT EXISTS license_usage (
    id           bigint unsigned NOT NULL AUTO_INCREMENT,
    member_id    bigint unsigned NOT NULL DEFAULT 0                 COMMENT 'user name',
    license_uuid varchar(255)    NOT NULL default ''                COMMENT 'uuid in license',
    device_uuid  varchar(255)    NOT NULL DEFAULT ''                COMMENT 'device id',
    update_time  timestamp       NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'insert time',
    PRIMARY KEY (id),
	UNIQUE KEY `unique_index` (`member_id`, `license_uuid`, `device_uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 default charset=utf8;

CREATE TABLE IF NOT EXISTS `dacs` (
    `id`       bigint unsigned NOT NULL AUTO_INCREMENT,
    `internet` bigint unsigned NOT NULL DEFAULT 0,
    `intranet` bigint unsigned NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS UserFeatureSwitchValue (
	`id`             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
	`user_name`      VARCHAR(128)    NOT NULL ,
	`switchAll`      INT             NOT NULL DEFAULT 1,
	`FileHook`       INT             NOT NULL DEFAULT 0,
	`ObjHook`        INT             NOT NULL DEFAULT  1,
	`WindowHook`     INT             NOT NULL DEFAULT  1,
	`PrinterHook`    INT             NOT NULL DEFAULT  1,
	`DataCommonHook` INT             NOT NULL DEFAULT 0,
	`DNSHook`        INT             NOT NULL DEFAULT  1,
	`ScreenshotHold` INT             NOT NULL DEFAULT  1,
	PRIMARY KEY (`id`),
	UNIQUE KEY `user_name` (`user_name`)
)ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS InitOption (
	`id`                   BIGINT UNSIGNED NOT NULL DEFAULT 1,
	`NeedSyncSwitchValue`  INT             NOT NULL DEFAULT 1,
	PRIMARY KEY (`id`)
) ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS dns_proxy (
	`id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
	`domain_id`   BIGINT UNSIGNED NOT NULL DEFAULT 0,
	`master`      varchar(64)     NOT NULL DEFAULT '',
	`slave`       varchar(64)     NOT NULL DEFAULT '',
	`cm_time`     BIGINT UNSIGNED NOT NULL DEFAULT 0,
	`description` varchar(256)    NOT NULL DEFAULT '',
	PRIMARY KEY (`id`),
	UNIQUE KEY `domain_id` (`domain_id`)
)ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS login_method (
	`id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  	`name`         varchar(64)     NOT NULL,
	`display_name` varchar(64)     NOT NULL DEFAULT '',
 	`is_active`    tinyint(1)      NOT NULL,
    `priority`     BIGINT          NOT NULL DEFAULT 0,
	PRIMARY KEY (`id`),
	UNIQUE KEY `name` (`name`)
)ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS login_method_desc (
	`display_name`   varchar(64) NOT NULL,
	`internal_name`  varchar(64) NOT NULL,
	PRIMARY KEY (`display_name`),
	UNIQUE KEY `internal_name`(`internal_name`)
)ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS label (
    id               BIGINT UNSIGNED     NOT NULL AUTO_INCREMENT,
    display_name     VARCHAR(128)        NOT NULL DEFAULT ''        COMMENT 'display name',
    group_id         BIGINT UNSIGNED     NOT NULL DEFAULT 0         COMMENT 'belong to the group',
    description      VARCHAR(1024)       NOT NULL DEFAULT ''        COMMENT 'description of the label',
    bound            VARCHAR(64)         NOT NULL DEFAULT ''        COMMENT 'range of the label',
    PRIMARY KEY (id),
    UNIQUE  KEY `display_name` (display_name)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS user_label_relation (
    id               BIGINT UNSIGNED     NOT NULL AUTO_INCREMENT,
    user_id          BIGINT UNSIGNED     NOT NULL DEFAULT 0         COMMENT 'user id',
    label_id         BIGINT UNSIGNED     NOT NULL DEFAULT 0         COMMENT 'label id',
    creater_id       VARCHAR(255)        NOT NULL DEFAULT ''        COMMENT 'who create this relation',
    cm_time          BIGINT UNSIGNED     NOT NULL DEFAULT 0         COMMENT 'the time of this relation',
    PRIMARY KEY (id),
    KEY `user_id` (user_id),
    KEY `label_id` (label_id)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS manage_range (
    id               BIGINT UNSIGNED     NOT NULL AUTO_INCREMENT,
    role_id          BIGINT UNSIGNED     NOT NULL DEFAULT 0         COMMENT 'role id',
    label_id         BIGINT UNSIGNED     NOT NULL DEFAULT 0         COMMENT 'label id',
    PRIMARY KEY (id),
    KEY `role_id` (role_id),
    KEY `label_id` (label_id)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS api_permission (
    id                 BIGINT UNSIGNED     NOT NULL AUTO_INCREMENT,
    url                VARCHAR(255)        NOT NULL DEFAULT ''        COMMENT 'api url',
    role               VARCHAR(64)         NOT NULL DEFAULT ''        COMMENT 'user role',
    permission         VARCHAR(64)         NOT NULL DEFAULT ''        COMMENT 'permission',
    cm_time            BIGINT UNSIGNED     NOT NULL DEFAULT 0         COMMENT 'create or modify time',
    PRIMARY KEY (id),
    KEY `url` (url)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS inode (
    id        BIGINT(20) UNSIGNED   NOT NULL AUTO_INCREMENT,
    task_id   BIGINT(20) UNSIGNED   NOT NULL DEFAULT 0,
    file_key  VARCHAR(128)          NOT NULL DEFAULT '' COMMENT 'unique key for inode, use md5 checksum',
    type      TINYINT(3) UNSIGNED   NOT NULL DEFAULT 0  COMMENT '0 regular file, 1 direction',
    stat      TINYINT(3) UNSIGNED   NOT NULL DEFAULT 0  COMMENT '0: deleted, 1: exist, 2:read lock, 3: write lock',
    size      BIGINT(20) UNSIGNED   NOT NULL DEFAULT 0,
    ctime     BIGINT(20)            NOT NULL DEFAULT 0  COMMENT 'create time',
    dtime     BIGINT(20)            NOT NULL DEFAULT 0  comment 'deletion time',
    attr      BIGINT(20) UNSIGNED   NOT NULL DEFAULT 0  COMMENT 'like linux: 0777 means all permission',
    path      TEXT                  NOT NULL            COMMENT 'path in machine(position)',
    position  TEXT                  NOT NULL            COMMENT 'ip:port of file',
    owner_id  BIGINT(20) UNSIGNED   NOT NULL DEFAULT 0  COMMENT 'owner id of file',
    domain_id BIGINT(20) UNSIGNED   NOT NULL DEFAULT 0  COMMENT 'file source domain id',
    name      TEXT                  NOT NULL            COMMENT 'file name shared by owner_id in domain_id',
    PRIMARY KEY (id),
    UNIQUE (task_id)
) ENGINE = INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS shared_file (
    id                BIGINT(20) UNSIGNED   NOT NULL AUTO_INCREMENT,
    shared_member_id  BIGINT(20) UNSIGNED   COMMENT 'user id shared to',
    task_id           BIGINT(20) UNSIGNED   NOT NULL,
    file_key          VARCHAR(128)          NOT NULL COMMENT 'file md5',
    owner_id          BIGINT(20) UNSIGNED   COMMENT 'owner id of file',
    domain_id         BIGINT(20) UNSIGNED   NOT NULL DEFAULT 0 COMMENT 'file source domain id',
    lowest_level      TINYINT(3) UNSIGNED   NOT NULL DEFAULT 0 COMMENT 'lowest download domain level',
    insert_time       BIGINT(20)            NOT NULL DEFAULT 0,
    expire_time       BIGINT(20)            NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE (shared_member_id, task_id)
) ENGINE = INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `dcube_packages` (
  `id`          BIGINT(10) UNSIGNED     NOT NULL    AUTO_INCREMENT,
  `uploader`    VARCHAR(256)            NOT NULL    DEFAULT '',
  `upload_time` TIMESTAMP               NOT NULL    DEFAULT CURRENT_TIMESTAMP,
  `os`          VARCHAR(128)            NOT NULL    DEFAULT '',
  `arch`        VARCHAR(128)            NOT NULL    DEFAULT '',
  `version`     VARCHAR(128)            NOT NULL    DEFAULT '',
  `md5`         VARCHAR(256)            NOT NULL    DEFAULT '',
  `size`        BIGINT(20)              NOT NULL    DEFAULT 0,
  `url`         TEXT                    NOT NULL,
  `detail`      TEXT,
  PRIMARY       KEY (`id`),
  UNIQUE        KEY `os` (`os`,`arch`,`version`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

/*
描述：下面区域为修改表结构区域
修改历史：
1、zjm - 2019:08:26 - 创建整理此脚本
*/

CALL modifySqlProcess('member', 'orignal_pw', 0, 'alter table member add orignal_pw varchar(256) not Null default \'\';');
CALL modifySqlProcess('member', 'cm_pw_time', 0, 'alter table member add cm_pw_time bigint unsigned not Null default 0;');
CALL modifySqlProcess('member', 'pw_state', 0, 'alter table member add pw_state int not Null default 3;');

CALL modifySqlProcess('InitOption', 'syncIpListToEtcd', 0, 'alter table InitOption add syncIpListToEtcd int NOT NULL default 1;');

CALL modifySqlProcess('ip_list', 'policyLevel', 0, 'alter table ip_list add policyLevel bigint  default 10001;');
CALL modifySqlProcess('ip_list', 'policyType', 0, 'alter table ip_list ADD policyType  VARCHAR(64) NOT NULL DEFAULT \'allow\';');
CALL modifySqlProcess('ip_list', 'isActive', 0, 'alter table ip_list add isActive tinyint NOT NULL default 1;');
CALL modifySqlProcess('ip_list', 'needSyncToEtcd', 0, 'alter table ip_list add needSyncToEtcd tinyint NOT NULL default 1;');

CALL modifySqlProcess('manager_domain_relation', 'role_type', 0, 'alter table manager_domain_relation add role_type VARCHAR(128) not Null default \'policyAdmin\';');
CALL modifySqlProcess('manager_domain_relation', 'consigner_id', 0, 'alter table manager_domain_relation add consigner_id BIGINT UNSIGNED not Null default 0;');
CALL modifySqlProcess('manager_domain_relation', 'cm_time', 0, 'alter table manager_domain_relation add cm_time BIGINT UNSIGNED not Null default 0;');
CALL modifySqlProcess('manager_domain_relation', 'user_id', 0, 'alter table manager_domain_relation add index user_id (user_id);');
CALL modifySqlProcess('manager_domain_relation', 'domain_id', 0, 'alter table manager_domain_relation add index domain_id (domain_id);');
CALL modifySqlProcess('manager_domain_relation', 'consigner_id', 0, 'alter table manager_domain_relation add index consigner_id (consigner_id);');

CALL modifySqlProcess('device', 'arch', 0, 'alter table device add column arch varchar(128) not null default \'\' after OS;');
CALL modifySqlProcess('device', 'version', 0, 'alter table device add column version varchar(128) not null default \'\' after arch;');

CALL modifySqlProcess('device', 'allowUninstall', 0, 'alter table device add column allowUninstall bool not null default false;');

/*
描述：下面区域为修改数据区域
修改历史：
1、zjm - 2019:08:26 - 创建整理此脚本
2、zjm - 2019:08:26 - 修改strategy_device_relation表所有设备、人、程序的ID值
*/
insert into login_method(id,name,is_active,priority,display_name) select 1,'COMMON',true,1,'DACS密码登录' from DUAL where not exists (select name from login_method where display_name='DACS密码登录');

insert into login_method_desc(display_name,internal_name) select 'DACS密码登录','COMMON' from DUAL where not exists(select display_name from login_method_desc where internal_name='COMMON' and display_name='DACS密码登录');
insert into login_method_desc(display_name,internal_name) select 'AD域登录','ADAUTH' from DUAL where not exists(select display_name from login_method_desc where internal_name='ADAUTH' and display_name='AD域登录');
insert into login_method_desc(display_name,internal_name) select 'SSO登录','YOUZUSSO' from DUAL where not exists(select display_name from login_method_desc where internal_name='YOUZUSSO' and display_name='SSO登录');
insert into login_method_desc(display_name,internal_name) select 'LDAP','LDAP' from DUAL where not exists(select display_name from login_method_desc where internal_name='LDAP' and display_name='LDAP');

REPLACE INTO InitOption(id,NeedSyncSwitchValue,syncIpListToEtcd) values (1,1,1);

update strategy_device_relation set device_id=2147483647 where device_id=0;
update strategy_member_relation set member_id=2147483647 where member_id=0;
update strategy_process_relation set process_id=2147483647 where process_id=0;





/* 注意：所有操作都需要在此语句之前 */
DROP PROCEDURE IF EXISTS modifySqlProcess;


