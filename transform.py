import csv
import json
from copy import deepcopy

'''


data:[
	{
		threads:	[ {threadid:_, title:_, posts:[{postid, posttitle, date, userid, userIndex}, ...]} ]
		users:		[ {userid:_, username:_, lv:_, 	posts:[{postid, threadid, date, posttitle, threadIndex}, ...]} ],
		forumid:_ ,
		forumtitle:_,
		numberofthreads:_,
		numberofposts:_,
		numberofusers:_,
		first_post_date:_
		last_post_date:_
	}
]

Note that there is no threadindex (i.e. threadindex = -1) if that post is not in that forum.
Similarly, there is not userindex of that post is not in that forum.

*To add
'''

forum_list = []

isLimit = False
#LEAST_NUMBER_OF_POSTS_PER_FORUM = 2000
MAX_NUMBER_OF_POSTS_PER_FORUM = 5000

def find(listToFind, key, value):
	for i, dic in enumerate(listToFind):
		if dic[key] == value:
			return i
	return -1

def readForums():
	with open('csv/forumInfo.csv', 'rb') as f:
		reader = csv.reader(f)
		#row = forumid,forumtitle,numberofthreads,numberofposts,activeusers, first_post_date,last_post_date
		rownum = 0

		for row in reader:
			if rownum>0:
				forum_info = {"forumid":int(row[0]), "forumtitle":row[1], "numberofthreads":0, "numberofposts":0,"numberofusers":0, "users":[], "threads":[], "first_post_date":int(row[5])*1000,"last_post_date":int(row[6])*1000 }
				#print forum_info
				forum_list.append(forum_info)
			rownum = rownum + 1

	#Sort forum_list by forumid
	#for ordered perservation
	forum_list.sort(key=lambda forum: forum["forumid"], reverse=False)


def addThreadToForum(index_forum, post_info, row):
	#Find the threadid in the threads[]
	threadid = int(row[6])
	threadtitle = row[5]
	index_thread = find(forum_list[index_forum]["threads"], "threadid", threadid)			

	if index_thread != -1:

		#numberofposts:_,
		forum_list[index_forum]["numberofposts"] = forum_list[index_forum]["numberofposts"] + 1

		#Add post to the thread
		forum_list[index_forum]["threads"][index_thread]["posts"].append(post_info)

	else:

		#numberofthreads:_,
		forum_list[index_forum]["numberofthreads"] = forum_list[index_forum]["numberofthreads"] + 1
		forum_list[index_forum]["numberofposts"] = forum_list[index_forum]["numberofposts"] + 1

		#Add thread
		thread_info = {"threadid":int(threadid), "title":threadtitle, "posts":[post_info]}
		forum_list[index_forum]["threads"].append(thread_info)

		#print "add thread: "+str(thread_info) 
		#print "numberofposts:"+str(forum_list[index_forum]["numberofposts"])

def addUserToForum(index_forum, user_info, post_info, row):
	index_user = find(forum_list[index_forum]["users"], "userid", user_info["userid"])			

	if index_user!=-1:

		#Add the user's post to the list of posts
		forum_list[index_forum]["users"][index_user]["posts"].append(post_info)

	else:

		#Add the user, otherwise don't add the user
		forum_list[index_forum]["users"].append(user_info)

		#numberofusers:_,
		forum_list[index_forum]["numberofusers"] = forum_list[index_forum]["numberofusers"] + 1


	

def addInfoForums():
	ifile  = open('csv/postTimeSeries.csv', "rb")
	reader = csv.reader(ifile)

	rownum = 0
	for row in reader:
		# Save header row.
		if rownum == 0:
			header = row
		else:
			#row = userid,username,lv, forumtitle,forumid,threadtitle,threadid,userid,postid,posttitle,dateposted,posttext
			forumid = int(row[4])
			index_forum = find(forum_list, "forumid", forumid)			
			
			#If the forum already added, then increase the statistics properly
			if index_forum != -1:

				numberofposts = forum_list[index_forum]["numberofposts"]
				if (numberofposts<=int(MAX_NUMBER_OF_POSTS_PER_FORUM) and isLimit) or not isLimit:

					#Add post
					postid = int(row[8])
					posttitle = row[9]
					dateposted = int(row[10]) *1000
					threadid = int(row[6])
					
					#Add the userid, username to the right forum
					userid = int(row[0])
					username = row[1]
					lv = int(row[2])

					#{postid, posttitle, date, userid}
					post_info = {"postid":postid, "posttitle":posttitle, "date":dateposted, "userid":userid, "threadid":threadid}
					
					#user_list = [ {userid:_, username:_, lv:_, posts:[{postid, threadid, date, posttitle, posttext}, ...]}, ... ]
					user_info = {"userid":userid, "username":username, "lv":lv, "posts":[]}
					user_info["posts"].append(post_info)

					#Add user
					addUserToForum(index_forum, user_info, post_info, row)

					
					#Add thread to forum
					addThreadToForum(index_forum, post_info, row)
					
					
			
		rownum = rownum + 1


readForums()

addInfoForums()

#sort the threads and users
#for ordered perservation
for index, item in enumerate(forum_list):
	for i, thread in enumerate(item["threads"]):
		thread["posts"].sort(key=lambda post: post["date"], reverse=False)

	item["users"].sort(key=lambda user: user["userid"], reverse=False)

	for i, user in enumerate(item["users"]):
		user["posts"].sort(key=lambda post: post["date"], reverse=False)


#Add the thread index and user index
#Add threadindex to the user array in forum
for index, item in enumerate(forum_list):
	for userIndex, userItem in enumerate(forum_list[index]["users"]):
		for postIndex, postItem in enumerate(forum_list[index]["users"][userIndex]["posts"]):

			#Find the thread index in the thread version
			threadIndex = find(item["threads"], "threadid", postItem["threadid"]) 

			if threadIndex!=-1:
				forum_list[index]["users"][userIndex]["posts"][postIndex]["threadindex"] = threadIndex
			else:
				print "forumid: "+str(item["forumid"])+" remove "+str(postItem)
				forum_list[index]["users"][userIndex]["posts"].remove(postItem)
				#postIndex =postIndex- 1

#Add userindex to the thread array in forum
for index, item in enumerate(forum_list):
	for threadIndex, threadItem in enumerate(item["threads"]):
		for postIndex, postItem in enumerate(threadItem["posts"]):
			
			userIndex = find(item["users"], "userid", postItem["userid"]) 
			if userIndex!=-1:
				forum_list[index]["threads"][threadIndex]["posts"][postIndex]["userIndex"] = userIndex
			else:
				print "forumid: "+str(item["forumid"])+" remove "+str(postItem)
				forum_list[index]["threads"][threadIndex]["posts"].remove(postItem)
				#postIndex =postIndex- 1


with open("csv/dual_data.json", "w") as outfile:
	json.dump({"data":forum_list}, outfile)


