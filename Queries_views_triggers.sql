/*
Query 1: Return the handles of Tweeters and their number of Covid-tagged tweets if they’ve used the hashtag “covid19” more than 3 times. Your query should normalize the hashtags to lowercase (e.g., Covid19 should be converted to covid19 in order to properly consider all Covid-tagged tweets.
*/

SELECT Tr.handle, count(*) AS cnt
FROM Tweeter Tr, Tweet T, Hashtags Ht
WHERE Tr.tweeter_id = T.tweeter_id AND T.tweet_id = Ht.tweet_id
AND LOWER(Ht.hashtag)='covid19'
GROUP BY Tr.handle
having count(*)>3;

/*
Query 2:Return the handles of Tweeters who have a followers count greater than 500,000 and who have posted a tweet that contains one or more of the top ten most popular hashtags. (Note: You can break popularity ties arbitrarily.)
*/

WITH TrendingTags AS (SELECT Ht.hashtag
					 FROM Hashtags Ht
                     GROUP BY Ht.hashtag
                     ORDER BY count(*) DESC
                     LIMIT 10)
	SELECT DISTINCT Tr.handle 
    FROM TrendingTags TT, Tweeter Tr, Hashtags Ht, Tweet T
    WHERE Tr.followers_count > 500000 
    AND T.tweeter_id= Tr.tweeter_id
    AND T.tweet_id=Ht.tweet_id
    AND Ht.hashtag=TT.hashtag;
    
/*
Query 3: Find the tweet ids for tweets that have been verified using at least two different pieces of evidence and that have a popularity greater than 2.4. Remember that the popularity of a tweet can be computed using the formula:

Popularity=0.4 (Number of quotes)+0.6 (Number of replies)
    
*/

WITH VerifiedTweets AS (SELECT T.tweet_id
FROM Tweet T, Verification V, VerifiedUsing VU
WHERE T.tweet_id=V.tweet_id AND VU.ver_id=V.ver_id
GROUP BY T.tweet_id
Having count(*) >= 2), 
PopularTweets AS (SELECT T2.tweet_id, (
SELECT count(*) FROM Tweet T4 WHERE T4.quoted_tweet=T2.tweet_id) AS qt_cnt, 
 (SELECT count(*) FROM Tweet T3 WHERE T3.replied_to_tweet=T2.tweet_id) AS rep_cnt
FROM Tweet T2
WHERE  0.4 * (SELECT count(*) FROM Tweet T4 WHERE T4.quoted_tweet=T2.tweet_id) + 
 0.6 * (SELECT count(*) FROM Tweet T3 WHERE T3.replied_to_tweet=T2.tweet_id) > 2.4 
ORDER BY 0.4 * qt_cnt+ 0.6 * rep_cnt)

SELECT VT.tweet_id FROM VerifiedTweets VT , PopularTweets PT
WHERE VT.tweet_id = PT.tweet_id;

/*
View 4:Congratulations! For obvious reasons, the CTO of CheckedTweets.org is setting up a data science team to analyze election tweets that contain one or more of the following hashtags: "election2020", "trump", "biden", "bidenharris2020", "trumppence2020", "pennsylvania", "northcarolina", "wisconsin", "michigan".  (You will need to normalize the hashtags to lowercase.)  The CTO has made you the head of that team. As the team leader, you have been asked to create a SQL view so that the rest of the team can simply look at the data and draw meaningful conclusions without having to deal with all of its underlying complexity.
The view should provide simple tabular access to a combination of the following pieces of information:
•	Tweeter info (tweeter_id, handle, followers_count, verified)
•	Tweet info (tweet_id, tweet_text, popularity, quality)

Remember that tweet popularity and quality are derived attributes and can be computed as follows:
Popularity=0.4 (Number of quotes)+0.6 (Number of replies)
Quality=Amount of associated evidence used for verification


part(a):
*/

CREATE VIEW ElectionTweets(tweeter_id, handle, followers_count, verified, tweet_id, tweet_text, popularity, quality) AS
SELECT DISTINCT Tr.tweeter_id, Tr.handle, Tr.followers_count, Tr.verified, T.tweet_id, T.tweet_text,
 (0.4 * (SELECT count(*) FROM Tweet T4 WHERE T4.quoted_tweet=T.tweet_id) 
 + 0.6 * (SELECT count(*) FROM Tweet T3 WHERE T3.replied_to_tweet=T.tweet_id)),
 (SELECT count(*) FROM Verification V, VerifiedUsing VU WHERE V.ver_id=VU.ver_id AND T.tweet_id=V.tweet_id)
