import csv
import json
'''
{
	forum:[
		{
			users:		[ {lv:_, 			posts:[{postid, date, threadid}, ...]} ],
			threads:	[ {threadid:_, title:_, posts:[{postid, posttitle, date, userid}, ...]} ]
			forumid:_ ,
			forumtitle:_,
			numberofthreads:_,
			numberofposts:_,
			activeusers:_
		}
	]
}
'''
isLimit = False

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
		print "Not added to any forum:"+user_info



def addPostToThread(post_info, row):
	threadid = row[5]
	threadtitle = row[4]
	forumid = row[3]

	#Add post_info the the right thread in thread_list
	isPostAdded = False
	for index, threaditem in enumerate(thread_list):
		if threaditem["threadid"] == threadid:
			thread_list[index]["posts"].append(post_info)
			isPostAdded = True
			break
	#thread_info = [ {threadid, title:_, posts:[post_info, ...]} ]
	if not isPostAdded:
		thread_list.append({"threadid":threadid, "title":threadtitle, "posts":[post_info], "forumid":forumid})
		


forum_list = []
with open('csv/forumInfo.csv', 'rb') as f:
	reader = csv.reader(f)
	#row = forumid,forumtitle,numberofthreads,numberofposts,activeusers
	rownum = 0

	for row in reader:
		if rownum>0:
			forum_info = {"forumid":row[0], "forumtitle":row[1], "numberofthreads":row[2], "numberofposts":row[3],"numberofusers":row[4], "users":[], "threads":[] }
			#print forum_info
			forum_list.append(forum_info)
		rownum = rownum + 1


#A list of threads and their posts i.e. [ {threadid:_, title:_, 	posts:[{postid, date, userid}, ...]} ]
thread_list = []

ifile  = open('csv/postTimeSeries.csv', "rb")
reader = csv.reader(ifile)

rownum = 0
for row in reader:
	# Save header row.
	if rownum == 0:
		header = row
	else:
		#row = userid,username,forumtitle,forumid,threadtitle,threadid,userid,postid,posttitle,dateposted,posttext
		forumid = row[3]
		forumtitle = row[2]

		#Add the userid, username to the right forum
		userid = row[0]
		username = row[1]
		#{lv:_, posts:[{postid, date, threadid}, ...]}
		user_info = {"userid":userid, "username":username}#, "posts":[]}
		addUserToForum(user_info, row)

		#group posts by threads
		postid = row[7]
		posttitle = row[8]
		dateposted = row[9]
		posttext = row[10]
		#{postid, posttitle, date, userid}
		post_info = {"postid":postid, "posttitle":posttitle, "date":dateposted, "userid":userid} 
		addPostToThread(post_info, row)

		#Add the post information to the users
	if isLimit and rownum>10000:
		break
	rownum += 1

ifile.close()

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


with open("csv/dual_data.json", "w") as outfile:
	json.dump({"data":forum_list}, outfile)


