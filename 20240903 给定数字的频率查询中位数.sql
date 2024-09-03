
-- mysql

create table base (
    num int,
    freq int
);

-- 插入数据
insert into base values(0, 7), (1, 1), (2, 3), (3, 1);

select * from base;
-- num     freq
-- 0       7
-- 1       1
-- 2       3
-- 3       1

-- 

-----------------------------------------------------------------------------------------
-- 知识点 space函数
-- space(int n)
-- 返回长度为n的空格字符串
select space(10)                 -- 会返回十个空格组成的字符串
select length(space(10));        -- 10
-- space + split
select split(space(10), '');
-- return: [" "," "," "," "," "," "," "," "," "," ",""]
select size(split(space(10), ''))       -- 11
-----------------------------------------------------------------------------------------

-- 按照频率展开成明细表
select 
    num, 
    pos + 1 as id
from base
lateral view posexplode(split(space(freq - 1), space(1))) tmp as pos, val;
-- 借助于上边的思路，可以利用space函数实现从1-freq的递增
-- 0       1
-- 0       2
-- 0       3
-- 0       4
-- 0       5
-- 0       6
-- 0       7
-- 1       1
-- 2       1
-- 2       2
-- 2       3
-- 3       1

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
