select user.userid, user.username, user.reputationlevelid as lv,
	postfilter.postid, postfilter.threadid, postfilter.forumid,
    postfilter.dateline as date, postfilter.title as posttitle, postfilter.pagetext as posttext
from
(
	select post.*, thread.forumid
	from carderscc_01.post inner join carderscc_01.thread 
	on post.threadid = thread.threadid
	where thread.replycount>9 
)as postfilter
inner join
carderscc_01.user
on user.userid = postfilter.userid