FROM Tweet T, Tweeter Tr, Hashtags Ht
WHERE T.tweeter_id=Tr.tweeter_id AND Ht.tweet_id = T.tweet_id
AND LOWER(Ht.hashtag) IN ('election2020','trump','biden','bidenharris2020','trumppence2020','pennsylvania','northcarolina','wisconsin','michigan');
SELECT count(*) FROM ElectionTweets;

/*
part(b):
*/

SELECT ET.tweet_id, ET.handle, ET.popularity, ET.quality
FROM ElectionTweets ET
WHERE ET.popularity = (SELECT Max(ET2.popularity) FROM ElectionTweets ET2);

/*
Store Procedure 5: Create and exercise a SQL stored procedure called RegisterChecker(…) that the application can use to add a brand new checker with an office phone to the database. You may not change the signature of this procedure. Hint: To get the current time, use the NOW() function. 
*/

DELIMITER //
CREATE PROCEDURE RegisterChecker(
    user_id integer,
    name_first varchar(50),
    name_last varchar(50), 
    email varchar(100),
    password varchar(30),
    profile_pic varchar(500),
    address_country varchar(30),
    address_state varchar(30),
    address_city varchar(30),
    office_number varchar(20)
)
BEGIN
	SET @user_since = NOW();
    INSERT INTO User(user_id, name_first, name_last, email, password, user_since, profile_pic, address_country, address_state, address_City)
    VALUES(user_id, name_first, name_last, email, password, @user_since, profile_pic, address_country, address_state, address_city);
    INSERT INTO Checker(user_id, checker_since)
    VALUES(user_id, @user_since);
    INSERT INTO Phone(user_id, kind, number)
    VALUES(user_id, 'Office', office_number);
END;  //
DELIMITER ;

/*
Alter Table 6: As your schema currently stands, evidence can only be submitted in the form of URLs to websites. Your boss would like to enrich the Evidence entity by also allowing books (specifically, 13-character ISBNs) to be used as evidence. This changes your ER model in two ways: 1) URL now becomes an optional field in Evidence, and 2) ISBN is now an additional optional field in Evidence.
Note: The current datatype for URL is VARCHAR(500). 

Write and execute the ALTER TABLE statement(s) needed to modify the Evidence table to reflect the new requirements above. (Hint: Refer to the MySQL documentation online if you need more information about how to use the ALTER TABLE statement.)

*/

ALTER TABLE Evidence MODIFY url varchar(500),
					 ADD isbn varchar(13);
/*
Trigger 7:
*/

DELIMITER $$

CREATE TRIGGER update_tweet_info
AFTER INSERT ON RawTweet FOR EACH ROW
BEGIN
	INSERT INTO Tweeter(display_name, followers_count, handle, tweeter_id, verified)
    VALUES(
	JSON_UNQUOTE(JSON_EXTRACT(NEW.content, '$.user.screen_name')),
    JSON_UNQUOTE(JSON_EXTRACT(NEW.content, '$.user.followers_count')),
    JSON_UNQUOTE(JSON_EXTRACT(NEW.content, '$.user.name')),
    JSON_UNQUOTE(JSON_EXTRACT(NEW.content, '$.user.id_str')),
    CASE WHEN JSON_EXTRACT(NEW.content, '$.user.verified') THEN 1 ELSE 0 END)
    ON DUPLICATE KEY UPDATE
	display_name=JSON_UNQUOTE(JSON_EXTRACT(NEW.content, '$.user.screen_name')),
    followers_count=JSON_UNQUOTE(JSON_EXTRACT(NEW.content, '$.user.followers_count')),
	handle=JSON_UNQUOTE(JSON_EXTRACT(NEW.content, '$.user.name'));
    INSERT INTO Tweet(posting_datetime, posting_location_longitude, posting_location_latitude, quoted_tweet, replied_to_tweet, tweet_id, tweet_text, tweeter_id)
    VALUES(
    JSON_UNQUOTE(JSON_EXTRACT(NEW.content, '$.created_at')),
    JSON_EXTRACT(NEW.content, '$.geo.coordinates[0]'),
    JSON_EXTRACT(NEW.content, '$.geo.coordinates[1]'),
    JSON_EXTRACT(NEW.content, '$.quoted_status_id'),
    JSON_EXTRACT(NEW.content, '$.in_reply_to_status_id'),
    JSON_UNQUOTE(JSON_EXTRACT(NEW.content, '$.id')),
    JSON_UNQUOTE(JSON_EXTRACT(NEW.content, '$.text')),
    JSON_UNQUOTE(JSON_EXTRACT(NEW.content, '$.user.id_str')));


    
    CALL UpdateHashtags(tweet_id);
END;
$$

DELIMITER ;
                     