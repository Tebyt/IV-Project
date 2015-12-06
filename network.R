generateIDs <- function() {
  table_user <- read.csv("csv/user.csv",
                         colClasses = c("character", "integer"),
                         stringsAsFactors = FALSE);
  return (table_user$userid);
}

deleteUnusedIDs <- function(IDs, connections) {
  markUsedID <- function(IDs, connections, match) {
    match <- markUsedIDAux(connections$fromuser, IDs, match);
    match <- markUsedIDAux(connections$touser, IDs, match);
  }
  markUsedIDAux <- function(ids, IDs, match) {
    size <- length(ids);
    for (row in 1:size) {
      if (which(IDs == ids[row]) > 0)
        match[which(IDs == ids[row])] = TRUE;
    }
    return (match);
  }
  
  
  match <- rep(FALSE, length(IDs));
  match <- markUsedID(IDs, connections, match);
  return (IDs[match]);
}

deleteIDs <- function(IDs, toDelete) {
  for (item in 1:length(toDelete)) {
    IDs <- IDs[IDs != toDelete[item]]
  }
  return (IDs);
}

generateConnections <- function() {
  table_quote <- read.csv("csv/quote.csv",
                          colClasses = rep("integer", 5),
                          stringsAsFactors = FALSE);
  
  table_thank <- read.csv("csv/thank.csv",
                          colClasses = rep("integer", 4),
                          stringsAsFactors = FALSE);
  
  table_pm <- read.csv("csv/pm.csv",
                       colClasses = rep("integer", 4),
                       stringsAsFactors = FALSE);
  connections_quote <- table_quote[, c("fromuser", "touser")];
  connections_quote$group <- rep("quote", nrow(connections_quote));
  connections_pm <- table_pm[, c("fromuser", "touser")];
  connections_pm$group <- rep("pm", nrow(connections_pm));
  connections_thank <- table_thank[, c("fromuser", "touser")];
  connections_thank$group <- rep("pm", nrow(connections_thank));
  connections <- rbind(connections_quote, connections_pm, connections_thank);
  return (connections);
}

deleteConnections <- function(connections, toDelete) {
  for (item in 1:length(toDelete)) {
    connections <- connections[connections$fromuser != toDelete[item], ];
    connections <- connections[connections$touser != toDelete[item], ];
  }
  return (connections);
}

# Make fromuser always less than touser
# and elliminate self link
convertToOneWayConnection <- function(connections) {
  tmp <- integer(length(connections$fromusers));
  index <- connections$fromuser > connections$touser;
  tmp[index] <- connections$fromuser[index];
  connections$fromuser[index] <- connections$touser[index];
  connections$touser[index] <- tmp[index];
  return (connections);
}

generateLinks <- function(IDs, connections) {
  connections <- connections[with(connections, order(fromuser, touser)), ];
  counts <- rep(0, nrow(connections));
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
    # Careful: index in d3 starts from 0
    i_from <- which(IDs == curFromuser);
    i_to <- which(IDs == curTouser);
    if (length(i_from) == 0 || length(i_to) == 0) {
      counts[curRow] <- -1;
    } else {
      fromusers[curRow] <- i_from-1;
      tousers[curRow] <- i_to-1;
    }
  }
  links <- data.frame(source = fromusers, target = tousers, 
                      value = counts);
  return (links[links$value>0, ]);
}

scale <- function(data, range_min, range_max) {
  min <- min(data);
  max <- max(data);
  r <- round((data - min) / (max - min) * 
    (range_max - range_min) + range_min, 2);
  r[r<0] = 0;
  return (r);
}

# scale <- function(data, kept_amount, range_min, range_max) {
#   qt <- 1 - kept_amount/length(data);
#   min <- quantile(data, qt);
#   max <- max(data);
#   r <- numeric(length(data));
#   r[data < min] <- 0;
#   r[data > min] <- round((data[data > min] - min) / (max - min) * 
#                            (range_max - range_min) + range_min, 2);
#   return (r);
# }

generateStrengthByConnection <- function(IDs, links) {
  strength <- integer(length(IDs));
  # Careful: start index differ
  sources <- links$source + 1;
  targets <- links$target + 1;
  
  values <- links$value;
  size <- nrow(links);
  for (row in 1:size) {
    strength[sources[row]] <- strength[sources[row]] + values[row];
    strength[targets[row]] <- strength[targets[row]] + values[row];
  }
  return (strength);
}

filterIDByStrength <- function(nodes, strength, num) {
  IDs <- nodes$name;
  qt <- 1 - num/length(IDs);
  min <- quantile(strength, qt)
  return (nodes[strength > min, ]);
}

#### Main ####

IDs <- generateIDs();
connections <- generateConnections();
# Delete those IDs that never appear in connection
IDs <- deleteUnusedIDs(IDs, connections);

# Elliminate abnormal data
toDelete = c(18936, 18957, 18950, # only connections among themselves
             14116);  # system messages
IDs <- deleteIDs(IDs, toDelete);
connections <- deleteConnections(connections, toDelete);

# Treat A->B and B->A the same
connections <- convertToOneWayConnection(connections);
# Order ID so the generated links will be ordered (unnecessary)
IDs <- IDs[order(IDs)];
links <- generateLinks(IDs, connections);

strength <- generateStrengthByConnection(IDs, links);
nodes <- data.frame(name = IDs, r = strength);
filtered_nodes <- filterIDByStrength(nodes, strength, 100);
filtered_nodes$r <- scale(filtered_nodes$r, 10, 50);
filtered_links <- generateLinks(filtered_nodes$name, connections);

write.csv(filtered_nodes, file="csv/network_nodes.csv", row.names=FALSE);
write.csv(filtered_links, file="csv/network_links.csv", row.names=FALSE);

nodes$r <- strength;
nodes$r <- scale(nodes$r, 100, 10, 50);

# nodes <- data.frame(name = IDs, r = r);
# 
write.csv(nodes, file="csv/network_nodes.csv", row.names=FALSE);
write.csv(links, file="csv/network_links.csv", row.names=FALSE);
