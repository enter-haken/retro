FROM node:12.2.0 as client_builder 

# set working directory
WORKDIR /app

# add `/app/node_modules/.bin` to $PATH
ENV PATH /app/node_modules/.bin:$PATH

RUN npm install -g @angular/cli@8.3.26

# add app

COPY client/ .

RUN make deep_clean build 

# backend builder

FROM elixir:1.9.4 AS backend_builder

WORKDIR /app

COPY . .

COPY --from=client_builder /app/dist client/dist

RUN mix local.hex --force
RUN mix local.rebar --force

RUN make release

# backend runner 

FROM elixir:1.9.4-slim AS runner

WORKDIR /app

COPY --from=backend_builder /app/_build/prod/rel/retro .

EXPOSE 5050 

CMD ["bin/retro", "start"]

