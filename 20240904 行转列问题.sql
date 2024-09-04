
-- env: hadoop 3.1.4 + hive 3.1.3

--==============================================================
-- data requirement
--==============================================================
-- input
-- partner label   value
-- 001     原始证件号      9111030275820228X7
-- 001     统一社会信用代码        8111030275820228X7
-- 002     原始证件号      6111030255820228Y7
-- 002     统一社会信用代码        5111030255820228Y7

-- target 
-- 001 9111030275820228X7 8111030275820228X7
-- 002 6111030255820228Y7 5111030255820228Y7
--==============================================================

--==============================================================
-- create base table
create table base as 
select '001' as partner , '原始证件号' as label,'9111030275820228X7' as value union all
select '001' as partner , '统一社会信用代码' as label,'8111030275820228X7' as value union all
select '002' as partner , '原始证件号' as label,'6111030255820228Y7' as value union all
select '002' as partner , '统一社会信用代码' as label,'5111030255820228Y7' as value;
--==============================================================

--==============================================================
-- solution 1: 结合case when + max函数实现行转列
select 
    partner,
    max(case when label = '原始证件号' then value else NULL end) as id,
    max(case when label = '统一社会信用代码' then value else NULL end) as tx_num
from base
group by partner

-- key points:
-- 利用max()函数可以有效的去除NULL值，max()函数在计算的时候会忽略NULL值

-- output:
-- partner id      tx_num
-- 001     9111030275820228X7      8111030275820228X7
-- 002     6111030255820228Y7      5111030255820228Y7
-- Time taken: 49.683 seconds, Fetched: 2 row(s)
--==============================================================

--==============================================================
-- solution 2: 利用 HQL 的 str_to_map 函数，可以将字符串拆分成map的格式，直接根据key值取值

-- concat_ws(":", label, value)
    -- 原始证件号:9111030275820228X7
-- collect_list(concat_ws(":", label, value))
    -- ["原始证件号:9111030275820228X7","统一社会信用代码:8111030275820228X7"]
-- concat_ws('&', collect_list(concat_ws(":", label, value)))
    -- 原始证件号:9111030275820228X7&统一社会信用代码:8111030275820228X7

with p_map as (
    select 
        partner,
        str_to_map(
            concat_ws('&', collect_list(concat_ws(":", label, value))),
            "&",
            ":"
        ) as mmap
    from base
    group by partner
)
select 
    partner,
    mmap['原始证件号'] as id,
    mmap['统一社会信用代码'] as tx_num
from p_map;

-- key points
-- str_to_map(字符串参数, 分隔符1, 分隔符2)
-- 使用两个分隔符将文本拆分为键值对。分隔符1将文本分成K-V对，分隔符2分割每个K-V对。
-- 对于分隔符1默认分隔符是 ','，对于分隔符2默认分隔符是 '='。以下为使用样例
-- str_to_map('aaa:11&bbb:22', '&', ':');
    -- {"aaa":"11","bbb":"22"}

-- output:
-- 001     9111030275820228X7      8111030275820228X7
-- 002     6111030255820228Y7      5111030255820228Y7
--==============================================================

--==============================================================
-- solution n: 

-- output:

--==============================================================

