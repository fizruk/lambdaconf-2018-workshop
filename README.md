# lambdaconf-2018-workshop

[![Gitter chat](https://badges.gitter.im/lambdaconf-2018-workshop/Lobby.png)](https://gitter.im/lambdaconf-2018-workshop/Lobby)

LambdaConf 2018 workshop on building Telegram bots in Haskell.

![Stage 8 demo](images/stage_8_demo.gif)

## Preparing for the workshop

See [preparation instructions](PREPARE.md) to get ready for the workshop ahead of time!
It is still possible to set up everything at the workshop, but it can steal some time
and leave you with less time to play around :)

## Working in stages

The workshop relies on a high-level library for buildling Telegram bots: [`telegram-bot-simple`](https://github.com/fizruk/telegram-bot-simple).
The library is under development (does not support the whole Telegram Bot API out of the box at the time of writing),
but you still can write any Telegram bot with it.

The workshop goes in stages, and you can find the code for every stage in [app/stages](app/stages).
Here's what is accomplished in each stage:

- **Stage 1**. ([source](app/stages/stage_1.hs))

  Basic Telegram bot application structure with debug tracing. The bot does nothing yet.

- **Stage 2**. ([source](app/stages/stage_2.hs))

  Bot that replies _"Got it."_ to every incoming Telegram update in a corresponding chat.

- **Stage 3**. ([source](app/stages/stage_3.hs))

  An echo bot.

- **Stage 4**. ([source](app/stages/stage_4.hs))

  A task manager bot that can save todo items (you can see them saved in debug trace).

- **Stage 5**. ([source](app/stages/stage_5.hs))

  A task manager bot that can add items, remove them and show a list of things to do (through commands).

- **Stage 6**. ([source](app/stages/stage_6.hs))

  Like Stage 5 but with a nice help message (on `/start` command).

- **Stage 7**. ([source](app/stages/stage_7.hs))

  Like Stage 6 but with a reply keyboard with some starting to do suggestions.

- **Stage 8**. ([source](app/stages/stage_8.hs))

  Like Stage 7 but a list of items (available with `/show` command) is now interactive
  (using an inline keyboard) and users can modify items conveniently using that keyboard:

    - remove an item (mark as done);
    - set a reminder in 1 min or 5 min;
    - go back to the list of items.

  This version has a bot job to enable reminders and a custom timer implementation.

  This stage is a bit of a leap from Stage 7, but it's still pretty straightforward to understand.
