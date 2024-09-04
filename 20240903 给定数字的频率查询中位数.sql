
-- env: hadoop 3.1.4 + hive 3.1.3

--==============================================================
-- data requirement
--==============================================================
-- input
-- num freq
-- 0 7
-- 1 1
-- 2 3
-- 3 1

-- target 
-- 0
--==============================================================

--==============================================================
-- create base table
create table base (
    num int,
    freq int
);
insert into base values(0, 7), (1, 1), (2, 3), (3, 1);
--==============================================================

--==============================================================
-- solution 1: 利用中位数公式求得数组的中位数
select
    num
from 
(
    select
        num,
        row_number() over (order by num) rn,
        count(1) over () cnt
    from base 
    lateral view posexplode(split(space(freq - 1), space(1))) tmp as pos, val
) t
where abs(rn - (cnt + 1) / 2) < 1       -- 利用公式求解中位数
group by num;

-- key points space(int n)
-- 返回长度为n的空格字符串
select space(10)                 -- 会返回十个空格组成的字符串
select length(space(10));        -- 10
-- space + split
select split(space(10), '');
-- return: [" "," "," "," "," "," "," "," "," "," ",""]
select size(split(space(10), ''))       -- 11

-- output
-- 0
--==============================================================

