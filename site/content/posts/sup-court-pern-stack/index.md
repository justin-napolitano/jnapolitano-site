+++
title =  "PERN Stack with GraphQl and Apollo"
description = "Build a Website Backend with Apollo and Graphql" 
tags = ['javascript', "pern","databases"]
images = ["images/feature-image.png"]
date = "2024-08-02T15:16:27-05:00"
categories = ["projects"]
series = ["Java"]
[extra]
lang = "en"
toc = true
comment = false
copy = true
outdate_alert = true
outdate_alert_days = 120
math = false
mermaid = false
featured = false
reaction = false
+++


# Setting Up a PERN Stack with GraphQL and Apollo: 


Source Repo : ```https://github.com/justin-napolitano/sup-court-pern-stack.git```


I've been playing with a knowledge graph recently. Most of the data modelling is complete... well at least the groundwork is done.  

In this part of the series,we'll walk through the process of setting up a PostgreSQL, Express, React, Node.js (PERN) stack application with GraphQL and Apollo. 

The point is to build out a backend so I can then build out a react client to explore the beautiful grapth. 


## Prerequisites


Before we begin, make sure you have the following installed:

Node.js
PostgreSQL
npm or yarn
Step 1: Project Setup
Initialize the project:

```bash

mkdir my-pern-app
cd my-pern-app
npm init -y

```
### Install dependencies:


```bash

npm install express sequelize pg pg-hstore apollo-server-express graphql graphql-iso-date dotenv cors morgan bcrypt dataloader

```

### Step 2: Configure Environment Variables

Create a .env file in the root of your project with the following content:

```text

DATABASE_URL=postgres://example:example@localhost:5432/supreme_court
SECRET=asdlplplfwfwefwekwself.2342.dawasdq
PORT=8000
NODE_ENV=development

```

### Step 3: Set Up Sequelize

Create a config directory with the following files:

#### src/config/db.js

```javascript

import dotenv from 'dotenv';

dotenv.config();

const dbConfig = {
  development: {
    url: process.env.DATABASE_URL,
    dialect: 'postgres',
    logging: console.log, // Ensure logging is either a function or false
  },
  test: {
    url: process.env.TEST_DATABASE_URL,
    dialect: 'postgres',
    logging: false,
  },
  production: {
    url: process.env.DATABASE_URL,
    dialect: 'postgres',
    logging: false,
    dialectOptions: {
      ssl: {
        require: true,
        rejectUnauthorized: false,
      },
    },
  },
};

const environment = process.env.NODE_ENV || 'development';

export default dbConfig[environment];

```

### Step 4: Create Models

Create a models directory with the following files:

#### src/models/index.js

```javascript

import { Sequelize, Op } from 'sequelize';
import config from '../config';

const sequelize = new Sequelize(config.databaseUrl, {
  dialect: 'postgres',
  logging: config.nodeEnv === 'development',
  dialectOptions: {
    ssl: config.nodeEnv === 'production' ? { rejectUnauthorized: false } : false,
  },
  operatorsAliases: {
    $eq: Op.eq,
    $ne: Op.ne,
    $gte: Op.gte,
    $gt: Op.gt,
    $lte: Op.lte,
    $lt: Op.lt,
    $not: Op.not,
    $in: Op.in,
    $notIn: Op.notIn,
    $is: Op.is,
    $like: Op.like,
    $notLike: Op.notLike,
    $iLike: Op.iLike,
    $notILike: Op.notILike,
    $regexp: Op.regexp,
    $notRegexp: Op.notRegexp,
    $iRegexp: Op.iRegexp,
    $notIRegexp: Op.notIRegexp,
    $between: Op.between,
    $notBetween: Op.notBetween,
    $overlap: Op.overlap,
    $contains: Op.contains,
    $contained: Op.contained,
    $adjacent: Op.adjacent,
    $strictLeft: Op.strictLeft,
    $strictRight: Op.strictRight,
    $noExtendRight: Op.noExtendRight,
    $noExtendLeft: Op.noExtendLeft,
    $and: Op.and,
    $or: Op.or,
    $any: Op.any,
    $all: Op.all,
    $values: Op.values,
    $col: Op.col,
  },
});

const models = {
  User: sequelize.import('./user'),
  Message: sequelize.import('./message'),
};

Object.keys(models).forEach(key => {
  if ('associate' in models[key]) {
    models[key].associate(models);
  }
});

export { sequelize };

export default models;

```
#### src/models/user.js

```javascript

import bcrypt from 'bcrypt';

const user = (sequelize, DataTypes) => {
  const User = sequelize.define('user', {
    username: {
      type: DataTypes.STRING,
      unique: true,
      allowNull: false,
      validate: {
        notEmpty: true,
      },
    },
    email: {
      type: DataTypes.STRING,
      unique: true,
      allowNull: false,
      validate: {
        notEmpty: true,
        isEmail: true,
      },
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        notEmpty: true,
        len: [7, 42],
      },
    },
    role: {
      type: DataTypes.STRING,
    },
  });

  User.associate = models => {
    User.hasMany(models.Message, { onDelete: 'CASCADE' });
  };

  User.findByLogin = async login => {
    let user = await User.findOne({
      where: { username: login },
    });

    if (!user) {
      user = await User.findOne({
        where: { email: login },
      });
    }

    return user;
  };

  User.beforeCreate(async user => {
    user.password = await user.generatePasswordHash();
  });

  User.prototype.generatePasswordHash = async function() {
    const saltRounds = 10;
    return await bcrypt.hash(this.password, saltRounds);
  };

  User.prototype.validatePassword = async function(password) {
    return await bcrypt.compare(password, this.password);
  };

  return User;
};

export default user;
```


