FROM elixir:1.13.4-alpine AS build

WORKDIR /app

ENV MIX_ENV=prod
RUN mix do local.hex --force, local.rebar --force

COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

COPY config config
COPY lib lib
RUN mix do compile, release

FROM alpine:3.16

RUN apk update && apk upgrade --no-cache && apk add --no-cache ncurses-libs

ENV MIX_ENV=prod
ENV PORT=8080
EXPOSE ${PORT}

WORKDIR /app

COPY --from=build /app/_build/prod/rel/raccoon_server .

CMD ["/app/bin/raccoon_server", "start"]
