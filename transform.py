import csv
import json
'''
{
	forum:[
		{
			users:	[ {lv:_, 		posts:[{postid, date, threadid}, ...]} ],
			thread:	[ {title:_, 	posts:[{postid, date, userid}, ...]} ]
			forumid:_ ,
			forumtitle:_,
			numberofthreads:_,
			numberofposts:_,
			activeusers:_
		}
	]
}
'''

#information i.e. {userid}
def addToForum(user_info, row):
	#Search for the forum in forum_list
	isAdded = False
	for index, item in enumerate(forum_list):
		if item["forumid"] == forumid:

			#Check to make sure that the user_info added in the forum_list[index] 
			userAdded = False
			for j, userinforum in enumerate(forum_list[index]["user"]):
				if userinforum["userid"] == userid:
					userAdded = True
					break
			if not userAdded:
				forum_list[index]["user"].append(user_info)

			isAdded = True
			break

	if not isAdded:
		print "Not added to any forum:"+user_info

		
forum_list = []
with open('csv/forumInfo.csv', 'rb') as f:
	reader = csv.reader(f)
	#row = forumid,forumtitle,numberofthreads,numberofposts,activeusers
	rownum = 0

	for row in reader:
		if rownum>0:
			forum_info = {"forumid":row[0], "forumtitle":row[1], "numberofthreads":row[2], "numberofposts":row[3],"numberofusers":row[4], "user":[], "thread":[] }
			#print forum_info
			forum_list.append(forum_info)
		rownum = rownum + 1



ifile  = open('csv/postTimeSeries.csv', "rb")
reader = csv.reader(ifile)

rownum = 0
for row in reader:
	# Save header row.
	if rownum == 0:
		header = row
	else:
		#row = userid,username,forumtitle,forumid,threadtitle,threadid,userid,postid,posttitle,dateposted,posttext
		
		#Add the userid, username to the right forum
		userid = row[0]
		username = row[1]
		forumid = row[3]

		#{lv:_, posts:[{postid, date, threadid}, ...]}
		user_info = {"userid":userid, "username":username, "posts":[]}
		
		addToForum(user_info, row)
		


	rownum += 1

ifile.close()

with open("csv/dual_data.json", "w") as outfile:
	json.dump({"data":forum_list}, outfile)


