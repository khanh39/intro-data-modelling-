# Intro to Data Modelling

This assignment will give you the opportunity to practice
  * designing models for a variety of app concepts
  * determining the relationships between those models
  * designing a database structure to support those relationships
    - placing foreign keys
    - creating join tables
  * writing ActiveRecord migrations to generate those database schemas and ActiveRecord models
  * writing ActiveRecord association code to implement those relationships

First this guide will walk you through a few examples of the data modelling process (please feel free to code along).  Then it will present you with [a collection of simple app concepts for you to practice this data modelling process on](#now-its-your-turn).  The steps involved in this process are:
#### Step 1
Come up with a set of models and their attributes.

#### Step 2
Come up with the relationships that exist between these models.  Think in terms of 1-to-1, 1-to-many, and many-to-many relationships.

#### Step 3
Translate this into a database schema.

Each model should have a table and each attribute should correspond to a column in that table. Each table should also have a primary key (id) column, and potentially some foreign key columns to facilitate the relationships that exist between your tables.

#### Step 4
Generate ActiveRecord models and migrations to implement what you just planned out.

#### Step 5
Add associations (`belongs_to`, `has_many`, etc) to your models to inform them about the relationships that exist in your database schema.

## Step by Step Example: 1-to-Many

This example describes a simple blogging app that includes articles written by different authors.

#### Step 1:
Models:

![author_article.png.png](author_article.png)

#### Step 2:
One article is written by one author

One author writes many different articles

Therefore there is a 1-to-many relationship between them.

#### Step 3:
Database schema:

![articles_authors.png](articles_authors.png)

#### Step 4
`rails g model Author name:string bio:text`

This generates a model called `Author` and a migration to create an `authors` database table with a string column called `name` and a text column called `bio`.  By default you also always get an integer column called `id` (the "primary key"), as well as datetime columns called `created_at` and `updated_at`.

`rails g model Article title:string body:text date:date author_id:integer`

This generates a model called `Article` and a migration to create an `articles` database table with a string column called `title`, a text column called `body`, a date column called `date`, and an integer column called `author_id` (this is a foreign key).  Again, we don't have to specify the `id` column. It will get created for us without us having to ask.

#### Step 5
Anywhere you have a foreign key in your database you should add a `belongs_to` association to the corresponding model.  Because our `articles` table has a foreign key that refers to an author, our `Article` model should have a `belongs_to :author` association.

```ruby
class Article < ActiveRecord::Base
  belongs_to :author
end
```

The other side of this relationship gets a `has_many :articles`.  This lets the `Author` model know that the `articles` table has a foreign key that refers back to it.
```ruby
class Author < ActiveRecord::Base
  has_many :articles
end
```

## Step by Step Example: Many-to-Many
### Solution 1: Direct Many-to-Many (no model)
This example refers to an app that allows users to bookmark articles.

#### Step 1
![user_article.png](user_article.png)

#### Step 2
Each user bookmarks many different articles.

Each article is bookmarked by many different users.

Therefore there is a many-to-many relationship between them.

#### Step 3
We need to add a join table to record this many-to-many relationship.

![articles_users.png](articles_users.png)

#### Step 4
`rails g model User email:string username:string`

`rails g model Article title:string body:text date:date`

`rails g migration CreateArticlesUsers article_id:integer user_id:integer`

Since we don’t need a model to go with our join table we use the command `rails g migration` to make just a database migration and no model. `rails g model` creates both a migration and a model.  `CreateArticlesUsers` is the name of the migration we want to generate.  By convention, if you’re generating a migration that creates a new database table, you name it `Create`+ the name of the table, which is `articles_users` in our case.

#### Step 5
```ruby
class User < ActiveRecord::Base
  has_and_belongs_to_many :articles
end

class Article < ActiveRecord::Base
  has_and_belongs_to_many :users
end
```
`has_and_belongs_to_many` is the association you want to use to inform your models about a direct many-to-many relationship between them.  This tells the models about the join table that you put in your database.

### Solution 2: Many-to-Many Through a Model
We might decide that we want to know when a user bookmarked an article.  This is best solved by adding another column to the join table that we were going to create in the previous solution, thereby making it into a third `Bookmark` model that sits between `User` and `Article`.  `Bookmark` is still a join table between `User` and `Article`, but because it has columns other than foreign keys, it also gets its own model.

#### Step 1
*foreign keys and primary keys are excluded for consistency, but will be added in step 3*

![bookmark.png](bookmark.png)

#### Step 2
Each user has many bookmarks.

Each bookmark was made by a single user.

Therefore there is a 1-to-many relationship between bookmark and user.

---
Each article is bookmarked many times.

Each bookmark refers to one article.

Therefore there is a 1-to-many relationship between bookmark and article.

---
Each user saves many articles (by bookmarking them).

Each article is saved by many different users (through being bookmarked by them).

Therefore there is a many-to-many relationship between user and article, through bookmark.

#### Step 3
![bookmarks.png](bookmarks.png)

#### Step 4
`rails g model Article title:string body:text date:date`

`rails g model User email:string username:string`

`rails g model Bookmark date:date user_id:integer article_id:integer`

#### Step 5
```ruby
class Article < ActiveRecord::Base
  has_many :bookmarks
  has_many :users, through: :bookmarks
end

class Bookmark < ActiveRecord::Base
  belongs_to :user
  belongs_to :article
end

class User < ActiveRecord::Base
  has_many :bookmarks
  has_many :users, through: :bookmarks
end
```
Again, `Bookmark` has two `belongs_to` associations because of the two foreign keys in its database table.  The `has_many :bookmarks` associations in `User` and `Article` express the other sides of those 1-to-many relationships.

`has_many :users, through: :bookmarks` in the `Article` model expresses the many-to-many relationship between `User` and `Article`, from the article’s point of view.

`has_many :articles, through: :bookmarks` in the `User` model expresses that same relationship from the user’s point of view.


### General Hints

##### Placing foreign keys
For every 1-to-many relationship in your app you must place a foreign key on the “many side”.  For example:

Each author is associated with multiple articles. Each article is associated with one author.  The “many side” is article, and the `articles` table must have an `author_id` foreign key column.

This allows each article to keep track of who its author is.

##### Placing join tables
A join table is a table with two foreign key columns.  It “joins” together the tables/models that those two foreign keys refer to.  

For example:

Each playlist consists of many songs
Each song appears on many different playlists
Therefore there is a many-to-many relationship between these two things.

This means we need a join table between them to record their relationships.

playlists_songs
playlist_id
Song_id

Typically when you have a simple join table such as this one you don’t bother to create a model in your app to go with it.

However, sometimes you realize you need to record more information about a relationship than just the ids of the two things.  For example, maybe we want to be able to put the songs on our playlist in a specific order.  Now instead of just recording that song 20 is on playlist 8, we need to also record the fact that it should be the 2nd song in the playlist by adding an `order` column to our join table.

As soon as your join table has more than just the two foreign key columns you need to create a model to go with it.


##### Adding Associations to your Models
```
belongs_to ...
has_many ...
has_and_belongs_to_many ...
has_many ... through: ...
```

`belongs_to` and `has_many` are the associations you need for a 1-to-many relationship.  This will inform your models about the foreign key column that you added to your database to support that relationship.

`has_and_belongs_to_many` is the association you need for a direct many-to-many relationship with a simple join table (only foreign keys and no other columns).

`has_many through:` is the association you need for a "through" many-to-many relationship where the join table has a model to go with it.

### Now it's Your Turn
Your task is to complete steps 1-5 for each of the following app concepts.  Don't go crazy with models - you can keep each solution to 2-5 models for now.

1. For this first one we'll start you off with the models: ![customer_order.png](customer_order.png)

2. An app that lists what ingredients are needed for various recipes.

3. An app that allows doctors and patients to make appointments with each other.

4. An Eventbrite-inspired app that allows hosts to create events and guests to RSVP to them

5. Github! You can limit your solution to only worrying about repositories and users.

6. Twitter! You can limit your solution to only worrying about tweets and users.

7. An IMDB-inspired app that contains films, directors, and actors

