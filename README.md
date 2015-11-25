# IV-Project

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


## Sub Visualization Prefix
We need to use prefix to name every element to prevent conflict when merging our works.

e.g.:
 
\<circle id="barchart_circle" />

When you use d3.select or css, only select element by ID

* **network_ ** for network overview
