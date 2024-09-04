
-- env: hadoop 3.1.4 + hive 3.1.3

--==============================================================
-- data requirement
--==============================================================

-- desc：有一张直播间用户进出日志表ods_ks_zb_usr_io_log, 包含uid（用户id）、op_time（进出时间）、op_type（进入=1，出去=0）、oid（直播间id）
-- ques：计算所有直播间峰值在线人数以及持续时间（单位：分钟）

-- input
-- uid  op_time  op_type  oid
-- 1001  2019-9-4 11:11:00      1      A
-- 1002  2019-9-4 11:12:00      1      A
-- 1002  2019-9-4 11:13:00      0      A
-- 1003  2019-9-4 11:14:00      1      A
-- 1005  2019-9-4 11:19:00      1      A
-- 1006  2019-9-4 11:23:00      1      A
-- 1001  2019-9-4 11:30:00      0      A

-- target 
-- oid  max_cnt  dura_ts
-- A      3        7 
--==============================================================

--==============================================================
-- create base table
create table base (
    uid string,
    op_time string,
    op_type int,
    oid string
);
insert into base values 
    ('1001','2019-9-4 11:11:00',1,'A'),
    ('1002','2019-9-4 11:12:00',1,'A'),
    ('1002','2019-9-4 11:13:00',0,'A'),
    ('1003','2019-9-4 11:14:00',1,'A'),
    ('1005','2019-9-4 11:19:00',1,'A'),
    ('1006','2019-9-4 11:23:00',1,'A'),
    ('1001','2019-9-4 11:30:00',0,'A')
;
--==============================================================

--==============================================================
-- solution n: 
    -- 把直播间理解成一个空瓶子，进一个人就 +1，走一个人就 -1，即可计算出最大的直播间人数。
    -- 峰值后的持续时间需要找到最大峰值时的时间，已经峰值后的下一个时间，两个相减即为持续时间
select
    oid,
    max_cnt,
    op_time,
    end_time,
    unix_timestamp(op_time),
    unix_timestamp(end_time),
    -- 计算相差的分钟值, 结束 - 当前时间
    (unix_timestamp(end_time) - unix_timestamp(op_time)) / (60) as dura_ts      -- 持续时间（分钟）
from (
    select
        uid,
        oid,
        op_time,
        cnt,
        max(cnt) over(partition by oid) as max_cnt,
        lead(op_time, 1) over(partition by oid order by op_time) as end_time
    from (
        select
            uid,
            oid,
            op_time,
            sum(case when op_type = 1 then 1 else -1 end) over(partition by oid order by op_time) as cnt
        from base
    ) t
) t
where cnt = max_cnt;

-- key points:
-- 时间戳的单位都是秒，对应的时间戳的长度为小于10位的
-- unix_timestamp()                             -- 返回当前时间戳
-- unix_timestamp(date:string)                  -- 返回对应的时间戳，必须为yyyy-MM-dd HH:mm:ss格式
-- unix_timestamp(date:string, format:string)   -- 返回对应的时间戳，按照自定义的时间格式
select unix_timestamp('2019-9-4 11:23:00');
select unix_timestamp('11:23:00', 'HH:mm:ss');      -- 40980
select unix_timestamp('11:24:00', 'HH:mm:ss');      -- 41040
    -- diff 60s = 1min
-- from_unixtime(timestamp: int/bigint)                     -- 返回时间戳对应的日期
-- from_unixtime(timestamp: int/bigint, format:string)      -- 返回符合format要求的时间戳对应的日期
select from_unixtime(40980);                        -- 1970-01-01 11:23:00
select from_unixtime(40980, 'yyyy-MM-dd HH:mm')     -- 1970-01-01 11:23
-- 如果拿到的时间戳是13位的，则可能是存储了毫秒为单位的时间戳，需要除以1000再进行转化
-- reference: https://blog.csdn.net/HappyRocking/article/details/80854778

-- output:
-- A       4       2019-9-4 11:23:00       2019-9-4 11:30:00       1567596180      1567596600      7
--==============================================================

