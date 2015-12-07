import csv
import json
'''

{
	forum:[
		{
			users:		[ {userid:_, username:_, lv:_, 	posts:[{postid, threadid, date, posttitle, posttext}, ...]} ],
			threads:	[ {threadid:_, title:_, posts:[{postid, posttitle, date, userid}, ...]} ]
			forumid:_ ,
			forumtitle:_,
			numberofthreads:_,
			numberofposts:_,
			activeusers:_,
			first_post_date:_
			last_post_date:_
		}
	]
}
*To add
'''
isLimit = True
LEAST_NUMBER_OF_POSTS_PER_FORUM = 2000
MAX_NUMBER_OF_POSTS_PER_FORUM = 5000

def readForums():
	with open('csv/forumInfo.csv', 'rb') as f:
		reader = csv.reader(f)
		#row = forumid,forumtitle,numberofthreads,numberofposts,activeusers, first_post_date,last_post_date
		rownum = 0

		for row in reader:
			if rownum>0:
				forum_info = {"forumid":int(row[0]), "forumtitle":row[1], "numberofthreads":int(row[2]), "numberofposts":int(row[3]),"numberofusers":int(row[4]), "users":[], "threads":[], "first_post_date":row[5],"last_post_date":row[6] }
				#print forum_info
				numberofposts = int(forum_info["numberofposts"])
				if (numberofposts>=int(LEAST_NUMBER_OF_POSTS_PER_FORUM) and numberofposts<=int(MAX_NUMBER_OF_POSTS_PER_FORUM) and isLimit) or not isLimit:
					forum_list.append(forum_info)
			rownum = rownum + 1

#information i.e. {userid}
def addUserToForum(user_info, row):
	#Search for the forum in forum_list
	isAdded = False
	for index, item in enumerate(forum_list):
		if item["forumid"] == forumid:

			#Check to make sure that the user_info added in the forum_list[index] 
			userAdded = False
			for j, userinforum in enumerate(forum_list[index]["users"]):
				if userinforum["userid"] == userid:
					userAdded = True
					break
			if not userAdded:
				forum_list[index]["users"].append(user_info)

			isAdded = True
			break

	if not isAdded:
		print "Not added to any forum:"+str(user_info)



def addPostToThread(post_info, row):
	threadid = int(row[6])
	threadtitle = row[5]
	forumid = int(row[4])

	#Add post_info the the right thread in thread_list
	isPostAdded = False
	for index, threaditem in enumerate(thread_list):
		if threaditem["threadid"] == threadid:
			thread_list[index]["posts"].append(post_info)
			isPostAdded = True
			break
	#thread_info = [ {threadid, title:_, posts:[post_info, ...]} ]
	if not isPostAdded:
		thread_list.append({"threadid":int(threadid), "title":threadtitle, "posts":[post_info], "forumid":int(forumid)})
		

def getNumPostInForum(forumid):
	for index, item in enumerate(forum_list):
		if item["forumid"] == forumid:
			return int(item["numberofposts"])
	return 0

def readTimeSeries():
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
			forumtitle = row[3]
			number_of_post_in_forum = getNumPostInForum(forumid)

			if (number_of_post_in_forum>=LEAST_NUMBER_OF_POSTS_PER_FORUM  and number_of_post_in_forum<=int(MAX_NUMBER_OF_POSTS_PER_FORUM) and isLimit) or not isLimit:
				#Add the userid, username to the right forum
				userid = int(row[0])
				username = row[1]
				lv = int(row[2])
				#{lv:_, posts:[{postid, date, threadid}, ...]}
				#user_info = {"userid":userid, "username":username, "lv":lv}#, "posts":[]}
				#addUserToForum(user_info, row)

				#group posts by threads
				postid = int(row[8])
				posttitle = row[9]
				dateposted = row[10]
				posttext = row[11]
				#{postid, posttitle, date, userid}
				post_info = {"postid":postid, "posttitle":posttitle, "date":dateposted, "userid":userid, "posttext":posttext} 
				addPostToThread(post_info, row)

			#Add the post information to the users
		#if isLimit and rownum>LIMIT:
		#	break
		rownum += 1

	ifile.close()

