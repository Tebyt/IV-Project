var data;

d3.json("../csv/dual_data.json", function (d) {
    data = d.data;
    viz_forum_list(data);
    viz_thread();
    viz_user();
});

function viz_forum_list(dataset) {
    var table_rows = viz_table_structure(dataset, "#search_result",
        "<th>Forum Name</th><th># of Threads</th><th># of Users</th>",
        ["forumtitle", "numberofthreads", "numberofusers"],
        ["50%", "25%", "25%"]);



    table_rows.on("click", function(d, i) {
            d3.select("#search_result").style({
                "display": "none"
            });
            d3.select("#cover").style({
                "display": "none"
            });
            viz_user(data[i].users);
            viz_thread(data[i].threads);
        });
    table_rows.append("td").text(function(d) {return d.forumtitle;});
    table_rows.append("td").text(function(d) {return d.numberofthreads;});
    table_rows.append("td").text(function(d) {return d.numberofusers;});

    d3.select("#forum_search")
        .on("click", function() {
            d3.select("#search_result").style({
                "display": "table"
            });
            d3.select("#cover").style({
                "display": "block"
            });
        })
}


function viz_thread(threads) {
    var width = [0.2, 0.25, 0.25, 0.3].map(function (d) {
        return d * d3.select("#thread").node().getBoundingClientRect().width - 10;
    });
    var table_rows = viz_table_structure(threads, "#thread",
        "<th>Thread title</th><th># of Users</th><th># of Posts</th><th>Time Series</th>",
        ["title", "userNum", "postNum", "timeSeries"],
        width);
    if (typeof threads == "undefined") {
        return;
    }
    threads = alterThreads(threads);
    threads = addMinMax(threads);

    viz_name(threads, "title", table_rows, width[0]);
    viz_number(threads, "userNum", table_rows, width[1], 20);
    viz_number(threads, "postNum", table_rows, width[2], 20);
    viz_time_series(threads, table_rows, "time_thread", width[3], 15);
}

function viz_user(users) {
    var width = [0.2, 0.25, 0.25, 0.3].map(function (d) {
        return d * d3.select("#user").node().getBoundingClientRect().width - 10;
    });
    table_rows = viz_table_structure(users, "#user",
        "<th>User Name</th><th># of Threads</th><th># of Posts</th><th>Time Series</th>",
        ["username", "threadNum", "postNum", "timeSeries"],
        width);
    if (typeof users == "undefined") {
        return;
    }
    users = addMinMax(users);

    viz_name(users, "username", table_rows);
    //viz_time_series(users, table_rows, "time_user");
}

// temporary functions
function ThreadUserNum(obj) {
    var num = 0;
    var useridarray = Array();
    for (var i = 0; i < obj.length; i++) {
        if (useridarray.indexOf(obj[i]["userid"]) > -1) {} else {
            num += 1;
            useridarray.push(obj[i]["userid"])
        }
    }
    return num;
}

function viz_table_structure(dataset, div_table, thhtml, thdata, width) {
    d3.select(div_table).html("");
    var table = d3.select(div_table)
        .attr("class", "table table-hover table-condensed table-border table-bordered");
    table.append("thead").append("tr")
        .html(thhtml);

    var descending = false;
    table.selectAll("th")
        .data(thdata)
        .style({
            "width": function(d, i) {
                return width[i]+"px";
            }.bind(this)
        })
        .on("click", function (k) {
            if (k === "timeSeries") {
                return;
            }
            if (descending) {
                descending = false;
                table_rows.sort(function (a, b) {
                    return d3.ascending(a[k], b[k]);
                })
            } else {
                descending = true;
                table_rows.sort(function (a, b) {
                    return d3.descending(a[k], b[k]);
                })
            }});

    if (typeof dataset == "undefined") {
        return;
    }
    var table_rows = table.append("tbody")
        .selectAll("tr").data(dataset)
        .enter().append("tr")

    return table_rows;
}

function alterThreads(threads) {
    threads = threads.map(function (thread) {
        thread.userNum = ThreadUserNum(thread.posts);
        thread.postNum = thread.posts.length;
        return thread;
    });
    return threads;
}

