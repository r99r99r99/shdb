## call getLastBeachDegreeByStation(10004);
drop procedure if exists getLastBeachDegreeByStation;
create procedure getLastBeachDegreeByStation(
	in v_stationId int
)
leave_name:
begin
	DECLARE no_more_tables INT DEFAULT 0;  
	DECLARE i_code varchar(30);
	DECLARE i_name varchar(50);
	DECLARE i_groupid int;
	DECLARE i_groupname varchar(30);
	DECLARE i_type int;
	DECLARE i_data double;
	DECLARE i_dataValue varchar(200);
	DECLARE i_collecttime varchar(30);
	DECLARE i_badreason varchar(50);
	DECLARE i_levelid int;
	DECLARE i_levelname varchar(30);
	DECLARE i_unit varchar(30);
	
	##参数指向
	DECLARE i_deviceid int;
	DECLARE i_indicatorcode varchar(20);
	DECLARE i_tounit double;
	
	##在线监测系统中读取数据的表名
	DECLARE i_tablename varchar(50);
	DECLARE i_currenttime timestamp DEFAULT CURRENT_TIMESTAMP;
	
	##遍历所有编码
	DECLARE CUR1 CURSOR FOR
	select a.code,a.name,a.type,a.unit,a.groupid,b.name as groupname
	from aiot_beach_code a,aiot_beach_group b
	where a.groupid = b.id;
	DECLARE CONTINUE HANDLER FOR NOT FOUND  SET  no_more_tables = 1;
	
	##创建保存所有参数最终数据的临时表
	drop table if exists tmp_datatable;
	CREATE TEMPORARY TABLE tmp_datatable
	(	 
		code varchar(30),
		name varchar(50),
		groupid int,
		groupname varchar(30),
		type int,
		data double,
		dataValue varchar(200),
		collecttime varchar(30),
		badreason varchar(50),
		levelid int,
		levelname varchar(30)
	);
	
	##根据当前站点以及查询时间获得需要查询的表名
	SELECT TABLENAME INTO i_tablename
	FROM AIOT_META_TABLE
	WHERE TYPE = 1 AND WPID = V_STATIONID
	AND ISACTIVE = 1 
	AND BEGINTIME <= i_currenttime AND ENDTIME >= i_currenttime
	LIMIT 1;
	
	OPEN cur1;
	REPEAT
    FETCH cur1 INTO i_code,i_name,i_type,i_unit,i_groupid,i_groupname;
    	if not no_more_tables then
    		select i_code,i_type;
    		if i_unit is null or i_unit = '-' then 
    			set i_unit = ' ';
    		end if;
    		##得到该参数在上报数据表中的数据
    		if i_type = 1 then
    			select a.collecttime,a.data,concat(a.data,i_unit)
    			into i_collecttime,i_data,i_datavalue
    			from aiot_beach_data a
				where a.stationid = v_stationid
				and code = i_code
				order by collecttime desc
				limit 1;
    		else 
    			select a.collecttime,a.data,b.value as datavalue
    			into i_collecttime,i_data,i_datavalue
				from aiot_beach_data a,aiot_beach_config b
				where a.data = b.data
				and a.code = b.code
				and a.code = i_code
				and a.stationid = v_stationid
				order by a.collecttime desc
				limit 1;
    		end if;
    		
    		if i_type = 3 then
    			select '4444444444444';
    			##判断该参数是否有指向target  自动读取数据
    			select deviceid,indicatorcode,tounit
    			from aiot_beach_target
    			where stationid = v_stationid
    			and code = i_code;
    			
    			select deviceid,indicatorcode,tounit
    			into i_deviceid,i_indicatorcode,i_tounit
    			from aiot_beach_target
    			where stationid = v_stationid
    			and code = i_code;
    			select '33333333333';
    			select concat(i_deviceid,i_indicatorcode,i_tounit);
    			##当有指向时,读取该参数在系统中的最后一条数据
    			if i_deviceid is not null and i_indicatorcode is not null and i_tounit is not null then
    				select '22222222222222';
    				select data,concat(data,i_unit)
    				into i_data,i_datavalue
    				from i_tablename
    				order by collect_time desc limit 1;
    				select '1111111111';
    				select i_data,i_datavalue;
    			end if;
    		end if;
		 	select concat(i_code,i_name,i_data,'  ',i_datavalue);
    	end if;
    UNTIL  no_more_tables = 1  END REPEAT;
    close cur1;
	
end ;