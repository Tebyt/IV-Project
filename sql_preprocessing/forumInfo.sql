/* forumInfo: forum, forumid, number of threads, number of posts, number of active users*/
select foruminfo.*, last_post_date_table.last_post_date
from (
	select foruminfo1.*, first_post_date_table.first_post_date
	from
	(
		select forumagg.forumid, forumagg.forumtitle, forumagg.numberofthreads,
			forumagg.numberofposts, usercounts.activeusers
		from
		(
			select forum.forumid, forum.title_clean as forumtitle,
				count(threadagg.threadid) as numberofthreads, 
				sum(totpostsinthread) as numberofposts
			from
			(
				select thread.forumid, thread.threadid, 
					thread.replycount+1 as totpostsinthread
				from 
				carderscc_01.thread 
				where thread.replycount>9

			)as threadagg
			 right join
			 carderscc_01.forum
			 on forum.forumid = threadagg.forumid
			 group by forum.forumid
		)as forumagg
		inner join
		(
			select threadusersagg.forumid,  count(threadusersagg.userid) as activeusers
			from (
				select distinct thread.forumid, thread.threadid, post.userid
				from carderscc_01.thread 
				left outer join
				carderscc_01.post
				on thread.threadid = post.threadid
				where thread.replycount>9

			)as threadusersagg
			group by threadusersagg.forumid
		)as usercounts
		on forumagg.forumid = usercounts.forumid
	) as foruminfo1
	inner join
	/*first_post_date*/
	(
		select thread.forumid, (min( post.dateline)) as first_post_date
		from carderscc_01.thread 
		left join 
		carderscc_01.post
		on thread.firstpostid = post.postid
		where thread.replycount>9
		group by thread.forumid
	) as first_post_date_table
	on foruminfo1.forumid = first_post_date_table.forumid
)as foruminfo
inner join
(
	/*last_post_date*/
	select thread.forumid, (max( post.dateline)) as last_post_date
	from carderscc_01.thread 
	left join 
	carderscc_01.post
	on thread.lastpostid = post.postid
	where thread.replycount>9
	group by thread.forumid
)as last_post_date_table
on foruminfo.forumid = last_post_date_table.forumid 
