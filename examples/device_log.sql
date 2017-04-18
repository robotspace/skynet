/*
Navicat MySQL Data Transfer

Source Server         : 脚链
Source Server Version : 50711
Source Host           : 101.200.219.38:3306
Source Database       : liaokao_dev

Target Server Type    : MYSQL
Target Server Version : 50711
File Encoding         : 65001

Date: 2017-04-16 18:21:27
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `device_log`
-- ----------------------------
DROP TABLE IF EXISTS `device_log`;
CREATE TABLE `device_log` (
  `id` int(20) NOT NULL AUTO_INCREMENT,
  `device_id` int(10) NOT NULL DEFAULT '0',
  `device_name111111` varchar(100) DEFAULT NULL,
  `protocol_version` varchar(40) DEFAULT NULL,
  `device_imei` varchar(40) NOT NULL,
  `device_name` varchar(100) DEFAULT NULL,
  `gprs_data_flag` varchar(10) NOT NULL,
  `date` varchar(30) DEFAULT NULL,
  `time` varchar(30) DEFAULT NULL,
  `receiveTime` int(11) NOT NULL,
  `receiveTime1` datetime DEFAULT NULL,
  `gps_time` datetime DEFAULT NULL,
  `gps_flag` varchar(10) DEFAULT NULL,
  `latitude` decimal(16,14) DEFAULT NULL,
  `original_lat` decimal(16,14) DEFAULT NULL,
  `latitude_ns` varchar(4) DEFAULT NULL,
  `longitude` decimal(17,14) DEFAULT NULL,
  `original_lng` decimal(17,14) DEFAULT NULL,
  `longitude_we` varchar(4) DEFAULT NULL,
  `beidou_num` varchar(11) DEFAULT NULL,
  `gps_num` varchar(11) DEFAULT NULL,
  `glonass_num` varchar(11) DEFAULT NULL,
  `horizontal_location_accuracy` varchar(15) DEFAULT '0.00000',
  `speed` decimal(15,5) DEFAULT '0.00000',
  `course` decimal(15,5) DEFAULT '0.00000' COMMENT '航向',
  `altitude` varchar(15) DEFAULT '0.00000' COMMENT '海拔高度',
  `mileage` varchar(30) DEFAULT '0.00000' COMMENT '里程',
  `is_lbs` int(1) DEFAULT '0',
  `is_phone_position` int(1) DEFAULT NULL,
  `lbs_lat` decimal(16,14) DEFAULT NULL,
  `lbs_lng` decimal(17,14) DEFAULT NULL,
  `mcc` varchar(10) DEFAULT NULL COMMENT '移动国家码',
  `mnc` varchar(10) DEFAULT NULL,
  `lac` varchar(10) DEFAULT NULL,
  `cell_id` varchar(10) DEFAULT NULL COMMENT '小区识别码',
  `gsm_signal` int(12) DEFAULT '0' COMMENT 'GSM信号强度',
  `digital_in` int(12) DEFAULT '0',
  `digital_out` int(12) DEFAULT '0',
  `simulate1` int(12) DEFAULT '0',
  `simulate2` int(12) DEFAULT '0',
  `simulate3` int(255) DEFAULT '0',
  `temperature_sensor1` decimal(15,5) DEFAULT '0.00000',
  `temperature_sensor2` decimal(15,5) DEFAULT '0.00000',
  `rfid` int(12) DEFAULT '0',
  `external_device_status` int(10) DEFAULT '0',
  `battery` varchar(12) DEFAULT NULL,
  `alarm_events` varchar(30) DEFAULT NULL,
  `the_efficacy_and` varchar(30) DEFAULT NULL COMMENT '效验和',
  `department_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of device_log
-- ----------------------------
