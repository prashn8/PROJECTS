-- Create Users table
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    user_name VARCHAR(50) NOT NULL UNIQUE,
    full_name VARCHAR(100),
    bio TEXT,
    join_date DATE NOT NULL DEFAULT CURRENT_DATE
);

-- Create Posts table
CREATE TABLE Posts (
    post_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    caption TEXT,
    post_date DATE NOT NULL DEFAULT CURRENT_DATE,
    num_likes INT DEFAULT 0,
    num_comments INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Create Likes table
CREATE TABLE Likes (
    like_id SERIAL PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    like_date DATE NOT NULL DEFAULT CURRENT_DATE,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Create Comments table
CREATE TABLE Comments (
    comment_id SERIAL PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    comment_text TEXT,
    comment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Create indexes to improve query performance
CREATE INDEX idx_users_user_name ON Users(user_name);
CREATE INDEX idx_posts_user_id ON Posts(user_id);
CREATE INDEX idx_likes_post_id ON Likes(post_id);
CREATE INDEX idx_comments_post_id ON Comments(post_id);

-- Insert sample data into Users table
INSERT INTO Users (user_name, full_name, bio, join_date) VALUES
('viratkohli18', 'Virat Kohli', 'Fitness Freak.', '2023-01-15'),
('rohit45', 'Rohit Sharma', '19-nov-2023 :(', '2023-02-20'),
('bowler_no1', 'Jasprit Bumrah', 'Fast Bowler academy.', '2023-03-05');

-- Insert sample data into Posts table
INSERT INTO Posts (user_id, caption, post_date) VALUES
(1, 'Hello, world!', '2023-04-01'),
(2, 'Beautiful sunset!', '2023-04-02'),
(3, 'Exploring the mountains.', '2023-04-03');

-- Insert sample data into Likes table
INSERT INTO Likes (post_id, user_id, like_date) VALUES
(1, 2, '2023-04-01'),
(1, 3, '2023-04-01'),
(2, 1, '2023-04-02');

-- Insert sample data into Comments table
INSERT INTO Comments (post_id, user_id, comment_text, comment_date) VALUES
(1, 2, 'Nice post!', '2023-04-01'),
(1, 3, 'Welcome to Instagram!', '2023-04-01'),
(2, 1, 'Amazing view!', '2023-04-02');

-- Query to get all posts with their respective number of likes and comments
SELECT p.post_id, p.caption, p.post_date, 
       (SELECT COUNT(*) FROM Likes WHERE post_id = p.post_id) AS num_likes,
       (SELECT COUNT(*) FROM Comments WHERE post_id = p.post_id) AS num_comments
FROM Posts p;

-- Query to get the most liked post
SELECT p.post_id, p.caption, COUNT(l.like_id) AS num_likes
FROM Posts p
JOIN Likes l ON p.post_id = l.post_id
GROUP BY p.post_id
ORDER BY num_likes DESC
LIMIT 1;

-- Query to get the number of posts each user has made
SELECT u.user_id, u.full_name, u.user_name, COUNT(p.post_id) AS num_posts
FROM Users u
LEFT JOIN Posts p ON u.user_id = p.user_id
GROUP BY u.user_id;

-- Query to get the number of comments each user has made
SELECT u.user_id, u.full_name, u.user_name, COUNT(c.comment_id) AS num_comments
FROM Users u
LEFT JOIN Comments c ON u.user_id = c.user_id
GROUP BY u.user_id;

-- Query that retrieves all users along with their full name, user name, bio, and their respective posts.
SELECT
    u.full_name,
    u.user_name,
    u.bio,
    p.caption AS post_caption,
    p.post_date
FROM
    Users u
LEFT JOIN
    Posts p ON u.user_id = p.user_id;

-- Query to retrieve full_name, user_name, bio, and their posts
SELECT
    u.full_name,
    u.user_name,
    u.bio,
    COALESCE(p.caption, 'No posts yet') AS post_caption,
    COALESCE(p.post_date, 'N/A') AS post_date
FROM
    Users u
LEFT JOIN
    Posts p ON u.user_id = p.user_id;

-- Query to retrieve full_name, user_name, bio of users who haven't posted anything yet
SELECT
    u.full_name,
    u.user_name,
    u.bio,
    'No posts yet' AS post_caption,
    NULL AS post_date
FROM
    Users u
LEFT JOIN
    Posts p ON u.user_id = p.user_id
WHERE
    p.post_id IS NULL;

-- Advanced Query: Using CTEs to get the top 3 most active users by number of posts and comments
WITH UserActivity AS (
    SELECT u.user_id, u.full_name, u.user_name, 
           COUNT(DISTINCT p.post_id) AS num_posts, 
           COUNT(DISTINCT c.comment_id) AS num_comments
    FROM Users u
    LEFT JOIN Posts p ON u.user_id = p.user_id
    LEFT JOIN Comments c ON u.user_id = c.user_id
    GROUP BY u.user_id
)
SELECT user_id, full_name, user_name, num_posts, num_comments, 
       (num_posts + num_comments) AS total_activity
FROM UserActivity
ORDER BY total_activity DESC
LIMIT 3;