#### src/models/message.js

```javascript

const message = (sequelize, DataTypes) => {
  const Message = sequelize.define('message', {
    text: {
      type: DataTypes.STRING,
      validate: { notEmpty: true },
    },
  });

  Message.associate = models => {
    Message.belongsTo(models.User);
  };

  return Message;
};

export default message;
Step 5: Set Up GraphQL Schema and Resolvers
Create a schema directory with the following files:

#### src/schema/index.js
javascript

import { gql } from 'apollo-server-express';

import userSchema from './user';
import messageSchema from './message';

const linkSchema = gql`
  scalar Date

  type Query {
    _: Boolean
  }

  type Mutation {
    _: Boolean
  }

  type Subscription {
    _: Boolean
  }
`;

export default [linkSchema, userSchema, messageSchema];
```

#### src/schema/user.js

```javascript

import { gql } from 'apollo-server-express';

export default gql`
  extend type Query {
    users: [User!]
    user(id: ID!): User
    me: User
  }

  extend type Mutation {
    signUp(
      username: String!
      email: String!
      password: String!
    ): Token!

    signIn(login: String!, password: String!): Token!
    updateUser(username: String!): User!
    deleteUser(id: ID!): Boolean!
  }

  type Token {
    token: String!
  }

  type User {
    id: ID!
    username: String!
    email: String!
    role: String
    messages: [Message!]
  }
`;

```

#### src/schema/message.js

```javascript

import { gql } from 'apollo-server-express';

export default gql`
  extend type Query {
    messages(cursor: String, limit: Int): MessageConnection!
    message(id: ID!): Message!
  }

  extend type Mutation {
    createMessage(text: String!): Message!
    deleteMessage(id: ID!): Boolean!
  }

  type MessageConnection {
    edges: [Message!]!
    pageInfo: PageInfo!
  }

  type PageInfo {
    hasNextPage: Boolean!
    endCursor: String!
  }

  type Message {
    id: ID!
    text: String!
    createdAt: Date!
    user: User!
  }

  extend type Subscription {
    messageCreated: MessageCreated!
  }

  type MessageCreated {
    message: Message!
  }
`;
Create a resolvers directory with the following files:
```

#### src/resolvers/index.js

```javascript

import { GraphQLDateTime } from 'graphql-iso-date';

import userResolvers from './user';
import messageResolvers from './message';

const customScalarResolver = {
  Date: GraphQLDateTime,
};

export default [
  customScalarResolver,
  userResolvers,
  messageResolvers,
];

```

#### src/resolvers/user.js

```javascript

import jwt from 'jsonwebtoken';
import { combineResolvers } from 'graphql-resolvers';
import { AuthenticationError, UserInputError } from 'apollo-server';
import { isAdmin, isAuthenticated } from './authorization';
import { createToken } from '../utils/auth';

export default {
  Query: {
    users: async (parent, args, { models }) => {
      return await models.User.findAll();
    },
    user: async (parent, { id }, { models }) => {
      return await models.User.findByPk(id);
    },
    me: async (parent, args, { models, me }) => {
      if (!me) {
        return null;
      }

      return await models.User.findByPk(me.id);
    },
  },

  Mutation: {
    signUp: async (parent, { username, email, password }, { models, secret }) => {
      const user = await models.User.create({
        username,
        email,
        password,
      });

      return { token: createToken(user, secret, '30m') };
    },

    signIn: async (parent, { login, password }, { models, secret }) => {
      const user = await models.User.findByLogin(login);

      if (!user) {
        throw new UserInputError('No user found with these login credentials.');
      }

      const isValid = await user.validatePassword(password);

      if (!isValid) {
        throw new AuthenticationError('Invalid password.');
      }

      return { token: createToken(user, secret, '30m') };
    },

    updateUser: combineResolvers(
      isAuthenticated,
      async (parent, { username }, { models, me }) => {
        const user = await models.User.findByPk(me.id);
        return await user.update({ username });
      },
    ),

    deleteUser: combineResolvers(
      isAdmin,
      async (parent, { id }, { models }) => {
        return await models.User.destroy({
          where: { id },
        });
      },
    ),
  },

  User: {
    messages: async (user, args, { models }) => {
      return await models.Message.findAll({
        where: {
          userId: user.id,
        },
      });
    },
  },
};
```

#### src/resolvers/message.js