def addThreadsToForums():
	#We have group threads by forum --> posts by forum
	for tindex, threaditem in enumerate(thread_list):
		#Search for the forum in forum_list
		isThreadAdded = False
		for index, item in enumerate(forum_list):
			if item["forumid"] == threaditem["forumid"]:
				forum_list[index]["threads"].append(threaditem)
				isThreadAdded = True
				break
		if not isThreadAdded:
			print "Not added to any forum:"+threaditem


	#for ordered perservation
	for index, item in enumerate(forum_list):
		for i, thread in enumerate(item["threads"]):
			thread["posts"].sort(key=lambda post: post["date"], reverse=False)
			#print "=========="+thread["threadid"]+"========="
			#for j, post in enumerate(thread["posts"]):
			#	print post["date"]

def readUserPosts():
	ifile  = open('csv/userPostInfo.csv', "rb")
	reader = csv.reader(ifile)

	rownum = 0
	for row in reader:
		# Save header row.
		if rownum == 0:
			header = row
		else:
			#row = userid,username,lv,postid,threadid,forumid,date,posttitle,posttext

			forumid = int(row[5])
			number_of_post_in_forum = getNumPostInForum(forumid)

			#Filter out the posts that do not belong in the forums that arent within the limits
			if (number_of_post_in_forum>=LEAST_NUMBER_OF_POSTS_PER_FORUM  and number_of_post_in_forum<=int(MAX_NUMBER_OF_POSTS_PER_FORUM) and isLimit) or not isLimit:
				#Add the userid, username to the right forum
				userid = int(row[0])
				username = row[1]
				lv = int(row[2])
				#{userid:_, username:_, lv:_, posts:[{postid, threadid, date, posttitle, posttext}, ...]} 
				#userpost_list = {"userid":userid, "username":username, "lv":lv}#, "posts":[]}

				#Add post information to list of users in forum_list
				postid = int(row[3])
				threadid = int(row[4])
				date = row[6]
				posttitle = row[7]
				posttext = row[8]
				#{postid, threadid, date, posttitle, posttext}
				post_info = {"postid":postid, "threadid":threadid, "date":date}#, "posttitle":posttitle, "posttext":posttext} 
				
				#Find the user in the forum list
				#Add post_info to the right user in user_list
				isPostAdded = False
				for index, useritem in enumerate(user_list):
					if useritem["userid"] == userid:
						user_list[index]["posts"].append(post_info)
						isPostAdded = True
						break
				#user_list = [ {userid:_, username:_, lv:_, posts:[{postid, threadid, date, posttitle, posttext}, ...]}, ... ]
				if not isPostAdded:
					user_list.append({"forumid":forumid, "userid":userid, "username":username, "lv":lv, "posts":[post_info]})

			
		rownum += 1

	ifile.close()

def addUserPostToForums():
	#We have group posts by user --> now group user by forum
	for uindex, useritem in enumerate(user_list):
		#Search for the forum in forum_list
		isUserAdded = False
		for index, item in enumerate(forum_list):
			if item["forumid"] == useritem["forumid"]:
				forum_list[index]["users"].append(useritem)
				isUserAdded = True
				break
		if not isUserAdded:
			print "Not added to any forum:"+useritem

forum_list = []
readForums()

#A list of threads and their posts i.e. [ {threadid:_, title:_, posts:[{postid, date, userid}, ...]} ]
thread_list = []
readTimeSeries()
addThreadsToForums()

#Read in user and their post information i.e. [ {userid:_, username:_, lv:_, posts:[{postid, threadid, date, posttitle, posttext}, ...]} ]
#Group posts by user first
user_list = []
readUserPosts()

#Group users by forums
addUserPostToForums()

with open("csv/dual_data.json", "w") as outfile:
	json.dump({"data":forum_list}, outfile)


