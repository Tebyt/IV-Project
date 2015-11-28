# IV-Project

This is our reference for the interface. 

## Files
### Preprocessing
* **data.sql** generates csv files
* **quote.R** extract quote connections from post.csv

### Data
* **post.csv** post information
* **quote.csv** quote connection

### Temporary
* **q_conn.json** connection data for force graph
* **force-graph.html** testing page for force graph


## Data Format
There will be one **SINGLE** global variale containg all the data we need, it's format is as follow:


```
var data = {
	quote: {
		fromuser: String(), // name
		touser: String(), // name
		date: Int(),
		postid: Int(),
		threadid: Int(),
	},
	post: {
		username: String(),
		pagetext: String(), // post content
		postid: Int(),
		threadid: Int(),
		dateline: Int()
	}
}
		

```

## Functions
Don't access any global variable inside function (always pass in)

```
function displayNetwork(data, attr) {
attr specifies what attributes user wants the network graph to show as a circle
e.g. Most post user, Reputable user

The function will draw graph in <svg id = "network_viz">	
}
```


## Sub Visualization Prefix
We need to use prefix to name every element to prevent conflict when merging our works.
 
**\<circle id="barchart_circle" />**

When you use d3.select or css, only select element by ID

This will also be the prefix for your auxiliary functions

** function network_addCircle() {}**



* **network_ ** for network overview

## For Network Overview
Run force_graph_csv/force_graph_group_csv.html

This file reads data from: 
1) force_graph_csv/quotes.csv
2) usersGroupByMostActiveForum.csv

## Local server
Since bracket.io server doesn't automatically load the changes in the code, run the local server instead.
1. Before running the server install nodejs: https://nodejs.org/en/download/ 
2. Run the terminal and navigate to project folder.
3. Run the following command:
    node server.js
4. Then, go to the browser and go to the url: http://localhost:4567 

## Things TODO:
1. Tweak the gravity, charge, and friction of the network overview: force_graph_csv/force_graph_group_csv.html
Right now the graph is simply too tight to each other

2. Create a transition from node click to user-centric view
