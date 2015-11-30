table_post <- read.csv("csv/post.csv",
                       colClasses = c(rep("character", 2), rep("integer", 4)),
                       stringsAsFactors = FALSE,
                       na.strings = "NULL");

startTag <- "\\[quote.*?\\]";
endTag <- "\\[\\/quote\\]";

extractQuotes <- function(pagetext, startTag, endTag) {
  result <- character();
  depth <- 0;
  quote <- "";
  quoteStart <- regexpr(startTag, pagetext, ignore.case=TRUE);
  if (quoteStart < 0) {
    return (result);
  }
  quoteEnd <- regexpr(endTag, pagetext, ignore.case=TRUE);
  while (TRUE) {
    if (quoteStart < 0 && quoteEnd < 0) {
      return (result);
    } else if (quoteStart < 0 || quoteEnd < quoteStart) {
      quote <- paste0(quote, substring(pagetext, 1, quoteEnd+7));
      pagetext <- substring(pagetext, quoteEnd+8);
      quoteStart <- quoteStart - (quoteEnd + 7);
      quoteEnd <- regexpr(endTag, pagetext, ignore.case=TRUE);
      depth <- depth - 1;
    } else {
      if (quote == "") {
        quote <- substring(pagetext, quoteStart, quoteStart);
      } else {
        quote <- paste0(quote, substring(pagetext, 1, quoteStart));
      }
      pagetext <- substring(pagetext, quoteStart+1);
      quoteEnd <- quoteEnd - quoteStart;
      quoteStart <- regexpr(startTag, pagetext, ignore.case=TRUE);
      depth <- depth + 1;
    }
    if (depth == 0) {
      result <- append(result, quote);
      quote = "";
    } else if (depth < 0) {
      result <- append(result, paste0(quote, pagetext));
      return (result);
    }
  }
}

getUsernameByID <- function(quote) {
  userName <- sub(".*\\[QUOTE\\=(.+)\\;\\d+\\].*", "\\1", quote, ignore.case = TRUE);
  if (userName != quote) {
    return (userName);
  }
  userName <- sub(".*\\[quote author\\=(.+) link\\=topic\\=\\d+\\.(msg\\d+)\\#\\2 date\\=\\d+\\].*"
                  , "\\1", quote, ignore.case = TRUE);
  if (userName != quote) {
    return (userName);
  }
  return ("");
}

findMatchedRow <- function(quote, pagetexts, startRow, endRow) {
  if (quote == "") {
    return (-1);
  }
  for (row in startRow:endRow) {
    if (regexpr(quote, pagetexts[row], fixed=TRUE) > 0) {
      return (row);
    }
  }
  return (-1);
}


buildQuote <- function(post, startTag, endTag) {
  progress <- 0;
  startTime <- proc.time()[3];
  
  newRows <- integer();
  newTousers <- character();
  
  endRow <- 1;
  size <- nrow(post);
  tousers <- character(nrow(post));
  pagetexts <- post$pagetext;
  threadids <- post$threadid;
  fromusers <- post$username;
  importpostids <- post$importpostid;
  dates <- post$dateline;
  postids <- post$postid;
  for (row in 2:size) {
    if (threadids[row] != threadids[row-1]) {
      endRow = row;
      next;
    }
    pagetext <- pagetexts[row];
    quotes <- extractQuotes(pagetext, startTag, endTag);
    if (length(quotes) == 0) {
      next;
    }
    first <- TRUE;
    result <- "";
    for (quote in quotes) {
      username <- getUsernameByID(quote);
      if (username == "") {
        quote <- sub(paste0(startTag, "(.*)", endTag), "\\1", quote, ignore.case <- TRUE);
        threadid <- threadids[row];
        matched_row <- findMatchedRow(quote, pagetexts, row-1, endRow);
        if (matched_row > 0) {
          username <- fromusers[matched_row];
        } else {
          next;
        }
      }
      if (first) {
        tousers[row] <- username;
        first = FALSE;
      } else {
        newRows = append(newRows, row);
        newTousers = append(newTousers, username);
      }
    }
    if (row / size > progress) {
      progress = progress + 0.01;
      cat("\014")
      cat("Progress:\t", progress*100, "%\n");
      cat("Time Estimate:\t", as.integer((proc.time()[3]-startTime)/progress*(1-progress)), "\tseconds\n");
      cat("Time Elapse:\t", as.integer(proc.time()[3]-startTime), "\tseconds\n");
    }
  }
  
  
  cat("\014");
  cat("Time Elapse:\t", as.integer(proc.time()[3]-startTime), "\tseconds\n");
  cat("Finished");
  
  newData = getNewRows(newRows, newTousers, fromusers, dates, postids, threadids);
  post$touser = tousers;
  post = post[tousers != "",];
  post = post[, c("username", "touser", "dateline", "postid", "threadid")];
  colnames(post) <- c("fromuser", "touser", "date", "postid", "threadid");
  post = rbind(post, newData);
  return (post);
}

getNewRows <- function(newRows, newTousers, fromusers, dates, postids, threadids) {
  size = length(newRows);
  newFromusers = character(size);
  newDates = integer(size);
  newPostids = integer(size);
  newThreadids = integer(size);
  for (row in 1:size) {
    i = newRows[row];
    newFromusers[row] = fromusers[i];
    newDates[row] = dates[i];
    newPostids[row] = postids[i];
    newThreadids[row] = threadids[i];
  }
  return (data.frame(fromuser=newFromusers, touser=newTousers, date=newDates, postid=newPostids, threadid=newThreadids));
}

table_quote = buildQuote(table_post, startTag, endTag);

write.csv(table_quote, file="csv/quote.csv", row.names=FALSE);


# write(toJSON(unname(split(table_quote, 1:nrow(table_quote)))), "json/quote.json");

###########################
## For profiling:
# fileName <- "prof_main.txt";
# Rprof(fileName);
# table_quote = buildQuote(table_post, startTag, endTag);
# Rprof(NULL);
# fileName <- "prof_main.txt";
# summaryRprof(fileName)$by.total[1:20,];