```javascript

import { PubSub } from 'apollo-server';
import { combineResolvers } from 'graphql-resolvers';
import { isAuthenticated, isMessageOwner } from './authorization';

const pubsub = new PubSub();

const MESSAGE_CREATED = 'MESSAGE_CREATED';

export default {
  Query: {
    messages: async (parent, { cursor, limit = 100 }, { models }) => {
      const cursorOptions = cursor
        ? {
            where: {
              createdAt: {
                [models.Sequelize.Op.lt]: cursor,
              },
            },
          }
        : {};

      const messages = await models.Message.findAll({
        order: [['createdAt', 'DESC']],
        limit: limit + 1,
        ...cursorOptions,
      });

      const hasNextPage = messages.length > limit;
      const edges = hasNextPage ? messages.slice(0, -1) : messages;

      return {
        edges,
        pageInfo: {
          hasNextPage,
          endCursor: edges[edges.length - 1].createdAt,
        },
      };
    },
    message: async (parent, { id }, { models }) => {
      return await models.Message.findByPk(id);
    },
  },

  Mutation: {
    createMessage: combineResolvers(
      isAuthenticated,
      async (parent, { text }, { me, models }) => {
        const message = await models.Message.create({
          text,
          userId: me.id,
        });

        pubsub.publish(MESSAGE_CREATED, {
          messageCreated: { message },
        });

        return message;
      },
    ),
    deleteMessage: combineResolvers(
      isAuthenticated,
      isMessageOwner,
      async (parent, { id }, { models }) => {
        const message = await models.Message.findByPk(id);

        if (!message) {
          throw new Error('Message not found');
        }

        await message.destroy();
        return true;
      },
    ),
  },

  Subscription: {
    messageCreated: {
      subscribe: () => pubsub.asyncIterator(MESSAGE_CREATED),
    },
  },

  Message: {
    user: async (message, args, { models }) => {
      return await models.User.findByPk(message.userId);
    },
  },
};

```

#### src/resolvers/authorization.js

```javascript

import { ForbiddenError } from 'apollo-server';
import { combineResolvers, skip } from 'graphql-resolvers';

export const isAuthenticated = (parent, args, { me }) =>
  me ? skip : new ForbiddenError('Not authenticated as user.');

export const isAdmin = combineResolvers(
  isAuthenticated,
  (parent, args, { me: { role } }) =>
    role === 'ADMIN'
      ? skip
      : new ForbiddenError('Not authorized as admin.'),
);

export const isMessageOwner = async (
  parent,
  { id },
  { models, me },
) => {
  const message = await models.Message.findByPk(id, { raw: true });

  if (message.userId !== me.id) {
    throw new ForbiddenError('Not authenticated as owner.');
  }

  return skip;
};

```

### Step 6: Configure Loaders

Create a loaders directory with the following files:

#### src/loaders/user.js

```javascript

export const batchUsers = async (keys, models) => {
  const users = await models.User.findAll({
    where: {
      id: {
        [models.Sequelize.Op.in]: keys,
      },
    },
  });

  return keys.map(key => users.find(user => user.id === key));
};

```



#### src/loaders/index.js


```javascript

import DataLoader from 'dataloader';
import models from '../models';
import { batchUsers } from './user';

const loaders = {
  user: new DataLoader(keys => batchUsers(keys, models)),
};

export default loaders;
Step 7: Set Up Apollo Server
Create a server.js file in the src directory:
```

#### src/server.js

```javascript

import { ApolloServer, AuthenticationError } from 'apollo-server-express';
import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import http from 'http';
import schema from './schema';
import resolvers from './resolvers';
import models, { sequelize } from './models';
import loaders from './loaders';
import config from './config';
import { verifyToken } from './utils/auth';
import logger from './config/logger';

const app = express();

app.use(cors());
app.use(morgan('dev'));

const getMe = async (req) => {
  const token = req.headers['x-token'];
  if (token) {
    try {
      return verifyToken(token);
    } catch (error) {
      throw new AuthenticationError('Session expired, please login again');
    }
  }
};

const server = new ApolloServer({
  introspection: true,
  playground: true,
  typeDefs: schema,
  resolvers,
  formatError: (error) => {
    const message = error.message.replace('SequelizeValidationError: ', '').replace('Validation error: ', '');
    return {
      ...error,
      message,
    };
  },
  context: async ({ req, connection }) => {
    if (connection) {
      return {
        models,
        loaders,
      };
    }

    if (req) {
      const me = await getMe(req);
      return {
        models,
        me,
        secret: config.secret,
        loaders,
      };
    }
  },
});

server.applyMiddleware({ app, path: '/graphql' });

const httpServer = http.createServer(app);
server.installSubscriptionHandlers(httpServer);

sequelize.authenticate().then(() => {
  logger.info('Database connected successfully');
  return sequelize.sync();
}).then(() => {
  httpServer.listen(config.port, () => {
    logger.info(`Server running at http://localhost:${config.port}/graphql`);
  });
}).catch((error) => {
  logger.error('Unable to connect to the database:', error);
});

```

### Create an index.js file in the src directory:

#### src/index.js

```javascript

import 'dotenv/config';
import './server';

```


### Step 8: Start the Server

To start the server, use the following command:

```bash

npx nodemon src/index.js

```


Your server should now be running, and you can access the Apollo GraphQL playground at http://localhost:8000/graphql.

