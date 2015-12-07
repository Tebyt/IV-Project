var Forumid = Array();
function dataload(){
    d3.json("dual_data.json", function(data){
        for(var j=0;j<data.data.length;j++){
            console.log(data.data[j]);
            Forumid.push(data.data[j]["forumid"]);
        }
    });
}

function GetBarInfo(forumid){
    var j = Forumid.indexOf(forumid.toString());
    d3.json("dual_data.json", function(data){
        /*for(var j=0;j<data.data.length;j++){*/
        var Thread = [];
        var length = data.data[j]["threads"].length;
        for(var i=0; i<length; i++){
            var userN = ThreadUserNum(data.data[j]["threads"][i]["posts"]);
            var postN = data.data[j]["threads"][i]["posts"].length;
            Thread.push({
                "threadid":data.data[j]["threads"][i]["title"],
                "userNum":userN,
                "postNum":postN
            });
        }
        drawbar(Thread);
    });
}

function ThreadUserNum(obj){
    var num = 0;
    var useridarray = Array();
    for (var i=0; i<obj.length;i++){
        if(useridarray.indexOf(obj[i]["userid"]) > -1){
        }else{
            num+=1;
            useridarray.push(obj[i]["userid"])
        }
    }
    return num;
}

function drawbar(Thread){
    var columns = [{"column":"Thread title"},{"column":"Number of Users"},{"column":"Number of Posts"}];
    var attributes = ["threadid","userNum","postNum"];
   
    var table = d3.select("div").append("table"),
    thead = table.append("thead"),
    tbody = table.append("tbody");

// append the header row
    thead.append("tr")
        .selectAll("th")
        .data(columns)
        .enter()
        .append("th")
            .html(function(d) { return d.column; })
            .data(attributes)
            .on("click",function(k){
                rows.sort(function(a, b){
                    return d3.descending(a[k], b[k]);
            });
        });

// create a row for each object in the data
    var rows = tbody.selectAll("tr")
        .data(Thread)
        .enter()
        .append("tr")
        .on("mouseover",function(){
            d3.select(this).style({
                "background-color":"rgba(192,192,192,0.5)"
            })
        })
        .on("mouseout",function(){
            d3.select(this).style({
                "background-color":"white"
            })
        });

    rows.append("td").html(function(d){return d.threadid;})
    
    var cln2 = rows.append("td").append("svg").attr("height",14).attr("width",function(d){return d.userNum;});
    cln2.append("rect")
            .attr("width",function(d){return d.userNum;})
            .attr("height",14)
            .attr("fill","blue");
    
    var cln3 = rows.append("td").append("svg").attr("height",14).attr("width",function(d){return d.postNum;});
    cln3.append("rect")
            .attr("width",function(d){return d.postNum;})
            .attr("height",14)
            .attr("fill","black");


}


