table_quote <- read.csv("quote.csv",
                  colClasses=c("numeric", "character","numeric"),
                  stringsAsFactors = FALSE,
                  na.strings = "NULL");
table_post <- read.csv("post.csv",
                 colClasses=c("numeric", "character", rep("numeric",3)),
                 stringsAsFactors = FALSE,
                 na.strings = "NULL");

dealQuote <- function(quote, post) {
  if ( regexpr("\\]", quote) + 1
              == regexpr("\\[\\/QUOTE\\]", quote, ignore.case=TRUE) ) {
    quote = "";
  } else if ( regexpr("\\[QUOTE\\=\\w+\\;\\d+\\]", quote, ignore.case=TRUE) == 1) {
    id = substr(quote,
                regexpr("\\;", quote, ignore.case=TRUE)+1,
                regexpr("\\]", quote, ignore.case=TRUE)-1);
    userid = post[post$importpostid==as.numeric(id),c("userid")];
    if (length(userid) == 0) {
      userid = post[post$postid==as.numeric(id),c("userid")];
      if (length(userid) > 1) {
        quote = userid;
      };
    } else {
      quote = userid;
    };
  } else if ( regexpr("(\\[quote author\\=\\w+ link\\=topic\\=\\d+\\.)(msg\\d+)\\#\\2 date\\=\\d+\\]", 
                      quote, ignore.case=TRUE) == 1 ) {
    id = substr(quote,
                regexpr("msg", quote, ignore.case=TRUE)+3,
                regexpr("\\#", quote, ignore.case=TRUE)-1);
    userid = post[post$importpostid==as.numeric(id),c("userid")];
    if (length(userid) == 0) {
      userid = post[post$postid==as.numeric(id),c("userid")];
      if (length(userid) > 1) {
        quote = userid;
      };
    } else {
      quote = userid;
    };
  };
  if (length(quote)>1 && regexpr("\\[QUOTE\\]\\[\\/QUOTE\\]", quote, ignore.case=TRUE) == 1) {
    quote = "";
  };
}

callback <- function(x, post) {
  result = '';
  while (regexpr("\\[QUOTE", x, ignore.case=TRUE) > 0) {
    metaStart = regexpr("\\[QUOTE", x, ignore.case=TRUE);
    x = substring(x, metaStart);
    quote = substr(x, 1, 1);
    x = substring(x, 2)
    depth = 1;
    while (regexpr("\\[QUOTE", x, ignore.case=TRUE) > 0
           && regexpr("\\[QUOTE", x, ignore.case=TRUE) < regexpr("\\[\\/QUOTE\\]", x, ignore.case=TRUE)) {
      metaStart = regexpr("\\[QUOTE", x, ignore.case=TRUE);
      quote = paste(quote, substr(x, 1, metaStart), sep="");
      x = substring(x, metaStart+1);
      depth = depth + 1;
    };
    while (regexpr("\\[\\/QUOTE\\]", x, ignore.case=TRUE) > 0) {
      metaEnd = regexpr("\\[\\/QUOTE\\]", x, ignore.case=TRUE);
      quote = paste(quote, substr(x, 1, metaEnd+7), sep="");
      x = substring(x, metaEnd+8);
      depth = depth - 1;
    };
    if (depth != 0) {
      quote = dealQuote(quote, post);
    }
    result = paste(result, quote, sep="");
  };
  result;
};


table_quote$quote <- sapply(table_quote$pagetext, callback, table_post);

test$quote <- sapply(test$pagetext, callback, table_post);

tmp <- quote[quote$quote!="NA",];
tmp2 <- tmp[grepl("^\\d+$", tmp$quote),];


regexpr("\\[QUOTE\\=\\w+\\;\\d+\\]", "[QUOTE=W4nt3D;381371]Ich habe bei mir ganz in der nähe ne PS. Ist es ein Problem wenn ich immer auf diese die Pakete kommen lasse heißt, soll ich auch andere PS nehmen oder ist es kein problem? Was ist wenn man bei der Tat erwischt wird? Welche Strafen lauern einem?[/QUOTE]
", ignore.case=TRUE);

# 
# new_quote <- quote[quote$quote!="",c(1,2,3)];
# 
# 

quote[quote$dateline=="1255019446",]
post[post$importpostid==22136,]

test <- quote[c(1:10),];

tmp <- quote[regexpr("Sry auf Grund von Threads wie, &quot;Kann man cardetes Handy selbst usen&quot; oder &quot;Kann man auf eigene Adresse carden&quot; musste ich diesen Thread mal los werden, weil es ja immer wieder so ne speziallisten gibt die meinen das man es ja im prinzip könnte. Im Prinzip könnte man alles, man kann es aber auch lassen.",
      quote$pagetext, fixed=TRUE)>0,]
ind <- post[regexpr("NA", post$userid),];
# tmp <- quote[ind,];
# a <- c(1,2,3);
# a[c(TRUE, FALSE, TRUE)];
# 
# result <- callback("[quote][/quote]");
# regexpr("\\]", "[quote][/quote]") + 1 ==
# regexpr("\\[\\/QUOTE\\]", "[quote][/quote]", ignore.case=TRUE)
# 
