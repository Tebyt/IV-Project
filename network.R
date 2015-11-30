table_quote <- read.csv("csv/quote.csv",
                        colClasses = rep("integer", 5),
                        stringsAsFactors = FALSE);

table_thank <- read.csv("csv/thank.csv",
                        colClasses = rep("integer", 4),
                        stringsAsFactors = FALSE);

table_pm <- read.csv("csv/pm.csv",
                        colClasses = rep("integer", 4),
                        stringsAsFactors = FALSE);

table_user <- read.csv("csv/user.csv",
                       colClasses = c("character", "integer"),
                       stringsAsFactors = FALSE);

userids <- table_user$userid;
match <- rep(FALSE, length(userids));


markUsedID <- function(table, userids, match) {
  match <- markUsedIDAux(table$fromuser, userids, match);
  match <- markUsedIDAux(table$touser, userids, match);
}

markUsedIDAux <- function(ids, userids, match) {
  size <- length(ids);
  for (row in 1:size) {
    if (which(userids == ids[row]) > 0)
    match[which(userids == ids[row])] = TRUE;
  }
  return (match);
}

match <- markUsedID(table_quote, userids, match);
match <- markUsedID(table_pm, userids, match);
match <- markUsedID(table_thank, userids, match);

nodes <- userids[match];
nodes <- nodes[order(nodes)]

###########################
## Below generates links ##

connections_quote <- table_quote[, c("fromuser", "touser")];
connections_quote$group <- rep("quote", nrow(connections_quote));
connections_pm <- table_pm[, c("fromuser", "touser")];
connections_pm$group <- rep("pm", nrow(connections_pm));
connections_thank <- table_thank[, c("fromuser", "touser")];
connections_thank$group <- rep("pm", nrow(connections_thank));

connections <- rbind(connections_quote, connections_pm, connections_thank);

# Make fromuser always less than touser
# and elliminate self link
getOneWayLink <- function(connections) {
  tmp <- integer(length(fromusers));
  index <- connections$fromuser > connections$touser;
  tmp[index] <- connections$fromuser[index];
  connections$fromuser[index] <- connections$touser[index];
  connections$touser[index] <- tmp[index];
  return (connections);
}

generateLinks <- function(nodes, connections, counts) {
  connections <- getOneWayLink(connections);
  connections <- connections[with(connections, order(fromuser, touser)), ];
  
  fromusers <- connections$fromuser;
  tousers <- connections$touser;
  size <- nrow(connections);
  row <- 1;
  while (row <= size) {
    curFromuser <- fromusers[row];
    curTouser <- tousers[row];
    curRow <- row;
    while (row <= size && fromusers[row] == curFromuser && tousers[row] == curTouser) {
      row <- row + 1;
      counts[curRow] <- counts[curRow] + 1;
    }
    fromusers[curRow] <- which(nodes == curFromuser)-1;
    tousers[curRow] <- which(nodes == curTouser)-1;
  }
  links <- data.frame(source = fromusers, target = tousers, 
                      value = counts, group = connections$group);
  return (links[links$value>0, ]);
}


counts <- rep(0, nrow(connections));
links <- generateLinks(nodes, connections, counts);


# Elliminating abnormal data


write.table(nodes, file="csv/network_nodes.csv", row.names=FALSE, col.names=c("name"));
write.csv(links, file="csv/network_links.csv", row.names=FALSE);


