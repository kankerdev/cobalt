FROM node:23-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

FROM base AS build

RUN corepack enable
RUN apk add --no-cache python3 alpine-sdk


FROM build AS build-api
WORKDIR /app
COPY . /app

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --prod --frozen-lockfile

RUN pnpm deploy --filter=@imput/cobalt-api --prod /prod/api


FROM base AS api
WORKDIR /app

COPY --from=build-api /prod/api /app
COPY --from=build-api /app/.git /app/.git

EXPOSE 9000
CMD [ "node", "src/cobalt" ]


FROM build AS build-web
ARG WEB_HOST WEB_DEFAULT_API
ENV WEB_HOST=${WEB_HOST:-cobalt.kanker.dev}
ENV WEB_DEFAULT_API=${WEB_DEFAULT_API}
WORKDIR /app
COPY . /app

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --frozen-lockfile

RUN pnpm run -r build


FROM nginx:alpine-slim AS web

COPY --from=build-web /app/web/build /usr/share/nginx/html

EXPOSE 80
