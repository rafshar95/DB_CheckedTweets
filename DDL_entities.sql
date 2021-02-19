DROP DATABASE IF EXISTS CheckedTweets;
CREATE DATABASE CheckedTweets;
USE CheckedTweets;

CREATE TABLE User(
	user_id Integer auto_increment,
	name_first VARCHAR(20) NOT NULL,
    name_last VARCHAR(20) NOT NULL,
    email VARCHAR(40) NOT NULL UNIQUE,
    password VARCHAR(40) NOT NULL,
    user_since DATETIME NOT NULL,
    profile_pic_url VARCHAR(300),
    address_country VARCHAR(20) NOT NULL,
    address_state VARCHAR(20),
    address_city VARCHAR(20) NOT NULL,
    PRIMARY KEY(user_id)
);

CREATE TABLE Checker(
	user_id Integer NOT NULL,
	checker_since DATETIME NOT NULL,
	PRIMARY KEY(user_id),
	FOREIGN KEY(user_id) REFERENCES User(user_id) ON DELETE CASCADE
);
CREATE TABLE Checker_phones(
	user_id Integer,
    phone_number VARCHAR(20),
    phone_type ENUM('HOME', 'OFFICE', 'MOBILE'),
    PRIMARY KEY (user_id, phone_number),
    FOREIGN KEY (user_id) REFERENCES Checker(User_id) ON DELETE CASCADE
);
CREATE TABLE Checker_expertises(
	user_id Integer,
    expertise VARCHAR(20) NOT NULL,
    PRIMARY KEY (user_id, expertise),
    FOREIGN KEY (user_id) REFERENCES Checker(User_id) ON DELETE CASCADE
);
CREATE TABLE Evidence(
	ev_id Integer auto_increment,
    url VARCHAR(100) NOT NULL,
    PRIMARY KEY(ev_id)
);

CREATE TABLE RawTweet(
	tweet_id VARCHAR(20),
	content JSON NOT NULL,
	PRIMARY KEY(tweet_id)
);

CREATE TABLE Tweeter(
	tweeter_id VARCHAR(20),
    followers_count INTEGER NOT NULL,
    handle VARCHAR(50) NOT NULL,
    verified BOOL NOT NULL,
    display_name VARCHAR(40),
    PRIMARY KEY(tweeter_id)
);

CREATE TABLE Tweet(
	tweet_id VARCHAR(20),
    posted_by VARCHAR(20) NOT NULL,
    posting_datetime DATETIME NOT NULL,
    posting_location_longitude DECIMAL(10,8),
    posting_location_latitude DECIMAL(10,8),
    replied_to_tweet VARCHAR(20),
    quoted_tweet VARCHAR(20),
	tweet_text VARCHAR(250),
    PRIMARY KEY (tweet_id),
    FOREIGN KEY (posted_by) REFERENCES Tweeter (tweeter_id) ON DELETE CASCADE,
	FOREIGN KEY(replied_to_tweet) REFERENCES  Tweet (tweet_id) ON DELETE SET NULL,
    FOREIGN KEY(quoted_tweet) REFERENCES Tweet (tweet_id) ON DELETE SET NULL,
    FOREIGN KEY (tweet_id) REFERENCES RawTweet (tweet_id) ON DELETE CASCADE
);
CREATE TABLE Verification(
	ver_id Integer auto_increment,
    verification_by INTEGER NOT NULL,
    verification_of VARCHAR(20) NOT NULL,
    comment VARCHAR(250),
    Verified_on DATETIME NOT NULL,
    FOREIGN KEY (verification_by) REFERENCES Checker(user_id),
    FOREIGN KEY (verification_of) REFERENCES Tweet(tweet_id),
    PRIMARY KEY(ver_id)
);


CREATE TABLE Tweet_hashtags(
	tweet_id VARCHAR(20),
	hashtag VARCHAR(20) NOT NULL,
    FOREIGN KEY (tweet_id) REFERENCES Tweet(tweet_id) on DELETE CASCADE,
	PRIMARY KEY(tweet_id, hashtag)
);



