
-- hadoop 3.1.4 + hive 3.1.3

-- 准备样例数据
create table base as 
select '001' as partner , '原始证件号' as label,'9111030275820228X7' as value union all
select '001' as partner , '统一社会信用代码' as label,'8111030275820228X7' as value union all
select '002' as partner , '原始证件号' as label,'6111030255820228Y7' as value union all
select '002' as partner , '统一社会信用代码' as label,'5111030255820228Y7' as value;

select * from base;

-----------------------------------------------------------------------------------------
-- 知识点 xxx
-----------------------------------------------------------------------------------------

-- 解决方案1