function viz_time_series(dataset, table_rows, id, width, height) {
    d3.select("body").append("div").attr("id", "tooltip_"+id)
        .html('<p id="date"></p><p id="value"></p>')
        .style({
            "background-color": "white",
            "border": "solid 1px black",
            "display": "none",
            "position": "absolute"
        })

    var scale = 50; // Merge data to how many blocks

    dataset = formatDate(dataset);

    table_rows.append("td").attr("id", function (d, i) {
        return id + i;
    });

    for (var i = 0; i < dataset.length; ++i) {
        var data = rescale(dataset[i].posts, dataset.minDate, dataset.maxDate, scale);
        MG.data_graphic({
            data: data,
            //interpolate: 'basic',
            show_tooltips: false,
            missing_is_zero: true,
            width: width,
            height: height,
            //full_width: true,
            //full_height: true,
            right: 0,
            top: 0,
            left: 0,
            bottom: 0,
            buffer: 0,
            x_axis: false,
            y_axis: false,
            area: false,
            point_size: 0,
            //y_rug: true,
            axes_not_compact: false,
            //y_extended_ticks: true,
            //yax_count: 0,
            //min_x: dataset.minDate,
            //max_x: dataset.maxDate,
            target: "#" + id + i,
            mouseover: function (d, i) {
                d3.event.preventDefault();
                if (d.value === 0) {
                    return;
                }
                var df = d3.time.format('%b %d, %Y');
                var date = df(d.date);
                var y_val = (d.value === 0) ? 'no data' : d.value;

                var tooltip = d3.select("tooltip_"+id);
                tooltip.select("#date").text("date: " + date);
                tooltip.select("#value").text("#ofPosts: " + y_val);
                tooltip.style({
                    "display": "block",
                    "top": d3.event.pageY + 20 + "px",
                    "left": d3.event.pageX + 20 + "px"
                });
            },
            mouseout: function () {
                var tooltip = d3.select("tooltip_"+id);
                tooltip.style("display", "none");
            }
        });
    }
}

function addMinMax(dataset) {
    dataset.minDate = getMinDate(dataset);
    dataset.maxDate = getMaxDate(dataset);
    return dataset;
}
// functions for viz_time_series
function getMinDate(dataset) {
    var minDate = dataset[0].posts[0].date;
    dataset.forEach(function (thread) {
        thread.posts.forEach(function (post) {
            if (post.date < minDate) {
                minDate = post.date;
            }
        })
    })
    return new Date(new Date(minDate * 1000).setHours(0, 0, 0, 0));
}

function getMaxDate(dataset) {
    var maxDate = dataset[0].posts[0].date;
    dataset.forEach(function (thread) {
        thread.posts.forEach(function (post) {
            if (post.date > maxDate) {
                maxDate = post.date;
            }
        })
    })
    return new Date(new Date(maxDate * 1000).setHours(0, 0, 0, 0));
}

function rescale(posts, minDate, maxDate, scale) {
    if (scale == 0) {
        divider = 1;
    } else {
        divider = (maxDate - minDate) / scale;
    }
    posts = posts.map(function (d) {
        return {
            "date": new Date(new Date(Math.round((d.date - minDate) / divider) * divider + minDate.getTime()).setHours(0, 0, 0, 0))
        }
    })
    //posts = posts.map(function (d) {
    //    return {
    //        "date": d.date < minDate ? minDate : d.date > maxDate ? maxDate : d.date
    //    }
    //})
    posts = posts.reduce(function (prev, next) {
        var matched = false;
        prev.forEach(function (d) {
            if (d.date.getTime() == next.date.getTime()) {
                ++d.value;
                matched = true;
                return;
            }
        })
        if (matched) {
            return prev;
        }
        prev.push({
            "date": next.date,
            "value": 1
        })
        return prev;
    }, []);
    posts.push({
        "date": new Date(maxDate),
        "value": 0
    })
    return posts;
}

function formatDate(threads) {
    threads.forEach(function (thread) {
        thread.posts.forEach(function (post) {
            post.date = new Date(new Date(post.date * 1000).setHours(0, 0, 0, 0));
        })
    })
    return threads;
}


function viz_name(dataset, namefield, table_rows, width) {
    var tooltip = d3.select("body").append("div").append("p");
    tooltip.style({
//        "background-color": "white",
        "border": "solid 1px black",
        "display": "none",
        "position": "absolute",
        "background-color": "white",
        "color": "blue"
    })

    // create a row for each object in the data
    table_rows.append("td").text(function (d) {
            return d[namefield].slice(0, 10);
        }.bind(this))
        .style({
            "width": width
        })
        .on("mouseover", function (d) {
            tooltip.text(d.namefield);
            tooltip.style({
                'display': "block",
                'top': d3.event.pageY + 10 + 'px',
                'left': d3.event.pageX + 10 + 'px'
            });
        })
        .on("mouseout", function (d) {
            tooltip.style({
                'display': "none",
            });
        });
}



// functions for viz_number



function viz_number(dataset, numberfield, table_rows, width, height) {




    var maxNum = table_rows.data().reduce(function (prev, next) {
        if (next[numberfield] > prev) {
            prev = next[numberfield];
        }
        return prev;
    }, 0);

    var scale = function (userNum) {
        //return (userNum / maxNum) * d3.select("#thread").select("thead").selectAll("th:nth-child(" + 1 + ")")
        //    .node().getBoundingClientRect().width;
        //return (userNum / maxNum) * 100;
        return (userNum / maxNum) * width;
    }
    table_rows.append("td").append("svg")
        .style({
            "height": height,
            "width": scale(maxNum)
        })
        .append("rect")
        .attr("width", function (d) {
            return scale(d[numberfield]);
        })
        .attr("height", height)
        .attr("fill", "blue");
}